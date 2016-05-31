import vibe.core.core;
import vibe.http.server;
import vibe.http.router;
import ddb.postgres;
import asdf : serializeToJson, jsonSerializer, serializeValue;

import std.algorithm : map;
import std.array : array;
import vibe.core.connectionpool;

private PostgresDB g_pgdb;
auto connectDB() {
    if (!g_pgdb) {
        auto params = [
            "host" : "localhost",
            "database" : "ecratum",
            "user" : "yannick",
            "password" : ""
        ];
       
        g_pgdb = new PostgresDB(params);
        g_pgdb.maxConcurrency = 4; //try with num cpus first
    }
   
    return g_pgdb.lockConnection();
}


struct Company
{
    long id;
    string name;
}

import std.typecons;
import memutils.unique;
void bench(scope HTTPServerRequest req, scope HTTPServerResponse res)
{
    auto conn = connectDB();

    Company[] companies;
    auto cmd = scoped!PGCommand(conn, "SELECT id, name from companies LIMIT 10");

    auto result = cmd.executeQuery!(long, string)().unique();
    foreach (row; *result) {
        companies ~= Company(row[0], row[1]);
    }
    result.close(); //close right after you read

    res.writeBody(companies.serializeToJson() ); 
    
}

void main()
{

    auto router = new URLRouter;

    router.get("/", &bench);
    auto settings = new HTTPServerSettings;
    settings.port = 8080;

    listenHTTP(settings, router);
    runEventLoop();
}
