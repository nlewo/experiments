use std::fs::File;
use std::io::prelude::*;
use std::io::{Error, ErrorKind};

extern crate coreos_metadata;
use coreos_metadata::metadata::fetch_metadata;
use coreos_metadata::providers::openstack::network::OpenstackProvider;
use coreos_metadata::providers::MetadataProvider;

extern crate nix;
use nix::unistd::sethostname;

extern crate clap;
use clap::{Arg, App};
/*

nixos-init --provider openstack --non-declarative-ssh-keys --non-declarative-hostname

*/

fn main() {
    let matches = App::new("nixos-init")
        .version("1.0")
        .author("Antoine Eiche <lewo@abesis.fr>")
        .about("Initialize a Nixos system")
        .arg(Arg::with_name("provider")
             .short("p")
             .long("provider")
             .value_name("PROVIDER")
             .required(true)
             .help("The provider to fetch")
             .takes_value(true))
        .get_matches();

    println!("Fetch metadata...");
    let md = match fetch_metadata("openstack-metadata") {
        Ok(md) => md,
        Err(_) => panic!("Can not fetch metadata"),
    };

    println!("Write ssh keys...");
    md.write_ssh_keys("root".to_string());

    println!("Update hostname...");
    let hostname = match md.hostname() {
        Ok(ok) => match ok {
            Some(hostname) => Some(format!("networking.hostName = \"{}\";", hostname)),
            _ => None,
        }
        Err(e) => {
            println!("Cannot get hostname from metadata: {}", e);
            None
        }
    };

    println!("hostname: {:?}", hostname);

    let ssh_keys = match md.ssh_keys() {
        Ok(keys) => {
            let keys = keys.into_iter().map(|k| k.to_key_format());
            Some(format!("users.extraUsers.root.openssh.authorizedKeys.keys = [ {} ];", keys.join(" ")))
        },
        Err(e) => {
            println!("Cannot get ssh_keys from metadata: {}", e);
            None
        }
    };
    
    println!("hostname: {:?}", ssh_keys);
}

fn ssh_keys() -> String {
    return "users.extraUsers.root.openssh.authorizedKeys.keys = [ keys ];".to_string()
}


fn non_declarative_hostname(hostname: String) {
    match sethostname(hostname) {
        Ok(_) => println!("Hostname updated"),
        Err(e) => println!("Hostname update failure: {}", e),
    }
}

fn write_hardware_configuration() -> std::io::Result<()> {
    
    let mut file = File::create("hardware-configuration.nix")?;
    file.write_all(&ssh_keys().into_bytes())?;
    println!("File written!");

    Ok(())
}
