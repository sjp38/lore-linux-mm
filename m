Received: by rv-out-0910.google.com with SMTP id f1so4531905rvb.26
        for <linux-mm@kvack.org>; Mon, 03 Mar 2008 03:51:19 -0800 (PST)
Message-ID: <84144f020803030351l2042e9aaqe656ad1610e5efc5@mail.gmail.com>
Date: Mon, 3 Mar 2008 13:51:19 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [BUG] Linux 2.6.25-rc2 - Kernel Ooops while running dbench
In-Reply-To: <20080218045954.50503fb1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.LFD.1.00.0802151302210.9496@woody.linux-foundation.org>
	 <47B6784E.2090401@linux.vnet.ibm.com>
	 <20080218045954.50503fb1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Feb 2008 11:14:46 +0530 Kamalesh Babulal
<kamalesh@linux.vnet.ibm.com> wrote:
>  > The 2.6.25-rc2 kernel oopses while running dbench on ext3 filesystem
>  > mounted with mount -o data=writeback,nobh option on the x86_64 box
>  >
>  > BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
>  > IP: [<ffffffff80274972>] kmem_cache_alloc+0x3a/0x6c
>  > PGD 1f6860067 PUD 1f5d64067 PMD 0
>  > Oops: 0000 [1] SMP
>  > CPU 3
>  > Modules linked in:
>  > Pid: 4271, comm: dbench Not tainted 2.6.25-rc2-autotest #1
>  > RIP: 0010:[<ffffffff80274972>]  [<ffffffff80274972>] kmem_cache_alloc+0x3a/0x6c
>  > RSP: 0000:ffff8101fb041dc8  EFLAGS: 00010246
>  > RAX: 0000000000000000 RBX: ffff810180033c00 RCX: ffffffff8027b269
>  > RDX: 0000000000000000 RSI: 00000000000080d0 RDI: ffffffff80632d70
>  > RBP: 00000000000080d0 R08: 0000000000000001 R09: 0000000000000000
>  > R10: ffff8101feb36e50 R11: 0000000000000190 R12: 0000000000000001
>  > R13: 0000000000000000 R14: ffff8101f8f38000 R15: 00000000ffffff9c
>  > FS:  0000000000000000(0000) GS:ffff8101fff0f000(0063) knlGS:00000000f7e41460
>  > CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
>  > CR2: 0000000000000000 CR3: 00000001f5620000 CR4: 00000000000006e0
>  > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>  > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>  > Process dbench (pid: 4271, threadinfo ffff8101fb040000, task ffff8101fb180000)
>  > Stack:  0000000000000001 ffff8101fb041ea8 0000000000000001 ffffffff8027b269
>  >  ffff8101fb041ea8 ffffffff80281fe8 0000000000000001 0000000000000000
>  >  ffff8101fb041ea8 00000000ffffff9c 000000000000000b 0000000000000001
>  > Call Trace:
>  >  [<ffffffff8027b269>] get_empty_filp+0x55/0xf9
>  >  [<ffffffff80281fe8>] __path_lookup_intent_open+0x22/0x8f
>  >  [<ffffffff80282853>] open_namei+0x86/0x5a7
>  >  [<ffffffff8027d019>] vfs_stat_fd+0x3c/0x4a
>  >  [<ffffffff80279ab1>] do_filp_open+0x1c/0x3d
>  >  [<ffffffff80279c2c>] get_unused_fd_flags+0x79/0x111
>  >  [<ffffffff80279dce>] do_sys_open+0x46/0xca
>  >  [<ffffffff80221c82>] ia32_sysret+0x0/0xa

On Mon, Feb 18, 2008 at 2:59 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>  Looks to me like we broke slab.  Christoph is offline until the 27th..

This is probably fixed by:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=00e962c5408b9f2d0bebd2308673fe982cb9a5fe

As this is on the regression list, Kamalesh, can you please confirm
it's fixed now?

                             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
