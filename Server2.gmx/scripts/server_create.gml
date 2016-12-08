#define server_create
///server_create(port)

var port = argument0;   //ports are like chanels or radio stations
server = 0;
server = network_create_server_raw(network_socket_tcp, port, 20);  //20 represents max amount of player in server
clientmap = ds_map_create();
client_id_counter = 0;

send_buffer = buffer_create(256, buffer_fixed, 1);

if(server < 0) show_error("Couldn't create server", true);

return server;

#define server_handle_connect
///server_handle_connect(socket_id);

var socket_id = argument0;

l = instance_create(0, 0, oServerClient);

l.socket_id = socket_id;

l.client_id = client_id_counter++;

if(client_id_counter >= 65000)
{
    client_id_counter = 0;
}

clientmap[? string(socket_id)] = l;


#define server_handle_message
///server_handle_message(socket_id, buffer);

//this is where things can differ a lot. 
var socket_id = argument0;

buffer = argument1;

client_id_current = clientmap[? string(socket_id)].client_id;
while(true)
{

var message_id = buffer_read(buffer, buffer_u8);

switch(message_id)
{

    case MESSAGE_MOVE:
        var 
        xx = buffer_read(buffer, buffer_u16);
        yy = buffer_read(buffer, buffer_u16);
        
        buffer_seek(send_buffer, buffer_seek_start, 0);     //start the buffer at the start so we dont go over 256 bytes
        
        buffer_write(send_buffer, buffer_u8, MESSAGE_MOVE);             //1 byte
        buffer_write(send_buffer, buffer_u16, client_id_current);       //2 bytes
        
        buffer_write(send_buffer, buffer_u16, xx);                      //2 bytes
        buffer_write(send_buffer, buffer_u16, yy);                      //2 bytes
                                                                  //     +------- 
                                                                        //7 bytes 
                                                                        //alltogether
        with(oServerClient)
        {
        
            if(client_id != client_id_current)
            {
                network_send_raw(self.socket_id, other.send_buffer, buffer_tell(other.send_buffer));    // this 7 is the total amount of bytes being sent
                
            }
        
        }
        
    break;

    }

    if(buffer_tell(buffer) == buffer_get_size(buffer))
    {
        break;
    }

}

#define server_handle_disconncet
///server_handle_disconncet(socket_id);

var socket_id = argument0;

with(clientmap[? (string(socket_id))])
{
    instance_destroy();
}

ds_map_delete(clientmap, string(socket_id));