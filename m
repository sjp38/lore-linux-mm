Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id AE9416B0032
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 23:03:12 -0400 (EDT)
Received: by obctg8 with SMTP id tg8so18666757obc.3
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 20:03:12 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id p132si16329045oig.125.2015.06.23.20.03.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Jun 2015 20:03:11 -0700 (PDT)
Message-ID: <558A1D20.10309@huawei.com>
Date: Wed, 24 Jun 2015 10:59:44 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: mm/pcp: NULL pointer access at free_pcppages_bulk()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiexiuqi <xiexiuqi@huawei.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Does someone have seen the call trace?

Linux version 3.0.101-0.46-default (geeko@buildhost) (gcc version 4.3.4 [gcc-4_3-branch revision 152973] (SUSE Linux) ) #1 SMP Wed Dec 17 11:04:10 UTC 2014 (8356111)
Command line: root=/dev/rootvg/rootlv resume=/dev/rootvg/swaplv splash=silent crashkernel=512M vga=0x31a

<1>[7241687.198999] BUG: unable to handle kernel NULL pointer dereference at           (null)
<1>[7241687.199013] IP: [<ffffffff81103698>] free_pcppages_bulk+0xd8/0x430
<4>[7241687.199026] PGD 0 
<0>[7241687.199029] Oops: 0002 [#1] SMP 
<4>[7241687.199036] CPU 6 
<4>[7241687.199037] Modules linked in: mmfs26(EX) mmfslinux(EX) tracedev(EX) raw binfmt_misc edd dm_service_time dm_multipath bonding rdma_ucm rdma_cm iw_cm ib_addr ib_srp scsi_transport_srp ib_ipoib ib_cm ib_uverbs ib_umad iw_cxgb3 cxgb3 mdio ib_mthca mperf fuse loop mlx4_ib mlx4_en ib_sa ib_mad ib_core ipv6 ipv6_lib i2c_i801 pcspkr igb mei dca ptp pps_core i2c_core mlx4_core joydev sr_mod cdrom wmi sg acpi_memhotplug rtc_cmos button container ext3 jbd mbcache usbhid hid dm_mirror dm_region_hash dm_log linear ehci_hcd usbcore sd_mod usb_common crc_t10dif processor thermal_sys hwmon scsi_dh_emc scsi_dh_rdac scsi_dh_hp_sw scsi_dh_alua scsi_dh dm_snapshot dm_mod ahci libahci libata lpfc scsi_transport_fc scsi_tgt megaraid_sas scsi_mod
<4>[7241687.199112] Supported: Yes, External
<4>[7241687.199114] 
<4>[7241687.199118] Pid: 181, comm: kworker/6:1 Tainted: G           E X 3.0.101-0.46-default #1 To be filled by O.E.M. Tecal RH5885 V3/BC61BLCA
<4>[7241687.199124] RIP: 0010:[<ffffffff81103698>]  [<ffffffff81103698>] free_pcppages_bulk+0xd8/0x430
<4>[7241687.199130] RSP: 0018:ffff881fc2025cd0  EFLAGS: 00010097
<4>[7241687.199133] RAX: 0000000000000000 RBX: ffffea01a1081d48 RCX: ffff88207fb13aa8
<4>[7241687.199136] RDX: ffff88207fb13aa0 RSI: ffffea0194c14160 RDI: 0000000000000000
<4>[7241687.199139] RBP: ffffea01a1081d20 R08: 0000000000000000 R09: 0000000000000000
<4>[7241687.199142] R10: ffffea0194c14138 R11: ffff88807ff97f80 R12: 0000000000000001
<4>[7241687.199146] R13: ffff88807ff97f80 R14: 0000000000000002 R15: 0000000000000002
<4>[7241687.199149] FS:  0000000000000000(0000) GS:ffff88207fb00000(0000) knlGS:0000000000000000
<4>[7241687.199153] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
<4>[7241687.199156] CR2: 0000000000000000 CR3: 0000000001a09000 CR4: 00000000001407e0
<4>[7241687.199159] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[7241687.199163] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[7241687.199166] Process kworker/6:1 (pid: 181, threadinfo ffff881fc2024000, task ffff881fc2022500)
<0>[7241687.199170] Stack:
<4>[7241687.199172]  ffffffff810095d5 ffff88207fb13aa8 0000000000000030 ffff88807ff97fe0
<4>[7241687.199189]  ffff88207fb13a70 000000090000001f ffff88207fb13aa0 ffff88207fb13a70
<4>[7241687.199196]  000000000000001f 0000000000000282 0000000000000006 ffff88207fb13e05
<0>[7241687.199202] Call Trace:
<4>[7241687.199215]  [<ffffffff8110472f>] drain_zone_pages+0x3f/0x60
<4>[7241687.199225]  [<ffffffff81119808>] refresh_cpu_vm_stats+0x138/0x150
<4>[7241687.199233]  [<ffffffff81119831>] vmstat_update+0x11/0x40
<4>[7241687.199241]  [<ffffffff8107cf7c>] process_one_work+0x16c/0x350
<4>[7241687.199248]  [<ffffffff8107fbaa>] worker_thread+0x17a/0x410
<4>[7241687.199255]  [<ffffffff81083f16>] kthread+0x96/0xa0
<4>[7241687.199264]  [<ffffffff8146d964>] kernel_thread_helper+0x4/0x10
<0>[7241687.199270] Code: 08 48 89 44 24 10 48 89 4c 24 08 0f 1f 84 00 00 00 00 00 48 8b 4c 24 08 48 8b 19 48 8d 6b d8 48 8b 45 30 48 8b 55 28 48 89 42 08 
<48>[7241687.199289]  89 10 48 b8 00 01 10 00 00 00 ad de 48 89 45 28 48 b8 00 02 
<1>[7241687.199300] RIP  [<ffffffff81103698>] free_pcppages_bulk+0xd8/0x430
<4>[7241687.199305]  RSP <ffff881fc2025cd0>
<0>[7241687.199307] CR2: 0000000000000000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
