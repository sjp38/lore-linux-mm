Message-ID: <3EB8DBA0.7020305@aitel.hist.no>
Date: Wed, 07 May 2003 12:10:40 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
References: <20030506232326.7e7237ac.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.5.69-mm1 is fine, 2.5.69-mm2 panics after a while even under very
light load.

Machine: 2.4GHz Pentium IV UP,
network card: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 78)
video: ATI Technologies Inc Radeon RV100 QY [Radeon 7000/VE]

Kernel config details:
UP, no module support, devfs, preempt, console on radeonfb

I got the OOPS this way:
boot normally (with X and network), switch to console
and log in, play nethack on the console until it oopses.
It will oops while in X too, but then there's nothing
visible to write down.

This is what I managed to write down. The first part scrolled
off screen with no scrollback - and no logfiles due to the
"not syncing" part:

<lost information>
ip_local_deliver
ip_local_deliver _finish
ip_recv_finish
ip_recv_finish
nf_hook_slow
ip_rcv_finish
ip_rcv
ip_rcv_finish
netif_receive_sub
process_backlog
net_rx_action
do_softirq
do_IRQ
default_idle
default_idle
common_interrupt
default_idle
default_idle
default_idle
cpu_idle
rest_init
start_kernel
unknown_bootoption
<0>Kernel panic: Fatal exception in interrupt
in interrupt handler - not syncing

Helge Hafting


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
