Received: from [129.179.161.11] by ns1.cdc.com with ESMTP for linux-mm@kvack.org; Wed, 29 Aug 2001 11:17:48 -0500
Message-Id: <3B8D14E5.7070204@syntegra.com>
Date: Wed, 29 Aug 2001 11:14:29 -0500
From: Andrew Kay <Andrew.J.Kay@syntegra.com>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva> <20010828000128Z16263-32386+166@humbolt.nl.linux.org> <3B8CF2BA.5030506@syntegra.com> <20010829150716Z16100-32383+2280@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> OK, it's not a bounce buffer because the allocation isn't __GFP_WAIT (0x10).
> It's GFP_ATOMIC and there are several hundred of those throughout the kernel so
> I'm not going to try to guess which one.  Could you please pass a few of your
> backtraces through ksymoops make them meaningful?
> Daniel

I'm not sure I did this right, but here is my attempt.  I ran a 
'ksymoops' and gave it a couple of the errors.  The parts that look 
somewhat recognizable are the sk98lin, which is a Syskonnect gig over 
copper card.  It is the only module I have running on the system.

Andy


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

Error (regular_file): read_system_map stat /boot/System.map-2.4.9 failed
Warning (compare_maps): mismatch on symbol SkInodeOps  , sk98lin says 
f88e0500, /lib/modules/2.4.9/kernel/drivers/net/sk98lin/sk98lin.o says 
f88df9c0.  Ignoring 
/lib/modules/2.4.9/kernel/drivers/net/sk98lin/sk98lin.o entry
Aug 29 02:24:49 dell63 kernel: Call Trace: [<c012db70>] [<c012de1e>] 
[<c012a69e>] [<c012aa21>] [<c0211032>]
Aug 29 02:24:49 dell63 kernel:    [<c02392da>] [<c023669f>] [<c02399a1>] 
[<c01b000f>] [<f88c30fa>] [<c01b000f>]
Aug 29 02:24:49 dell63 kernel:    [<c021a714>] [<c02158e6>] [<c022173d>] 
[<c0221638>] [<c0221b5d>] [<c0112437>]
Aug 29 02:24:49 dell63 kernel:    [<c0221638>] [<c023099a>] [<c0112437>] 
[<c0211f53>] [<c0211f68>] [<c02120b9>]
Aug 29 02:24:49 dell63 kernel:    [<c023698e>] [<c0236c65>] [<c023711d>] 
[<c021f07f>] [<c021f40a>] [<c0215fae>]
Aug 29 02:24:49 dell63 kernel:    [<c0119533>] [<c0108785>] [<c0105230>] 
[<c0105230>] [<c0106e34>] [<c0105230>]
Aug 29 02:24:49 dell63 kernel:    [<c0105230>] [<c010525c>] [<c01052c2>] 
[<c0105000>] [<c010505f>]
Aug 29 02:24:49 dell63 kernel: Call Trace: [<c012db70>] [<c012de1e>] 
[<c012a69e>] [<c012aa21>] [<c0211032>]
Aug 29 02:24:49 dell63 kernel:    [<c02392da>] [<c023669f>] [<c02399a1>] 
[<c01b000f>] [<c021a714>] [<c02158e6>]
Aug 29 02:24:49 dell63 kernel:    [<c022173d>] [<c0221638>] [<c0221b5d>] 
[<c0221638>] [<c023099a>] [<c02314f1>]
Aug 29 02:24:49 dell63 kernel:    [<c022ea31>] [<c022e9dc>] [<c023698e>] 
[<c0236c65>] [<c023711d>] [<c021f07f>]
Aug 29 02:24:49 dell63 kernel:    [<c021f40a>] [<c0215fae>] [<c0119533>] 
[<c0108785>] [<c0105230>] [<c0105230>]
Aug 29 02:24:49 dell63 kernel:    [<c0106e34>] [<c0105230>] [<c0105230>] 
[<c010525c>] [<c01052c2>] [<c01ffaf7>]
Aug 29 02:24:49 dell63 kernel:    [<c019266e>]
Warning (Oops_read): Code line not seen, dumping what data is available

Trace; c012db70 <_alloc_pages+18/1c>
Trace; c012de1e <__get_free_pages+a/18>
Trace; c012a69e <kmem_cache_destroy+1fe/4d8>
Trace; c012aa21 <kmem_cache_alloc+a9/bc>
Trace; c0211032 <sk_alloc+12/5c>
Trace; c02392da <ip_cmsg_recv+165b6/19944>
Trace; c023669f <ip_cmsg_recv+1397b/19944>
Trace; c02399a1 <ip_cmsg_recv+16c7d/19944>
Trace; c01b000f <loop_unregister_transfer+82a7/c9d4>
Trace; f88c30fa <[sk98lin]SkGeIsrOnePort+12e/144>
Trace; c01b000f <loop_unregister_transfer+82a7/c9d4>
Trace; c021a714 <qdisc_restart+14/250>
Trace; c02158e6 <dev_queue_xmit+136/374>
Trace; c022173d <ip_options_undo+981/1734>
Trace; c0221638 <ip_options_undo+87c/1734>
Trace; c0221b5d <ip_options_undo+da1/1734>
Trace; c0112437 <iounmap+2f7/360>
Trace; c0221638 <ip_options_undo+87c/1734>
Trace; c023099a <ip_cmsg_recv+dc76/19944>
Trace; c0112437 <iounmap+2f7/360>
Trace; c0211f53 <alloc_skb+293/304>
Trace; c0211f68 <alloc_skb+2a8/304>
Trace; c02120b9 <__kfree_skb+f5/fc>
Trace; c023698e <ip_cmsg_recv+13c6a/19944>
Trace; c0236c65 <ip_cmsg_recv+13f41/19944>
Trace; c023711d <ip_cmsg_recv+143f9/19944>
Trace; c021f07f <inet_del_protocol+35b/3d4>
Trace; c021f40a <ip_rcv+312/df4>
Trace; c0215fae <net_call_rx_atomic+1d6/2d4>
Trace; c0119533 <do_softirq+83/e0>
Trace; c0108785 <enable_irq+189/198>
Trace; c0105230 <enable_hlt+8/178>
Trace; c0105230 <enable_hlt+8/178>
Trace; c0106e34 <__read_lock_failed+1174/2630>
Trace; c0105230 <enable_hlt+8/178>
Trace; c0105230 <enable_hlt+8/178>
Trace; c010525c <enable_hlt+34/178>
Trace; c01052c2 <enable_hlt+9a/178>
Trace; c0105000 <gdt+4d94/4fb4>
Trace; c010505f <gdt+4df3/4fb4>
Trace; c012db70 <_alloc_pages+18/1c>
Trace; c012de1e <__get_free_pages+a/18>
Trace; c012a69e <kmem_cache_destroy+1fe/4d8>
Trace; c012aa21 <kmem_cache_alloc+a9/bc>
Trace; c0211032 <sk_alloc+12/5c>
Trace; c02392da <ip_cmsg_recv+165b6/19944>
Trace; c023669f <ip_cmsg_recv+1397b/19944>
Trace; c02399a1 <ip_cmsg_recv+16c7d/19944>
Trace; c01b000f <loop_unregister_transfer+82a7/c9d4>
Trace; c021a714 <qdisc_restart+14/250>
Trace; c02158e6 <dev_queue_xmit+136/374>
Trace; c022173d <ip_options_undo+981/1734>
Trace; c0221638 <ip_options_undo+87c/1734>
Trace; c0221b5d <ip_options_undo+da1/1734>
Trace; c0221638 <ip_options_undo+87c/1734>
Trace; c023099a <ip_cmsg_recv+dc76/19944>
Trace; c02314f1 <ip_cmsg_recv+e7cd/19944>
Trace; c022ea31 <ip_cmsg_recv+bd0d/19944>
Trace; c022e9dc <ip_cmsg_recv+bcb8/19944>
Trace; c023698e <ip_cmsg_recv+13c6a/19944>
Trace; c0236c65 <ip_cmsg_recv+13f41/19944>
Trace; c023711d <ip_cmsg_recv+143f9/19944>
Trace; c021f07f <inet_del_protocol+35b/3d4>
Trace; c021f40a <ip_rcv+312/df4>
Trace; c0215fae <net_call_rx_atomic+1d6/2d4>
Trace; c0119533 <do_softirq+83/e0>
Trace; c0108785 <enable_irq+189/198>
Trace; c0105230 <enable_hlt+8/178>
Trace; c0105230 <enable_hlt+8/178>
Trace; c0106e34 <__read_lock_failed+1174/2630>
Trace; c0105230 <enable_hlt+8/178>
Trace; c0105230 <enable_hlt+8/178>
Trace; c010525c <enable_hlt+34/178>
Trace; c01052c2 <enable_hlt+9a/178>
Trace; c01ffaf7 <isapnp_resource_change+24c3/353c>
Trace; c019266e <secure_tcp_sequence_number+4746/4b38>

3 warnings and 1 error issued.  Results may not be reliable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
