Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35DB16B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 02:46:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d127so2862936pga.11
        for <linux-mm@kvack.org>; Tue, 16 May 2017 23:46:01 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id 24si1184170pgy.279.2017.05.16.23.45.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 23:45:59 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [Question] softlock up in handle_mm_fault
Message-ID: <b96a3728-1ed7-1264-b208-bd1572b08fcb@huawei.com>
Date: Wed, 17 May 2017 14:45:02 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: will.deacon@arm.com, mark.rutland@arm.com, ard.biesheuvel@linaro.org, mhocko@kernel.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, liubo95@huawei.com

Hi all,
We met a softlockup problem in handle_mm_fault on platform arm32 with v4.1 kernel.
And from the log it seems do not have any deadlock or loopback.

Does anyone ever met similar problem or any idea about this problem?

Any reply is more than welcome!

Thanks.
Yisheng Xie

-------dmesg--------
[20170512182106]NMI watchdog: BUG: soft lockup - CPU#2 stuck for 410ms! [UMPTB.out:1681]
[20170512182106]Modules linked in: memory_add(O) pramdisk(O) rsm(O) mcss(O) hiuart(O) hii2c(O) himdio(O) hispi(O) npmac(O) hffs(O) hinand(O) nor(O) higmac(O) gic(O) upbcom_ipc(O) bsplogutil(O) Wdt_Hi1380_kernel(O) higpio(O) gpio(O) rtos_snapshot(O) virtualcpu(O) comm(O) NandDrv(O) bsplog(O) rtos_kbox_panic(O) enable_uart_rx(O) uart_suspend(O) double_cluster(O) xt_tcpudp vfat fat usbhid hid usb_device_hisi(O) sd_mod physmap ohci_hcd nfsd nfs_acl exportfs auth_rpcgss oid_registry nfs lockd sunrpc grace nand_ids nand_ecc mtdblock mtd_blkdevs iptable_filter ip_tables ipt_REJECT x_tables nf_reject_ipv4 invalid_Icache(O) ehci_hcd cmdlinepart cfi_probe gen_probe chipreg cfi_cmdset_0002(O) cfi_util mtd cache_ops(O)
[20170512182106]CPU: 2 PID: 1681 Comm: UMPTB.out Tainted: G        W  O
[20170512182106]Hardware name: Hisilicon A9
[20170512182106]task: c40692c0 ti: c309e000 task.ti: c309e000
[20170512182106]PC is at ptep_set_access_flags+0x0/0x88
[20170512182106]LR is at handle_mm_fault+0x10f0/0x130c
[20170512182106]pc : [<c0207ab4>]    lr : [<c01fc5a4>]    psr: 60000313
sp : c309fcd8  ip : 00000015  fp : 0000047b
[20170512182106]r10: eeef16e8  r9 : 00000001  r8 : c3b7a200
[20170512182106]r7 : daea475f  r6 : ef1cae70  r5 : 8f7ba000  r4 : edf44900
[20170512182106]r3 : daea475f  r2 : eeef16e8  r1 : 8f7ba000  r0 : edf44900
[20170512182106]Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
[20170512182106]Control: 1ac5387d  Table: ae82004a  DAC: 55555555
[20170512182106]CPU: 2 PID: 1681 Comm: UMPTB.out Tainted: G        W  O
[20170512182106]Hardware name: Hisilicon A9
[20170512182106][<c0110410>] (unwind_backtrace) from [<c010b640>] (show_stack+0x18/0x1c)
[20170512182106][<c010b640>] (show_stack) from [<c04a577c>] (dump_stack+0xa4/0xdc)
[20170512182106][<c04a577c>] (dump_stack) from [<c01a220c>] (watchdog_timer_fn+0x220/0x2fc)
[20170512182106][<c01a220c>] (watchdog_timer_fn) from [<c0172a2c>] (hrtimer_run_queues+0x1d0/0x3a8)
[20170512182106][<c0172a2c>] (hrtimer_run_queues) from [<c0171b58>] (run_local_timers+0x8/0x14)
[20170512182106][<c0171b58>] (run_local_timers) from [<c0171b8c>] (update_process_times+0x28/0x5c)
[20170512182106][<c0171b8c>] (update_process_times) from [<c017cfe8>] (tick_periodic+0xac/0xcc)
[20170512182106][<c017cfe8>] (tick_periodic) from [<c017d074>] (tick_handle_periodic+0x24/0x80)
[20170512182106][<c017d074>] (tick_handle_periodic) from [<c010f6f0>] (twd_handler+0x30/0x44)
[20170512182106][<c010f6f0>] (twd_handler) from [<c0165320>] (handle_percpu_devid_irq+0xb4/0x1b0)
[20170512182106][<c0165320>] (handle_percpu_devid_irq) from [<c01614ec>] (generic_handle_irq+0x20/0x30)
[20170512182106][<c01614ec>] (generic_handle_irq) from [<c016178c>] (__handle_domain_irq+0xd8/0x160)
[20170512182106][<c016178c>] (__handle_domain_irq) from [<c01013c0>] (gic_handle_irq+0x40/0x6c)
[20170512182106][<c01013c0>] (gic_handle_irq) from [<c04ab1e8>] (__irq_svc+0x48/0x60)
[20170512182106]Exception stack(0xc309fc90 to 0xc309fcd8)
[20170512182106]fc80:                                     edf44900 8f7ba000 eeef16e8 daea475f
[20170512182106]fca0: edf44900 8f7ba000 ef1cae70 daea475f c3b7a200 00000001 eeef16e8 0000047b
[20170512182106]fcc0: 00000015 c309fcd8 c01fc5a4 c0207ab4 60000313 ffffffff
[20170512182106][<c04ab1e8>] (__irq_svc) from [<c0207ab4>] (ptep_set_access_flags+0x0/0x88)
[20170512182106][<c0207ab4>] (ptep_set_access_flags) from [<ede20000>] (0xede20000)
[20170512182106]=====================SOFTLOCKUP INFO BEGIN=======================
[20170512182106]------------------CPU#2-----------------------------------
[20170512182106][CPU#2] the task [UMPTB.out] is not waiting for a lock,maybe a delay or deadcircle!
[20170512182106]UMPTB.out       R running      0  1681   1680 0x00000002
[20170512182106]locked:
[20170512182106]eee5db90   &f->f_pos_lock   2  [<c023eb58>] __fdget_pos+0x38/0x40	
[20170512182106]c3c50ab0   &p->lock         2  [<c02448c0>] seq_read+0x28/0x44c	
[20170512182106]c3b7a240   &mm->mmap_sem    2  [<c04ab910>] do_page_fault+0xc4/0x364	
[20170512182106][<c0110410>] (unwind_backtrace) from [<c010b640>] (show_stack+0x18/0x1c)
[20170512182106][<c010b640>] (show_stack) from [<c01a27f4>] (show_lock_info+0xd0/0x29c)
[20170512182106][<c01a27f4>] (show_lock_info) from [<c01a2240>] (watchdog_timer_fn+0x254/0x2fc)
[20170512182106][<c01a2240>] (watchdog_timer_fn) from [<c0172a2c>] (hrtimer_run_queues+0x1d0/0x3a8)
[20170512182106][<c0172a2c>] (hrtimer_run_queues) from [<c0171b58>] (run_local_timers+0x8/0x14)
[20170512182106][<c0171b58>] (run_local_timers) from [<c0171b8c>] (update_process_times+0x28/0x5c)
[20170512182106][<c0171b8c>] (update_process_times) from [<c017cfe8>] (tick_periodic+0xac/0xcc)
[20170512182106][<c017cfe8>] (tick_periodic) from [<c017d074>] (tick_handle_periodic+0x24/0x80)
[20170512182106][<c017d074>] (tick_handle_periodic) from [<c010f6f0>] (twd_handler+0x30/0x44)
[20170512182106][<c010f6f0>] (twd_handler) from [<c0165320>] (handle_percpu_devid_irq+0xb4/0x1b0)
[20170512182106][<c0165320>] (handle_percpu_devid_irq) from [<c01614ec>] (generic_handle_irq+0x20/0x30)
[20170512182106][<c01614ec>] (generic_handle_irq) from [<c016178c>] (__handle_domain_irq+0xd8/0x160)
[20170512182106][<c016178c>] (__handle_domain_irq) from [<c01013c0>] (gic_handle_irq+0x40/0x6c)
[20170512182106][<c01013c0>] (gic_handle_irq) from [<c04ab1e8>] (__irq_svc+0x48/0x60)
[20170512182106]Exception stack(0xc309fc90 to 0xc309fcd8)
[20170512182106]fc80:                                     edf44900 8f7ba000 eeef16e8 daea475f
[20170512182106]fca0: edf44900 8f7ba000 ef1cae70 daea475f c3b7a200 00000001 eeef16e8 0000047b
[20170512182106]fcc0: 00000015 c309fcd8 c01fc5a4 c0207ab4 60000313 ffffffff
[20170512182106][<c04ab1e8>] (__irq_svc) from [<c0207ab4>] (ptep_set_access_flags+0x0/0x88)
[20170512182106][<c0207ab4>] (ptep_set_access_flags) from [<ede20000>] (0xede20000)
[20170512182106]=====================SOFTLOCKUP INFO END=========================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
