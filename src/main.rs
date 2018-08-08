#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate rocket;
extern crate grpcio;
extern crate protos;

use rocket::config::{Config, Environment};

use grpcio::{ChannelBuilder, EnvBuilder};
use protos::helloworld::HelloRequest;
use protos::helloworld_grpc::GreeterClient;
use std::sync::Arc;

#[get("/")]
fn hello() -> String {
    let env = Arc::new(EnvBuilder::new().build());
    let ch = ChannelBuilder::new(env).connect("hello-proto-s:50051");
    let client = GreeterClient::new(ch);


    let mut req = HelloRequest::new();
    req.set_name("Rocket".to_owned());
    let reply = client.say_hello(&req).expect("rpc");

    format!("{} Webserver!", &reply.get_message())
}

fn main() {
    let config = Config::build(Environment::Staging)
        .address("0.0.0.0")
        .port(8000)
        .finalize()
        .unwrap();

    rocket::custom(config, true)
        .mount("/", routes![hello])
        .launch();
}

