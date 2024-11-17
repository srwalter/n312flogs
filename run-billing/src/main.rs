use mysql::prelude::*;
use mysql::PooledConn;

fn sql_connect(database: &str, password: &str) -> Result<PooledConn, mysql::Error> {
    let opts = mysql::OptsBuilder::new()
        .ip_or_hostname(Some("127.0.0.1"))
        .user(Some("srwalter"))
        .pass(Some(password.trim()))
        .db_name(Some(database));

    let pool = mysql::Pool::new(opts)?;
    pool.get_conn()
}

#[derive(Debug)]
struct FlightLog {
    day: String,
    pilot: String,
    tach_hours : f64
}

#[derive(Debug)]
struct Invoice {
    invoice_number: u32,
    name: String,
    _opened: String,
    _posted: Option<String>,
    _due: Option<String>,
    _paid: String,
}

fn get_invoice(invoices: &[Invoice], mut name: &str) -> u32 {
    if name == "Vickus" {
        name = "Phillippus";
    }
    if name == "Jim" {
        name = "James";
    }

    for i in invoices {
        if i.name.starts_with(name) {
            return i.invoice_number;
        }
    }
    panic!()
}

type Error = Box<dyn std::error::Error + Send + Sync + 'static>;

fn main() -> Result<(), Error> {
    let db = "n312flogs";

    eprint!("Enter password: ");
    let mut password = String::new();
    std::io::stdin().read_line(&mut password)?;

    let mut conn = sql_connect(&db, &password)?;
    let info = conn.query_map("CALL getBillingLogs()", |(day, pilot, tach_hours)| {
        FlightLog { day, pilot, tach_hours }
    })?;

    let mut conn = sql_connect("n312f", &password)?;
    let invoices = conn.query_map("CALL listOpenInvoices()", |(invoice_number, name, _opened, _posted, _due, _paid)| {
        Invoice { invoice_number, name, _opened, _posted, _due, _paid }
    })?;
    println!("{:?}", invoices);

    for i in info {
        println!("{:?}", i);
        if i.pilot == "MX" {
            continue;
        }
        let inv = get_invoice(&invoices, &i.pilot);
        let query = format!("CALL addtoInvoice({}, '{}', 'Flight', {}, 131, 26)", inv, i.day, i.tach_hours);
        println!("Query: {}", query);

        conn.query_map(query, |res: (String, String, String, String, String, String)| {
            println!("Result: {:?}", res);
        })?;
        println!();
    }


    Ok(())
}
