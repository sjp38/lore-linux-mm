Subject: 2.5.44-mm2 CONFIG_SHAREPTE necessary for starting KDE 3.0.3
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 11:01:48 -0600
Message-Id: <1035306108.13078.178.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Greetings all,

My experience with 2.5.44-mm2 and KDE 3 runs counter to the experience
of some others.  I've booted several kernels this morning on my UP test
box and found that starting KDE 3.0.3 using XFree86 4.2.1 _requires_
that CONFIG_SHAREPTE=y for my system.  All kernels were UP and PREEMPT.
With CONFIG_X86_UP_IOAPIC=y and nmi_watchdog=1, the results were the
same.

If SHAREPTE is not set, then the KDE startup fails with a frozen pointer
after the initial dark blue screen changes to black.  This does appear
to be KDE-related.  When Gnome is my default desktop, that works just
fine with 2.5.44-mm2 and CONFIG_SHAREPTE not set.

Here is a snippet from /var/log/messages.  At 09:31:23, I did a
alt-sysrq-P.  I also did a alt-sysrq-T right after that and that
information is available if needed.

Oct 22 09:31:09 spc1 kernel: Unable to handle kernel paging request at virtual address 08180058
Oct 22 09:31:09 spc1 kernel:  printing eip:
Oct 22 09:31:09 spc1 kernel: 08180058
Oct 22 09:31:09 spc1 kernel: *pde = 0e637067
Oct 22 09:31:09 spc1 kernel: *pte = 00000000
Oct 22 09:31:09 spc1 kernel: Oops: 0004
Oct 22 09:31:09 spc1 kernel: CPU:    0
Oct 22 09:31:09 spc1 kernel: EIP:    0023:[<08180058>]    Not tainted
Oct 22 09:31:09 spc1 kernel: EFLAGS: 00013206
Oct 22 09:31:09 spc1 kernel: eax: 00000000   ebx: 00000000   ecx: 0868fd08   edx: 085b0c60
Oct 22 09:31:09 spc1 kernel: esi: 0868fd08   edi: bffff620   ebp: bffff608   esp: bffff5d0
Oct 22 09:31:09 spc1 kernel: ds: 002b   es: 002b   ss: 002b
Oct 22 09:31:09 spc1 kernel: Process X (pid: 1826, threadinfo=cd296000 task=ccfb1360)
Oct 22 09:31:09 spc1 kernel:  <6>note: X[1826] exited with preempt_count 2
Oct 22 09:31:21 spc1 kernel: SysRq : HELP : loglevel0-8 reBoot tErm kIll saK showMem showPc unRaw Sync showTasks Unmount 
Oct 22 09:31:23 spc1 kernel: SysRq : Show Regs
Oct 22 09:31:23 spc1 kernel: 
Oct 22 09:31:23 spc1 kernel: Pid: 0, comm:              swapper
Oct 22 09:31:23 spc1 kernel: EIP: 0060:[<c0105364>] CPU: 0
Oct 22 09:31:23 spc1 kernel: EIP is at default_idle+0x24/0x30
Oct 22 09:31:23 spc1 kernel:  EFLAGS: 00000246    Not tainted
Oct 22 09:31:23 spc1 kernel: EAX: 00000000 EBX: c0105340 ECX: ffffffff EDX: c040a000
Oct 22 09:31:23 spc1 kernel: ESI: c040a000 EDI: c0105340 EBP: 0008e000 DS: 0068 ES: 0068
Oct 22 09:31:23 spc1 kernel: CR0: 8005003b CR2: 41210ca4 CR3: 0ee09000 CR4: 000006d0
Oct 22 09:31:23 spc1 kernel: Call Trace:
Oct 22 09:31:23 spc1 kernel:  [<c01053e2>] cpu_idle+0x32/0x50
Oct 22 09:31:23 spc1 kernel:  [<c0105000>] stext+0x0/0x50
Oct 22 09:31:23 spc1 kernel:

I can provide the results of grep ^CONFIG .config if needed.

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
