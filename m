Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id B1D4B6B0068
	for <linux-mm@kvack.org>; Tue, 29 May 2012 09:35:06 -0400 (EDT)
Date: Tue, 29 May 2012 16:36:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/35] AutoNUMA alpha14
Message-ID: <20120529133627.GA7637@shutemov.name>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

<2>[  729.065896] kernel BUG at /home/kas/git/public/linux/mm/autonuma.c:850!
<4>[  729.176966] invalid opcode: 0000 [#1] SMP 
<4>[  729.287517] CPU 24 
<4>[  729.397025] Modules linked in: sunrpc bnep bluetooth rfkill cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack coretemp kvm asix usbnet igb i7core_edac crc32c_intel iTCO_wdt i2c_i801 ioatdma pcspkr tpm_tis microcode joydev mii i2c_core iTCO_vendor_support tpm edac_core dca ptp tpm_bios pps_core megaraid_sas [last unloaded: scsi_wait_scan]
<4>[  729.870867] 
<4>[  729.989848] Pid: 342, comm: knuma_migrated0 Not tainted 3.4.0+ #32 QCI QSSC-S4R/QSSC-S4R
<4>[  730.111497] RIP: 0010:[<ffffffff8117baf5>]  [<ffffffff8117baf5>] knuma_migrated+0x915/0xa50
<4>[  730.234615] RSP: 0018:ffff88026c8b7d40  EFLAGS: 00010006
<4>[  730.357993] RAX: 0000000000000000 RBX: ffff88027ffea000 RCX: 0000000000000002
<4>[  730.482959] RDX: 0000000000000002 RSI: ffffea0017b7001c RDI: ffffea0017b70000
<4>[  730.607709] RBP: ffff88026c8b7e90 R08: 0000000000000001 R09: 0000000000000000
<4>[  730.733082] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000002
<4>[  730.858424] R13: 0000000000000200 R14: ffffea0017b70000 R15: ffff88067ffeae00
<4>[  730.983686] FS:  0000000000000000(0000) GS:ffff880272200000(0000) knlGS:0000000000000000
<4>[  731.110169] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
<4>[  731.236396] CR2: 00007ff3463dd000 CR3: 0000000001c0b000 CR4: 00000000000007e0
<4>[  731.363987] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[  731.490875] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[  731.616769] Process knuma_migrated0 (pid: 342, threadinfo ffff88026c8b6000, task ffff88026c8ac5a0)
<4>[  731.745286] Stack:
<4>[  731.871079]  ffff88027fffdef0 ffff88026c8ac5a0 0000000000000082 ffff88026c8ac5a0
<4>[  731.999154]  ffff88026c8b7d98 0000000100000003 ffffea000f165e60 ffff88067ffeb2c0
<4>[  732.126565]  ffffea000f165e60 ffffea000f165e20 ffffffff8107df90 ffff88026c8b7d98
<4>[  732.253488] Call Trace:
<4>[  732.377354]  [<ffffffff8107df90>] ? __init_waitqueue_head+0x60/0x60
<4>[  732.501250]  [<ffffffff8107e075>] ? finish_wait+0x45/0x90
<4>[  732.623816]  [<ffffffff8117b1e0>] ? __autonuma_migrate_page_remove+0x130/0x130
<4>[  732.748194]  [<ffffffff8107d437>] kthread+0xb7/0xc0
<4>[  732.872468]  [<ffffffff81668324>] kernel_thread_helper+0x4/0x10
<4>[  732.997588]  [<ffffffff8107d380>] ? __init_kthread_worker+0x70/0x70
<4>[  733.120411]  [<ffffffff81668320>] ? gs_change+0x13/0x13
<4>[  733.240230] Code: 4e 00 48 8b 05 6d 05 b8 00 a8 04 0f 84 b5 f9 ff ff 48 c7 c7 b0 c9 9e 81 31 c0 e8 04 6c 4d 00 e9 a2 f9 ff ff 66 90 e8 8a 87 4d 00 <0f> 0b 48 c7 c7 d0 c9 9e 81 31 c0 e8 e8 6b 4d 00 e9 73 f9 ff ff 
<1>[  733.489612] RIP  [<ffffffff8117baf5>] knuma_migrated+0x915/0xa50
<4>[  733.614281]  RSP <ffff88026c8b7d40>
<4>[  733.736855] ---[ end trace 25052e4d75b2f1f6 ]---

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
