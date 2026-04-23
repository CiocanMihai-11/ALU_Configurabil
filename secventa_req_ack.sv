class secventa_req_ack extends uvm_sequence #(req_ack_item);

  `uvm_object_utils(secventa_req_ack)

  function new(string name = "secventa_req_ack");
    super.new(name);
  endfunction
task body(); 
  req_ack_item item; 
  repeat(10) begin 
    item = req_ack_item::type_id::create("item");          item.delay=$urandom_range(0,5);
    item.data=$urandom();
    start_item(item); 
    finish_item(item); end
endtask

endclass
