    class checker_base;

        test_cfg_base cfg;

        bit done;
        int cnt;
        bit in_reset;

        mailbox#(packet) in_mbx;
        mailbox#(packet) out_mbx;

        virtual task run();
            packet tmp_p;
            forever begin
                wait(~in_reset);
                fork
                    do_check();
                    wait(in_reset);
                join_any
                disable fork;
                if( done ) break;
                while(in_mbx.try_get(tmp_p)) cnt = cnt + tmp_p.tlast;
            end
        endtask

        virtual task check(packet in, packet out);
            assert( in.tid === out.tid );
            assert( out.tdata === in.tdata ** 5 );
            assert( in.tlast === out.tlast );
        endtask

        virtual task do_check();
            packet in_p, out_p;
            forever begin
                in_mbx.get(in_p);
                out_mbx.get(out_p);
                check(in_p, out_p);
                cnt = cnt + out_p.tlast;
                if( cnt == cfg.master_pkt_amount ) begin
                    done = 1;
                    break;
                end
            end
        endtask

    endclass