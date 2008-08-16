Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7GNALcu007122
	for <linux-mm@kvack.org>; Sun, 17 Aug 2008 09:10:21 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7GNAjJt4694042
	for <linux-mm@kvack.org>; Sun, 17 Aug 2008 09:10:46 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7GNAjLL025508
	for <linux-mm@kvack.org>; Sun, 17 Aug 2008 09:10:45 +1000
Message-ID: <48A75E72.7050508@linux.vnet.ibm.com>
Date: Sun, 17 Aug 2008 04:40:42 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [BUG] linux-next: Tree for August 11/12 - powerpc - oops at __kmalloc_node_track_caller
 ()
References: <20080812185345.d7496513.sfr@canb.auug.org.au> <48A1C924.6020000@linux.vnet.ibm.com> <48A1D65A.8000600@linux-foundation.org>
In-Reply-To: <48A1D65A.8000600@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Reboot and switch on debugging by either specifying slub_debug as a kernel
> command line parameter or setting CONFIG_SLUB_DEBUG_ON. This looks like the
> freelists are corrupted. Could be a use after free or something.
> 
> 
Sorry for the delayed response, after passing the slub_debug as the command
line parameter while booting the kernel oops, the kernel faults with message

Kernel command line: root=/dev/sdb1 selinux=0 elevator=cfq slub_debug IDENT=1218735938 
.
.
<snip>
.
.
Unable to handle kernel paging request for data at address 0x6b6b6b6b6b6b6be3
Faulting instruction address: 0xc0000000002afb98
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=128 NUMA pSeries
Modules linked in:
NIP: c0000000002afb98 LR: c0000000002afb84 CTR: 0000000000000000
REGS: c00000077ccc7a80 TRAP: 0300   Not tainted  (2.6.27-rc2-next-20080812-autotest)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 84004044  XER: 00000000
DAR: 6b6b6b6b6b6b6be3, DSISR: 0000000040000000
TASK = c00000077cb9daa0[881] 'khvcd' THREAD: c00000077ccc4000 CPU: 2
GPR00: c0000000002afb84 c00000077ccc7d00 c000000000871068 c00000077cfd18d8 
GPR04: 0000000000000000 00000000000000f7 c0000000008bc448 0000000000000002 
GPR08: 0000000000000010 6b6b6b6b6b6b6b6b 0000000000000002 0000000000000000 
GPR12: 000000000000d032 c0000000008a4700 0000000000000000 c00000000063ad18 
GPR16: 4000000003a00000 c0000000006395b0 0000000000000000 00000000002b1000 
GPR20: 000000000411ff10 c00000000071ff10 0000000000000000 0000000000000001 
GPR24: 0000000000000000 0000000004500000 c0000000008b5920 c00000077ce78898 
GPR28: c00000077e0bf6d8 c00000077cfd18d8 c0000000007f7b00 c00000077cfd18f8 
NIP [c0000000002afb98] .tty_wakeup+0x40/0xa4
LR [c0000000002afb84] .tty_wakeup+0x2c/0xa4
Call Trace:
[c00000077ccc7d00] [c0000000002afb84] .tty_wakeup+0x2c/0xa4 (unreliable)
[c00000077ccc7d90] [c0000000002cd3a0] .hvc_poll+0x240/0x2d4
[c00000077ccc7e70] [c0000000002cd570] .khvcd+0x6c/0x184
[c00000077ccc7f00] [c000000000070450] .kthread+0x78/0xc4
[c00000077ccc7f90] [c000000000025854] .kernel_thread+0x4c/0x68
Instruction dump:
f8010010 f821ff71 60000000 e80300b0 7809dfe3 41820050 48008c81 60000000 
7c7f1b79 41820040 e93f0000 7fa3eb78 <e9290078> 2fa90000 419e0020 e8090000 
---[ end trace 839b2deb5e384ce9 ]---
BUG: soft lockup - CPU#0 stuck for 61s! [touch:3162]
Modules linked in:
NIP: c0000000004d86c4 LR: c000000000013dbc CTR: 0000000000000000
REGS: c00000077ca5fa70 TRAP: 0901   Tainted: G      D    (2.6.27-rc2-next-20080812-autotest)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24000484  XER: 20000000
TASK = c00000077e3e5aa0[3162] 'touch' THREAD: c00000077ca5c000 CPU: 0
GPR00: 0000020000000000 c00000077ca5fcf0 c000000000871068 0000000000000000 
GPR04: 00000000ff86e868 0000000000000000 0000000000000000 0000000000000002 
GPR08: 0000000000000000 0000000000000000 0000000000000200 0000000080000001 
GPR12: 000000000000f032 c0000000008a4300 
NIP [c0000000004d86c4] .lock_kernel+0x7c/0xb8
LR [c000000000013dbc] .compat_sys_sysctl+0xc4/0x1a8
Call Trace:
[c00000077ca5fcf0] [c00000077ca5fe30] 0xc00000077ca5fe30 (unreliable)
[c00000077ca5fd70] [c000000000013dbc] .compat_sys_sysctl+0xc4/0x1a8
[c00000077ca5fe30] [c0000000000086ac] syscall_exit+0x0/0x40
Instruction dump:
40a2fff0 4c00012c 2fab0000 41be003c 7c210b78 e92d0000 e8090008 78097fe1 
41820010 e87e8000 4bb5a70d 60000000 <e93e8000> 80090000 2fa00000 40beffd4 

The git-bisect points to 
git-bisect start
# good: [0967d61ea0d8e8a7826bd8949cd93dd1e829ac55] Linux 2.6.27-rc2
git-bisect good 0967d61ea0d8e8a7826bd8949cd93dd1e829ac55
# bad: [8a7363ad1b105ba8e979a1b00fada5cb6dbfc84e] Add linux-next specific files for 20080812
git-bisect bad 8a7363ad1b105ba8e979a1b00fada5cb6dbfc84e
# good: [771310c770214cd879d30d0825fb5e140cd74866] KVM: s390: Fix kvm on IBM System z10
git-bisect good 771310c770214cd879d30d0825fb5e140cd74866
# good: [4802ad47115e469f1dfe7a19086d9b14c059f5bc] Merge commit 'sh/master'
git-bisect good 4802ad47115e469f1dfe7a19086d9b14c059f5bc
# good: [cde62a78e433323f5b3bf0fbb42073209102edb4] Merge commit 'mtd/master'
git-bisect good cde62a78e433323f5b3bf0fbb42073209102edb4
# good: [c4e1eb40bc64f1127ae3d631702fa4f38aa6100c] Revert "UBIFS: add NFS support"
git-bisect good c4e1eb40bc64f1127ae3d631702fa4f38aa6100c
# good: [a59766bbf8b44caafc1c16539b90f77aed757765] Merge commit 'kmemcheck/auto-kmemcheck-next'
git-bisect good a59766bbf8b44caafc1c16539b90f77aed757765
# bad: [0806d59f07a0fb258ec92fcf236364a9424dc4bb] Merge branch 'quilt/ttydev'
git-bisect bad 0806d59f07a0fb258ec92fcf236364a9424dc4bb
# good: [da250c4bb64a4b3cec3b723ead8e9ebc3f9462af] Merge commit 'drm/drm-next'
git-bisect good da250c4bb64a4b3cec3b723ead8e9ebc3f9462af
# good: [3e0301ea47644782e0c0432b66fffd9da86323cc] tty-fix-pty-termios-race
git-bisect good 3e0301ea47644782e0c0432b66fffd9da86323cc
# bad: [618f77c709473bf8c57b2be76f2c728349da1749] tty-kref-stallion
git-bisect bad 618f77c709473bf8c57b2be76f2c728349da1749
# bad: [a2148160bbc82db03e874cca505a74de134df8ba] tty-move-write
git-bisect bad a2148160bbc82db03e874cca505a74de134df8ba
# bad: [b18540aa6f5cf3c12b14c3ab9a6cc4492a6eb930] tty-kref-modcount
git-bisect bad b18540aa6f5cf3c12b14c3ab9a6cc4492a6eb930
# bad: [d43a0b46168489882b40798bd1b2bb69ccdf5d99] tty-kref
git-bisect bad d43a0b46168489882b40798bd1b2bb69ccdf5d99

I was not able to reproduce this oops with next-20080813/14/15, hope some fixes have
gone into the next releases.

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
