Date: Wed, 23 Oct 2002 13:10:02 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.44-mm3: X doesn't work
Message-ID: <447940000.1035403802@flay>
In-Reply-To: <20021023205808.0449836a.diegocg@teleline.es>
References: <20021023205808.0449836a.diegocg@teleline.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arador <diegocg@teleline.es>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_SHAREPTE=y
CONFIG_PREEMPT=y

Want to try it again with the following?
1. CONFIG_SHPTE set, CONFIG_PREEMPT not set
2. CONFIG_SHPTE unset, CONFIG_PREEMPT set

Would be interesting to know which combinations of these two worked and
didn't. Search the last week's LKML archives for more details.

M.

--On Wednesday, October 23, 2002 20:58:08 +0200 Arador <diegocg@teleline.es> wrote:

> Xfree doesn't work. Config attached, preempt and shared pagetables enabled
> (EIP at pte_unshare sounds to a newbie like some shared pagetables issue so
>  i hope i've choosen the right mailing list ;)
> 
> I'll test(*) different CONFIG_* options if required
> X version 4.1. (Upgrading to 4.2.1 some day in this month, i expect :P)
> CPU: Cyrix 6x86MX 233+
> insmod tdfx (the drm driver) manually doesn't have this problem.
> 
> (*): I'll test only limited combinations, i need the 233 mhz. ;)
> 
> Oct 23 20:24:31 localhost kernel: Unable to handle kernel paging request at virtual address c3300000
> Oct 23 20:24:31 localhost kernel:  printing eip:
> Oct 23 20:24:31 localhost kernel: c0126075
> Oct 23 20:24:31 localhost kernel: *pde = 00000000
> Oct 23 20:24:31 localhost kernel: Oops: 0000
> Oct 23 20:24:31 localhost kernel: nls_iso8859-15 nls_cp850 vfat fat reiserfs ipt_LOG iptable_nat ip_conntrack iptable_filter ip_tables 
> Oct 23 20:24:31 localhost kernel: CPU:    0
> Oct 23 20:24:31 localhost kernel: EIP:    0060:[<c0126075>]    Not tainted
> Oct 23 20:24:31 localhost kernel: EFLAGS: 00013206
> Oct 23 20:24:31 localhost kernel: EIP is at pte_unshare+0x291/0x48c
> Oct 23 20:24:31 localhost kernel: eax: 00460000   ebx: e0000067   ecx: c3300000   edx: c1000000
> Oct 23 20:24:31 localhost kernel: esi: c1946668   edi: c0acc668   ebp: c1c22e40   esp: c0901eac
> Oct 23 20:24:32 localhost kernel: ds: 0068   es: 0068   ss: 0068
> Oct 23 20:24:32 localhost kernel: Process XFree86 (pid: 334, threadinfo=c0900000 task=c1e16cc0)
> Oct 23 20:24:32 localhost kernel: Stack: c0900000 c0a0d400 40012c0c c14ebce0 00040012 00000000 00000001 40400000
> Oct 23 20:24:32 localhost kernel:        40400000 4019a000 40000000 c103f2f0 c101afe0 c1946000 c0acc000 c012842c
> Oct 23 20:24:32 localhost kernel:        c14ebce0 c0a0d400 40012c0c c14ebce0 c1e16cc0 40012c0c c1c22720 c0111d87
> Oct 23 20:24:32 localhost kernel: Call Trace:
> Oct 23 20:24:32 localhost kernel:  [<c012842c>] handle_mm_fault+0xb0/0x1f0
> Oct 23 20:24:32 localhost kernel:  [<c0111d87>] do_page_fault+0x137/0x467
> Oct 23 20:24:32 localhost kernel:  [<c0111c50>] do_page_fault+0x0/0x467
> Oct 23 20:24:32 localhost kernel:  [<c0115978>] copy_process+0x860/0xa60
> Oct 23 20:24:32 localhost kernel:  [<c0115b9b>] do_fork+0x23/0xa8
> Oct 23 20:24:32 localhost kernel:  [<c0115bf2>] do_fork+0x7a/0xa8
> Oct 23 20:24:32 localhost kernel:  [<c0107ebd>] error_code+0x2d/0x40
> Oct 23 20:24:32 localhost kernel:
> Oct 23 20:24:32 localhost kernel: Code: 8b 01 a9 00 08 00 00 75 22 83 7c 24 14 00 74 0c 83 e3 fd 83
> Oct 23 20:24:32 localhost kernel:  <6>note: XFree86[334] exited with preempt_count 3
> Oct 23 20:24:32 localhost kernel: Debug: sleeping function called from illegal context at include/linux/rwsem.h:43
> Oct 23 20:24:32 localhost kernel: Call Trace:
> Oct 23 20:24:32 localhost kernel:  [<c0114535>] __might_sleep+0x55/0x60
> Oct 23 20:24:32 localhost kernel:  [<c0116da7>] profile_exit_task+0x17/0x48
> Oct 23 20:24:32 localhost kernel:  [<c0119daf>] do_exit+0x93/0x318
> Oct 23 20:24:32 localhost kernel:  [<c0108407>] die+0x77/0x78
> Oct 23 20:24:32 localhost kernel:  [<c0111f77>] do_page_fault+0x327/0x467
> Oct 23 20:24:32 localhost kernel:  [<c0111c50>] do_page_fault+0x0/0x467
> Oct 23 20:24:32 localhost kernel:  [<c015d0b8>] proc_alloc_inode+0x10/0x4c
> Oct 23 20:24:32 localhost kernel:  [<c015d0b8>] proc_alloc_inode+0x10/0x4c
> Oct 23 20:24:32 localhost kernel:  [<c0111744>] x86_profile_hook+0x1c/0x48
> Oct 23 20:24:32 localhost kernel:  [<c011099d>] smp_local_timer_interrupt+0xd/0xb0
> Oct 23 20:24:32 localhost kernel:  [<c01321cf>] buffered_rmqueue+0x113/0x120
> Oct 23 20:24:32 localhost kernel:  [<c0132496>] __alloc_pages+0x9e/0x250
> Oct 23 20:24:32 localhost kernel:  [<c0107ebd>] error_code+0x2d/0x40
> Oct 23 20:24:32 localhost kernel:  [<c0126075>] pte_unshare+0x291/0x48c
> Oct 23 20:24:32 localhost kernel:  [<c012842c>] handle_mm_fault+0xb0/0x1f0
> Oct 23 20:24:32 localhost kernel:  [<c0111d87>] do_page_fault+0x137/0x467
> Oct 23 20:24:32 localhost kernel:  [<c0111c50>] do_page_fault+0x0/0x467
> Oct 23 20:24:32 localhost kernel:  [<c0115978>] copy_process+0x860/0xa60
> Oct 23 20:24:32 localhost kernel:  [<c0115b9b>] do_fork+0x23/0xa8
> Oct 23 20:24:32 localhost kernel:  [<c0115bf2>] do_fork+0x7a/0xa8
> Oct 23 20:24:32 localhost kernel:  [<c0107ebd>] error_code+0x2d/0x40
> Oct 23 20:24:32 localhost kernel:
> Oct 23 20:24:32 localhost kernel: [drm] Initialized tdfx 1.0.0 20010216 on minor 0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
