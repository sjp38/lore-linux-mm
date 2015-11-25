Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D7E266B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:17:59 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so60831106pab.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:17:59 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id hz13si1423133pab.78.2015.11.25.06.17.56
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 06:17:59 -0800 (PST)
Message-ID: <5655C08D.5010201@huawei.com>
Date: Wed, 25 Nov 2015 22:07:09 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: x86:  Is the phenomenon normal  ?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Xishi Qiu <qiuxishi@huawei.com>

HI

Cpu0 and Cpu2 have taken place in a deadlock. cpu4 hold the lock currently.
and the three cpu enter into the handle_pte_fault function.  Is the phenomenon
could happen?  The call trace is as follows.

Thanks
zhongjiang

<0>[46435.416685] BUG: spinlock lockup on CPU#2, current: msg_server/48476
<0>[46435.416692]  lock: <NULL>/0xffff880101d71868, .magic: dead4ead, .owner: msg_server/33869, .owner_cpu: 4
<4>[46435.416699] Pid: 48476, comm: msg_server Tainted: P           O 3.4.24.19-0.11-default #1
<4>[46435.416703] Call Trace:
<4>[46435.416717]  [<ffffffff8143c79a>] show_spin_dump+0x52/0x56
<4>[46435.416723]  [<ffffffff8143c9a6>] spin_dump+0x108/0x116
<4>[46435.416733]  [<ffffffff81225674>] ? do_raw_spin_lock+0x64/0x110
<4>[46435.416739]  [<ffffffff81225714>] do_raw_spin_lock+0x104/0x110
<4>[46435.416745]  [<ffffffff81441889>] _raw_spin_lock+0x9/0x10
<4>[46435.416752]  [<ffffffff8110a2ee>] handle_pte_fault+0x1ae/0xa40
<4>[46435.416766]  [<ffffffff813441d4>] ? netif_rx+0x44/0xe0
<4>[46435.416774]  [<ffffffff812ec3b0>] ? loopback_xmit+0x80/0xa0
<4>[46435.416779]  [<ffffffff8110ae5d>] handle_mm_fault+0x13d/0x1d0
<4>[46435.416785]  [<ffffffff81444f78>] do_page_fault+0x168/0x4c0
<4>[46435.416793]  [<ffffffff81001600>] ? __switch_to+0x170/0x430
<4>[46435.416799]  [<ffffffff814417e9>] ? _raw_spin_unlock_irq+0x9/0x20
<4>[46435.416806]  [<ffffffff81064853>] ? finish_task_switch+0x63/0xd0
<4>[46435.416811]  [<ffffffff8143f65c>] ? __schedule+0x39c/0x810
<4>[46435.416817]  [<ffffffff81441cf5>] page_fault+0x25/0x30
<4>[46435.416827]  [<ffffffff8121e386>] ? copy_user_enhanced_fast_string+0x6/0x10
<4>[46435.416836]  [<ffffffff8133b97a>] ? memcpy_toiovec+0x4a/0x90
<4>[46435.416842]  [<ffffffff8133c823>] skb_copy_datagram_iovec+0x63/0x250
<4>[46435.416849]  [<ffffffff81383d03>] tcp_recvmsg+0x1d3/0xa10
<4>[46435.416854]  [<ffffffff81382506>] ? tcp_sendmsg+0x796/0xdd0
<4>[46435.416863]  [<ffffffff813a66c6>] inet_recvmsg+0x66/0x80
<4>[46435.416868]  [<ffffffff813a6741>] ? inet_sendmsg+0x61/0xb0
<4>[46435.416875]  [<ffffffff81330778>] sock_recvmsg+0xf8/0x130
<4>[46435.416881]  [<ffffffff8132e123>] ? sock_sendmsg+0xf3/0x120
<4>[46435.416887]  [<ffffffff81147efd>] ? path_put+0x1d/0x30
<4>[46435.416895]  [<ffffffff8115acb7>] ? mntput_no_expire+0x27/0x140
<4>[46435.416902]  [<ffffffff810ba9f2>] ? call_rcu_sched+0x12/0x20
<4>[46435.416909]  [<ffffffff8112e9b0>] ? kfree+0x30/0x110
<4>[46435.416915]  [<ffffffff81331484>] sys_recvfrom+0xe4/0x150
<4>[46435.416922]  [<ffffffff8113e842>] ? fput+0x182/0x240
<4>[46435.416927]  [<ffffffff8113b3b1>] ? filp_close+0x61/0x90
<4>[46435.416934]  [<ffffffff81449319>] system_call_fastpath+0x16/0x1b
<0>[46436.026368] BUG: spinlock lockup on CPU#0, current: msg_server/30122
<0>[46436.026375]  lock: <NULL>/0xffff880101d71868, .magic: dead4ead, .owner: msg_server/33869, .owner_cpu: 4
<4>[46436.026380] Pid: 30122, comm: msg_server Tainted: P           O 3.4.24.19-0.11-default #1
<4>[46436.026384] Call Trace:
<4>[46436.026395]  [<ffffffff8143c79a>] show_spin_dump+0x52/0x56
<4>[46436.026401]  [<ffffffff8143c9a6>] spin_dump+0x108/0x116
<4>[46436.026409]  [<ffffffff81225671>] ? do_raw_spin_lock+0x61/0x110
<4>[46436.026415]  [<ffffffff81225714>] do_raw_spin_lock+0x104/0x110
<4>[46436.026421]  [<ffffffff81441889>] _raw_spin_lock+0x9/0x10
<4>[46436.026427]  [<ffffffff8110a2ee>] handle_pte_fault+0x1ae/0xa40
<4>[46436.026433]  [<ffffffff8114c700>] ? do_last+0x440/0x930
<4>[46436.026439]  [<ffffffff8110ae5d>] handle_mm_fault+0x13d/0x1d0
<4>[46436.026446]  [<ffffffff81444f78>] do_page_fault+0x168/0x4c0
<4>[46436.026452]  [<ffffffff8113e842>] ? fput+0x182/0x240
<4>[46436.026458]  [<ffffffff81441cf5>] page_fault+0x25/0x30
<5>[46436.915773] [11630280][1500002c101e7][INFO][Card:0 restore default delay time:3 s][SAS_INI][SAL_RestoreDlyTimeHandler,2761][msg_server]
<4>[46437.266152] [11630367][15000009d007e][WARN][Queue 0xffff8801d34dd650, dev 68, qflag 0x4, sched busy 189, dev busy 1, disp busy 1.][BDM_SIO][sioUnplugWatchdog,152][CSD_0]
<4>[46439.666771] [11630969][15000008e0046][WARN][IOD thread2 has been blocked for about 10s,current running req(SIO_DIF_WRITE, pid:157).][IOD][checkDetectReqAndTimer,317][IodDetectThread]
<3>[46440.888489] os soft lockup - CPU#4 10s not feed dog [msg_server:33869].
<4>[46440.888499] Pid: 33869, comm: msg_server Tainted: P           O 3.4.24.19-0.11-default #1
<4>[46440.888505] Call Trace:
<4>[46440.888509]  <IRQ>  [<ffffffff81061064>] os_softlockup_tick+0x144/0x190
<4>[46440.888538]  [<ffffffff81046cc8>] run_local_timers+0x18/0x20
<4>[46440.888543]  [<ffffffff81046d08>] update_process_times+0x38/0x80
<4>[46440.888550]  [<ffffffff8108aee1>] tick_sched_timer+0x61/0xc0
<4>[46440.888554]  [<ffffffff8105bd34>] __run_hrtimer+0x84/0x1c0
<4>[46440.888557]  [<ffffffff8108ae80>] ? tick_nohz_handler+0x110/0x110
<4>[46440.888561]  [<ffffffff8103e4aa>] ? __do_softirq+0x14a/0x200
<4>[46440.888564]  [<ffffffff8105c62f>] hrtimer_interrupt+0xef/0x230
<4>[46440.888569]  [<ffffffff8144a71c>] ? call_softirq+0x1c/0x30
<4>[46440.888573]  [<ffffffff81020c84>] smp_apic_timer_interrupt+0x64/0xa0
<4>[46440.888593]  [<ffffffff81449dca>] apic_timer_interrupt+0x6a/0x70
<4>[46440.888595]  <EOI>  [<ffffffff810303f8>] ? native_flush_tlb_others+0xe8/0x120
<4>[46440.888608]  [<ffffffff810303eb>] ? native_flush_tlb_others+0xdb/0x120
<4>[46440.888614]  [<ffffffff81030599>] flush_tlb_page+0x59/0xb0
<4>[46440.888620]  [<ffffffff8102f8a2>] ptep_set_access_flags+0x62/0x70
<4>[46440.888627]  [<ffffffff81108ac1>] do_wp_page+0x321/0x710
<4>[46440.888633]  [<ffffffff8110a4c3>] handle_pte_fault+0x383/0xa40
<4>[46440.888679]  [<ffffffff813441d4>] ? netif_rx+0x44/0xe0
<4>[46440.888688]  [<ffffffff812ec3b0>] ? loopback_xmit+0x80/0xa0
<4>[46440.888693]  [<ffffffff8110ae5d>] handle_mm_fault+0x13d/0x1d0
<4>[46440.888698]  [<ffffffff81444f78>] do_page_fault+0x168/0x4c0
<4>[46440.888705]  [<ffffffff8106cb6a>] ? __dequeue_entity+0x2a/0x50
<4>[46440.888713]  [<ffffffff81001600>] ? __switch_to+0x170/0x430
<4>[46440.888718]  [<ffffffff8106e178>] ? set_next_entity+0x78/0x80
<4>[46440.888725]  [<ffffffff814417e9>] ? _raw_spin_unlock_irq+0x9/0x20
<4>[46440.888732]  [<ffffffff81064853>] ? finish_task_switch+0x63/0xd0
<4>[46440.888737]  [<ffffffff8143f65c>] ? __schedule+0x39c/0x810
<4>[46440.888743]  [<ffffffff81441cf5>] page_fault+0x25/0x30
<4>[46440.888753]  [<ffffffff8121e386>] ? copy_user_enhanced_fast_string+0x6/0x10
<4>[46440.888761]  [<ffffffff8133b97a>] ? memcpy_toiovec+0x4a/0x90
<4>[46440.888767]  [<ffffffff8133c823>] skb_copy_datagram_iovec+0x63/0x250
<4>[46440.888775]  [<ffffffff81383d03>] tcp_recvmsg+0x1d3/0xa10
<4>[46440.888780]  [<ffffffff81382506>] ? tcp_sendmsg+0x796/0xdd0
<4>[46440.888788]  [<ffffffff813a66c6>] inet_recvmsg+0x66/0x80
<4>[46440.888793]  [<ffffffff813a6741>] ? inet_sendmsg+0x61/0xb0
<4>[46440.888800]  [<ffffffff81330778>] sock_recvmsg+0xf8/0x130
<4>[46440.888806]  [<ffffffff8132e123>] ? sock_sendmsg+0xf3/0x120
<4>[46440.888812]  [<ffffffff81147efd>] ? path_put+0x1d/0x30
<4>[46440.888819]  [<ffffffff8115acb7>] ? mntput_no_expire+0x27/0x140
<4>[46440.888825]  [<ffffffff810ba9f2>] ? call_rcu_sched+0x12/0x20
<4>[46440.888830]  [<ffffffff81157002>] ? evict+0x112/0x1a0
<4>[46440.888836]  [<ffffffff81331484>] sys_recvfrom+0xe4/0x150
<4>[46440.888843]  [<ffffffff8113e842>] ? fput+0x182/0x240
<4>[46440.888848]  [<ffffffff8113b3b1>] ? filp_close+0x61/0x90
<4>[46440.888854]  [<ffffffff81449319>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
