Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4296B0253
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 04:27:58 -0500 (EST)
Received: by wmnn186 with SMTP id n186so61606010wmn.0
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 01:27:58 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id lh8si31471060wjb.110.2015.12.12.01.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Dec 2015 01:27:56 -0800 (PST)
Received: by wmpp66 with SMTP id p66so2147830wmp.1
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 01:27:56 -0800 (PST)
Subject: Re: [RFC] REHL 7.1: soft lockup when flush tlb
References: <566BE050.3000804@huawei.com>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <566BE89A.1070200@kyup.com>
Date: Sat, 12 Dec 2015 11:27:54 +0200
MIME-Version: 1.0
In-Reply-To: <566BE050.3000804@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>



On 12/12/2015 10:52 AM, Xishi Qiu wrote:
> [60050.458309] kjournald starting.  Commit interval 5 seconds
> [60076.821224] EXT3-fs (sda1): using internal journal
> [60098.811865] EXT3-fs (sda1): mounted filesystem with ordered data mode
> [60138.687054] kjournald starting.  Commit interval 5 seconds
> [60143.888627] EXT3-fs (sda1): using internal journal
> [60143.888631] EXT3-fs (sda1): mounted filesystem with ordered data mode
> [60164.075002] BUG: soft lockup - CPU#1 stuck for 22s! [mount:3883]
> [60164.075002] Modules linked in: loop binfmt_misc rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd sunrpc fscache hmem_driver(OF) kbox(OF) cirrus syscopyarea sysfillrect sysimgblt ttm drm_kms_helper drm ppdev parport_pc parport i2c_piix4 i2c_core virtio_balloon floppy serio_raw pcspkr ext3 mbcache jbd sd_mod sr_mod crc_t10dif cdrom crct10dif_common ata_generic pata_acpi virtio_scsi virtio_console ata_piix virtio_pci libata e1000 virtio_ring virtio [last unloaded: kernel_allocpage]
> [60164.075002] CPU: 1 PID: 3883 Comm: mount Tainted: GF       W  O --------------   3.10.0-229.20.1.23.x86_64 #1
> [60164.075002] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
> [60164.075002] task: ffff88061d850b60 ti: ffff88061c500000 task.ti: ffff88061c500000
> [60164.075002] RIP: 0010:[<ffffffff810d7a4a>]  [<ffffffff810d7a4a>] generic_exec_single+0xfa/0x1a0
> [60164.075002] RSP: 0018:ffff88061c503c50  EFLAGS: 00000202
> [60164.075002] RAX: 0000000000000004 RBX: ffff88061c503c20 RCX: 000000000000003c
> [60164.075002] RDX: 000000000000000f RSI: 0000000000000004 RDI: 0000000000000282
> [60164.075002] RBP: ffff88061c503c98 R08: ffffffff81631120 R09: 00000000000169e0
> [60164.075002] R10: ffff88063ffc5000 R11: 0000000000000000 R12: 0000000000000000
> [60164.075002] R13: ffff88063ffc5000 R14: ffff88061c503c20 R15: 0000000200000000
> [60164.075002] FS:  0000000000000000(0000) GS:ffff88063fc80000(0000) knlGS:0000000000000000
> [60164.075002] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [60164.075002] CR2: 00007fab0c4a0c40 CR3: 000000000190a000 CR4: 00000000000006e0
> [60164.075002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [60164.075002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [60164.075002] Stack:
> [60164.075002]  0000000000000000 0000000000000000 ffffffff8105fab0 ffff88061c503d20
> [60164.075002]  0000000000000003 000000009383884f 0000000000000002 ffffffff8105fab0
> [60164.075002]  ffffffff8105fab0 ffff88061c503cc8 ffffffff810d7b4f ffff88061c503cc8
> [60164.075002] Call Trace:
> [60164.075002]  [<ffffffff8105fab0>] ? leave_mm+0x70/0x70
> [60164.075002]  [<ffffffff8105fab0>] ? leave_mm+0x70/0x70
> [60164.075002]  [<ffffffff8105fab0>] ? leave_mm+0x70/0x70
> [60164.075002]  [<ffffffff810d7b4f>] smp_call_function_single+0x5f/0xa0
> [60164.075002]  [<ffffffff812d5c15>] ? cpumask_next_and+0x35/0x50
> [60164.075002]  [<ffffffff810d80e3>] smp_call_function_many+0x223/0x260
> [60164.075002]  [<ffffffff8105fc78>] native_flush_tlb_others+0xb8/0xc0
> [60164.075002]  [<ffffffff8105fd3c>] flush_tlb_mm_range+0x5c/0x180
> [60164.075002]  [<ffffffff8117f503>] tlb_flush_mmu.part.53+0x83/0x90
> [60164.075002]  [<ffffffff81180015>] tlb_finish_mmu+0x55/0x60
> [60164.075002]  [<ffffffff8118b0bb>] exit_mmap+0xdb/0x1a0
> [60164.075002]  [<ffffffff8106b487>] mmput+0x67/0xf0
> [60164.075002]  [<ffffffff8107458c>] do_exit+0x28c/0xa60
> [60164.075002]  [<ffffffff816100c3>] ? trace_do_page_fault+0x43/0x100
> [60164.075002]  [<ffffffff81074ddf>] do_group_exit+0x3f/0xa0
> [60164.075002]  [<ffffffff81074e54>] SyS_exit_group+0x14/0x20
> [60164.075002]  [<ffffffff816147c9>] system_call_fastpath+0x16/0x1b
> 

This stack trace is not sufficient to show what root cause of the lockup
is. More often than not what happens is that some other core (the
offending one) is stuck with interrupts disabled, and that's why the ipi
resulting from native_flush_tlb_others is getting stuck. So you need to
see which core failed at handling the IPI.


> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
