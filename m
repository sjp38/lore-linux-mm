Received: from [129.179.161.11] by ns1.cdc.com with ESMTP for linux-mm@kvack.org; Thu, 30 Aug 2001 09:28:31 -0500
Message-Id: <3B8E4CB7.4010509@syntegra.com>
Date: Thu, 30 Aug 2001 09:24:55 -0500
From: Andrew Kay <Andrew.J.Kay@syntegra.com>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva> <20010829150716Z16100-32383+2280@humbolt.nl.linux.org> <3B8D14E5.7070204@syntegra.com> <20010829175351Z16158-32383+2308@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I'm willing to guess at this point that this atomic failure is not a bug, the 
> only bug is that we print the warning message, potentially slowing things 
> down.  I'd like to see a correct backtrace first.
> 
> Do you detect any slowdown in your system when you're getting these messages? 
> I wouldn't expect so from what you've described so far.


I don't notice any slowdown in the system, but certain operations hang. 
  Such as vmstat, ps, and our SMTP server.  They lock up completely. 
The load average is at 20, but the CPU is completely idle.
Here's another attempt at ksymoops output:

ksymoops 2.4.0 on i686 2.4.9.  Options used
      -V (default)
      -k /proc/ksyms (default)
      -l /proc/modules (default)
      -o /lib/modules/2.4.9/ (default)
      -m /boot/System.map-2.4.9 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Aug 29 19:00:17 dhcp80-252 kernel: Call Trace: [<c0129b60>] [<c0129e0e>] 
[<c0126e7a>] [<c0127029>] [<c01f8242>]
Aug 29 19:00:17 dhcp80-252 kernel:    [<c021c02a>] [<c0219a6b>] 
[<c021c6b1>] [<c01a9024>] [<c0206464>] [<c0200413>]
Aug 29 19:00:17 dhcp80-252 kernel:    [<c0206464>] [<c01fc517>] 
[<c0206464>] [<c020651d>] [<c0206464>] [<c0206935>]
Aug 29 19:00:17 dhcp80-252 kernel:    [<c0106bf4>] [<c0206400>] 
[<c01fa441>] [<c0206935>] [<c01fa441>] [<c01f8fc3>]
Aug 29 19:00:17 dhcp80-252 kernel:    [<c01f8fd7>] [<c01f910b>] 
[<c0219c9e>] [<c0219f3d>] [<c021a35b>] [<c020414f>]
Aug 29 19:00:17 dhcp80-252 kernel:    [<c02044a9>] [<c01a8de4>] 
[<c01fca3d>] [<c0116f6d>] [<c0107ff4>] [<c01051a0>]
Aug 29 19:00:17 dhcp80-252 kernel:    [<c01051a0>] [<c0106bf4>] 
[<c01051a0>] [<c01051a0>] [<c01051c3>] [<c0105224>]
Aug 29 19:00:18 dhcp80-252 kernel:    [<c0105000>] [<c0105027>]
Aug 29 19:00:18 dhcp80-252 kernel: Call Trace: [<c0129b60>] [<c0129e0e>] 
[<c0126e7a>] [<c0127029>] [<c01f8242>]
Aug 29 19:00:18 dhcp80-252 kernel:    [<c021c02a>] [<c0219a6b>] 
[<c021c6b1>] [<c01a9024>] [<c01a954e>] [<c0206464>]
Aug 29 19:00:18 dhcp80-252 kernel:    [<c0200413>] [<c0206464>] 
[<c01fc517>] [<c0206464>] [<c020651d>] [<c0206464>]
Aug 29 19:00:18 dhcp80-252 kernel:    [<c0206935>] [<c01fc517>] 
[<c0206464>] [<c020651d>] [<c0206464>] [<c0214500>]
Aug 29 19:00:18 dhcp80-252 kernel:    [<c0214627>] [<c02150bf>] 
[<c01f8fc3>] [<c01f8fd7>] [<c01f910b>] [<c0219c9e>]
Aug 29 19:00:18 dhcp80-252 kernel:    [<c0219f3d>] [<c021a35b>] 
[<c020414f>] [<c02044a9>] [<c01a8de4>] [<c01fca3d>]
Aug 29 19:00:18 dhcp80-252 kernel:    [<c0116f6d>] [<c0107ff4>] 
[<c01051a0>] [<c01051a0>] [<c0106bf4>] [<c01051a0>]
Aug 29 19:00:18 dhcp80-252 kernel:    [<c01051a0>] [<c01051c3>] 
[<c0105224>] [<c0105000>] [<c0105027>]
Warning (Oops_read): Code line not seen, dumping what data is available

Trace; c0129b60 <_alloc_pages+18/1c>
Trace; c0129e0e <__get_free_pages+a/18>
Trace; c0126e7a <kmem_cache_grow+ce/234>
Trace; c0127029 <kmem_cache_alloc+49/58>
Trace; c01f8242 <sk_alloc+12/58>
Trace; c021c02a <tcp_create_openreq_child+16/44c>
Trace; c0219a6b <tcp_v4_syn_recv_sock+57/248>
Trace; c021c6b1 <tcp_check_req+251/380>
Trace; c01a9024 <speedo_refill_rx_buf+40/20c>
Trace; c0206464 <ip_output+0/f0>
Trace; c0200413 <qdisc_restart+13/c8>
Trace; c0206464 <ip_output+0/f0>
Trace; c01fc517 <dev_queue_xmit+117/264>
Trace; c0206464 <ip_output+0/f0>
Trace; c020651d <ip_output+b9/f0>
Trace; c0206464 <ip_output+0/f0>
Trace; c0206935 <ip_queue_xmit+3e1/540>
Trace; c0106bf4 <ret_from_intr+0/7>
Trace; c0206400 <ip_mc_output+108/16c>
Trace; c01fa441 <skb_copy_and_csum_bits+51/35c>
Trace; c0206935 <ip_queue_xmit+3e1/540>
Trace; c01fa441 <skb_copy_and_csum_bits+51/35c>
Trace; c01f8fc3 <skb_release_data+67/70>
Trace; c01f8fd7 <kfree_skbmem+b/58>
Trace; c01f910b <__kfree_skb+e7/f0>
Trace; c0219c9e <tcp_v4_hnd_req+42/150>
Trace; c0219f3d <tcp_v4_do_rcv+91/108>
Trace; c021a35b <tcp_v4_rcv+3a7/618>
Trace; c020414f <ip_local_deliver+eb/164>
Trace; c02044a9 <ip_rcv+2e1/338>
Trace; c01a8de4 <speedo_interrupt+b0/2b0>
Trace; c01fca3d <net_rx_action+135/208>
Trace; c0116f6d <do_softirq+5d/ac>
Trace; c0107ff4 <do_IRQ+98/a8>
Trace; c01051a0 <default_idle+0/28>
Trace; c01051a0 <default_idle+0/28>
Trace; c0106bf4 <ret_from_intr+0/7>
Trace; c01051a0 <default_idle+0/28>
Trace; c01051a0 <default_idle+0/28>
Trace; c01051c3 <default_idle+23/28>
Trace; c0105224 <cpu_idle+3c/50>
Trace; c0105000 <_stext+0/0>
Trace; c0105027 <rest_init+27/28>
Trace; c0129b60 <_alloc_pages+18/1c>
Trace; c0129e0e <__get_free_pages+a/18>
Trace; c0126e7a <kmem_cache_grow+ce/234>
Trace; c0127029 <kmem_cache_alloc+49/58>
Trace; c01f8242 <sk_alloc+12/58>
Trace; c021c02a <tcp_create_openreq_child+16/44c>
Trace; c0219a6b <tcp_v4_syn_recv_sock+57/248>
Trace; c021c6b1 <tcp_check_req+251/380>
Trace; c01a9024 <speedo_refill_rx_buf+40/20c>
Trace; c01a954e <speedo_rx+326/344>
Trace; c0206464 <ip_output+0/f0>
Trace; c0200413 <qdisc_restart+13/c8>
Trace; c0206464 <ip_output+0/f0>
Trace; c01fc517 <dev_queue_xmit+117/264>
Trace; c0206464 <ip_output+0/f0>
Trace; c020651d <ip_output+b9/f0>
Trace; c0206464 <ip_output+0/f0>
Trace; c0206935 <ip_queue_xmit+3e1/540>
Trace; c01fc517 <dev_queue_xmit+117/264>
Trace; c0206464 <ip_output+0/f0>
Trace; c020651d <ip_output+b9/f0>
Trace; c0206464 <ip_output+0/f0>
Trace; c0214500 <tcp_transmit_skb+36c/540>
Trace; c0214627 <tcp_transmit_skb+493/540>
Trace; c02150bf <tcp_write_xmit+18f/2dc>
Trace; c01f8fc3 <skb_release_data+67/70>
Trace; c01f8fd7 <kfree_skbmem+b/58>
Trace; c01f910b <__kfree_skb+e7/f0>
Trace; c0219c9e <tcp_v4_hnd_req+42/150>
Trace; c0219f3d <tcp_v4_do_rcv+91/108>
Trace; c021a35b <tcp_v4_rcv+3a7/618>
Trace; c020414f <ip_local_deliver+eb/164>
Trace; c02044a9 <ip_rcv+2e1/338>
Trace; c01a8de4 <speedo_interrupt+b0/2b0>
Trace; c01fca3d <net_rx_action+135/208>
Trace; c0116f6d <do_softirq+5d/ac>
Trace; c0107ff4 <do_IRQ+98/a8>
Trace; c01051a0 <default_idle+0/28>
Trace; c01051a0 <default_idle+0/28>
Trace; c0106bf4 <ret_from_intr+0/7>
Trace; c01051a0 <default_idle+0/28>
Trace; c01051a0 <default_idle+0/28>
Trace; c01051c3 <default_idle+23/28>
Trace; c0105224 <cpu_idle+3c/50>
Trace; c0105000 <_stext+0/0>
Trace; c0105027 <rest_init+27/28>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
