Received: by rn-out-0910.google.com with SMTP id j71so1828497rne.4
        for <linux-mm@kvack.org>; Sat, 01 Nov 2008 07:23:49 -0700 (PDT)
Message-ID: <a4423d670811010723u3b271fcaxa7d3bdb251a8b246@mail.gmail.com>
Date: Sat, 1 Nov 2008 17:23:49 +0300
From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: 2.6.28-rc2: Unable to handle kernel paging request at iov_iter_copy_from_user_atomic
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

How to reproduce: run dbench on tmpfs


Unable to handle kernel paging request at virtual address fffff80037c1c000
tsk->{mm,active_mm}->context = 0000000000001ae7
tsk->{mm,active_mm}->pgd = fffff8000ec8c000
              \|/ ____ \|/
              "@'/ .. \`@"
              /_| \__/ |_\
                 \__U_/
dbench(5007): Oops [#1]
TSTATE: 0000000011009604 TPC: 00000000005acbac TNPC: 00000000005acbb0
Y: 00000000    Not tainted
TPC: <__bzero+0x20/0xc0>
g0: 0000000000000016 g1: 0000000000000000 g2: 0000000000000000 g3:
0000000000033ae7
g4: fffff8000ec9c380 g5: 0000000000000020 g6: fffff8003b834000 g7:
ffffffffffffe8b1
o0: fffff80037c1c8b1 o1: 00000000000008b1 o2: 0000000000000000 o3:
fffff80037c1c8b1
o4: 0000000000000000 o5: 0000000000034398 sp: fffff8003b836e41 ret_pc:
00000000005ae73c
RPC: <copy_from_user_fixup+0x4c/0x70>
l0: 0000000000852800 l1: 0000000011009603 l2: 0000000000827ff4 l3:
0000000000000400
l4: 0000000000000000 l5: 0000000000000001 l6: 0000000000000000 l7:
0000000000000008
i0: fffff80037c1e000 i1: 0000000000032398 i2: 00000000000008b1 i3:
fffff80037c3e398
i4: fffff80037c1e000 i5: 0000000000000000 i6: fffff8003b836f01 i7:
0000000000486f28
I7: <iov_iter_copy_from_user_atomic+0x90/0xe0>
Caller[0000000000486f28]: iov_iter_copy_from_user_atomic+0x90/0xe0
Caller[0000000000488a58]: generic_file_buffered_write+0x108/0x2a8
Caller[0000000000489140]: __generic_file_aio_write_nolock+0x35c/0x380
Caller[00000000004899b4]: generic_file_aio_write+0x58/0xc8
Caller[00000000004b23d4]: do_sync_write+0x90/0xe0
Caller[00000000004b2ca4]: vfs_write+0x7c/0x11c
Caller[00000000004b2d98]: sys_pwrite64+0x54/0x80
Caller[000000000043efa4]: sys32_pwrite64+0x20/0x34
Caller[0000000000406154]: linux_sparc_syscall32+0x34/0x40
Caller[00000000f7e8df80]: 0xf7e8df80
Instruction DUMP: c56a2000  808a2003  02480006 <d42a2000> 90022001
808a2003  1247fffd  92226001  808a2007
note: dbench[5007] exited with preempt_count 2
BUG: sleeping function called from invalid context at kernel/rwsem.c:21
in_atomic(): 1, irqs_disabled(): 0, pid: 5007, name: dbench
INFO: lockdep is turned off.
Call Trace:
 [000000000044b79c] __might_sleep+0x104/0x114
 [00000000006d81b4] down_read+0x18/0x50
 [0000000000451b08] exit_mm+0x28/0x128
 [000000000045359c] do_exit+0x1c4/0x7a4
 [0000000000429044] die_if_kernel+0x270/0x29c
 [00000000006da6d0] unhandled_fault+0x90/0x9c
 [00000000006dac38] do_sparc64_fault+0x55c/0x64c
 [0000000000407854] sparc64_realfault_common+0x10/0x20
 [00000000005acbac] __bzero+0x20/0xc0
 [0000000000486f28] iov_iter_copy_from_user_atomic+0x90/0xe0
 [0000000000488a58] generic_file_buffered_write+0x108/0x2a8
 [0000000000489140] __generic_file_aio_write_nolock+0x35c/0x380
 [00000000004899b4] generic_file_aio_write+0x58/0xc8
 [00000000004b23d4] do_sync_write+0x90/0xe0
 [00000000004b2ca4] vfs_write+0x7c/0x11c
 [00000000004b2d98] sys_pwrite64+0x54/0x80
BUG: scheduling while atomic: dbench/5007/0x04000003
INFO: lockdep is turned off.
Modules linked in:
Call Trace:
 [000000000044cc2c] __schedule_bug+0x6c/0x7c
 [00000000006d66b8] schedule+0xa0/0x484
 [000000000044d6d8] __cond_resched+0x2c/0x54
 [00000000006d6c80] _cond_resched+0x40/0x60
 [0000000000498c88] unmap_vmas+0x53c/0x644
 [000000000049d0f4] exit_mmap+0xc4/0x1b4
 [000000000044e24c] mmput+0x40/0xc4
 [0000000000451bf8] exit_mm+0x118/0x128
 [000000000045359c] do_exit+0x1c4/0x7a4
 [0000000000429044] die_if_kernel+0x270/0x29c
 [00000000006da6d0] unhandled_fault+0x90/0x9c
 [00000000006dac38] do_sparc64_fault+0x55c/0x64c
 [0000000000407854] sparc64_realfault_common+0x10/0x20
 [00000000005acbac] __bzero+0x20/0xc0
 [0000000000486f28] iov_iter_copy_from_user_atomic+0x90/0xe0
 [0000000000488a58] generic_file_buffered_write+0x108/0x2a8
BUG: scheduling while atomic: dbench/5007/0x04000003
INFO: lockdep is turned off.
Modules linked in:
Call Trace:
 [000000000044cc2c] __schedule_bug+0x6c/0x7c
 [00000000006d66b8] schedule+0xa0/0x484
 [000000000044d6d8] __cond_resched+0x2c/0x54
 [00000000006d6c80] _cond_resched+0x40/0x60
 [0000000000451ec4] put_files_struct+0xa8/0x104
 [0000000000451f50] exit_files+0x30/0x40
 [00000000004535ac] do_exit+0x1d4/0x7a4
 [0000000000429044] die_if_kernel+0x270/0x29c
 [00000000006da6d0] unhandled_fault+0x90/0x9c
 [00000000006dac38] do_sparc64_fault+0x55c/0x64c
 [0000000000407854] sparc64_realfault_common+0x10/0x20
 [00000000005acbac] __bzero+0x20/0xc0
 [0000000000486f28] iov_iter_copy_from_user_atomic+0x90/0xe0
 [0000000000488a58] generic_file_buffered_write+0x108/0x2a8
 [0000000000489140] __generic_file_aio_write_nolock+0x35c/0x380
 [00000000004899b4] generic_file_aio_write+0x58/0xc8
Unable to handle kernel paging request at virtual address fffff8003632a000
tsk->{mm,active_mm}->context = 0000000000001af9
tsk->{mm,active_mm}->pgd = fffff8000eca2000
              \|/ ____ \|/
              "@'/ .. \`@"
              /_| \__/ |_\
                 \__U_/
dbench(5025): Oops [#2]
TSTATE: 0000000011009604 TPC: 00000000005acbac TNPC: 00000000005acbb0
Y: 00000000    Tainted: G      D
TPC: <__bzero+0x20/0xc0>
g0: 0000000000000000 g1: 0000000000000000 g2: 0000000000000000 g3:
0000000000031af9
g4: fffff8000ed86c00 g5: 0000000000000020 g6: fffff8003b6c8000 g7:
ffffffffffffe897
o0: fffff8003632a897 o1: 0000000000000897 o2: 0000000000000000 o3:
fffff8003632a897
o4: 0000000000000000 o5: 0000000000032390 sp: fffff8003b6cae41 ret_pc:
00000000005ae73c
RPC: <copy_from_user_fixup+0x4c/0x70>
l0: 0000000000852800 l1: 0000000011009603 l2: 0000000000827ff4 l3:
0000000000000400
l4: 0000000000000000 l5: 0000000000000001 l6: 0000000000000000 l7:
0000000000000008
i0: fffff8003632c000 i1: 0000000000030390 i2: 0000000000000897 i3:
fffff8003633c390
i4: fffff8003632c000 i5: 0000000000000000 i6: fffff8003b6caf01 i7:
0000000000486f28
I7: <iov_iter_copy_from_user_atomic+0x90/0xe0>

and so on..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
