Date: Tue, 12 Apr 2005 17:38:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4479] New: kernel BUG at mm/memory.c:1001!
Message-Id: <20050412173840.7a9f4fad.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: nf@ncc.up.pt
List-ID: <linux-mm.kvack.org>


Begin forwarded message:

Date: Tue, 12 Apr 2005 17:17:47 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4479] New: kernel BUG at mm/memory.c:1001!


http://bugme.osdl.org/show_bug.cgi?id=4479

           Summary: kernel BUG at mm/memory.c:1001!
    Kernel Version: 2.6.11.6 SMP
            Status: NEW
          Severity: high
             Owner: mm_numa-discontigmem@kernel-bugs.osdl.org
         Submitter: nf@ncc.up.pt


kernel BUG at mm/memory.c:1001!
invalid operand: 0000 [#1]
SMP
Modules linked in: w83781d eeprom i2c_sensor i2c_isa nfs lockd autofs4 sunrpc
dm_mod md5 ipv6 i2c_amd756 i2c_core dl2k floppy ext3 jbd
CPU:    1
EIP:    0060:[<c0149c5a>]    Not tainted VLI
EFLAGS: 00010206   (2.6.11.6nf1)
EIP is at zeromap_pte_range+0x5a/0x70
eax: 10000000   ebx: d81ccd48   ecx: 00352000   edx: e64e2001
esi: 003cd025   edi: 00360000   ebp: e6bc80cc   esp: e64e2ebc
ds: 007b   es: 007b   ss: 0068
Process yap (pid: 19935, threadinfo=e64e2000 task=f6cc7020)
Stack: d81ccd40 00350000 0cb50000 c0149dee d81ccd40 0cb50000 00010000 00000025
       f6cc967c 00360000 0c800000 00360000 0c800000 00350000 e6bc80c8 00000032
       f6cc9640 0cb60000 0cb60000 0cb50000 e6bc80c8 00000032 ed5656fc 00010000
Call Trace:
 [<c0149dee>] zeromap_page_range+0x17e/0x240
 [<c01ed0af>] mmap_zero+0x3f/0x50
 [<c014d297>] do_mmap_pgoff+0x4a7/0x7f0
 [<c0108c17>] sys_mmap2+0x87/0xd0
 [<c010285d>] sysenter_past_esp+0x52/0x75
Code: ff 0b 74 24 1c 83 e6 fd 8b 03 85 c0 75 1d 89 33 83 c3 04 81 c1 00 10 00 00
0f 95 c2 31 c0 39 f9 0f 92 c0 85 c2 75 e1 5b 5e 5f c3 <0f> 0b e9 03 55 27 31 c0
eb d9 8d b6 00 00 00 00 8d bf 00 00 00
 <6>note: yap[19935] exited with preempt_count 1
scheduling while atomic: yap/0x00000001/19935
 [<c02feb5e>] schedule+0x57e/0x640
 [<c0119fb0>] __call_console_drivers+0x50/0x60
 [<c011a0c5>] call_console_drivers+0x65/0x140
 [<c02ff819>] rwsem_down_read_failed+0x89/0x180
 [<c011a530>] release_console_sem+0x80/0xc0
 [<c011de92>] .text.lock.exit+0x27/0x85
 [<c011c7f7>] do_exit+0xa7/0x330
 [<c0103ae6>] die+0x186/0x190
 [<c0103e70>] do_invalid_op+0x0/0xb0
 [<c0103f12>] do_invalid_op+0xa2/0xb0
 [<c013eaa7>] __rmqueue+0xb7/0x100
 [<c0149c5a>] zeromap_pte_range+0x5a/0x70
 [<c01099fd>] convert_fxsr_to_user+0x11d/0x180
 [<c011401d>] try_to_wake_up+0x23d/0x280
 [<c0175169>] __d_lookup+0xd9/0x110
 [<c0129b53>] in_group_p+0x43/0x90
 [<c0103333>] error_code+0x2b/0x30
 [<c0149c5a>] zeromap_pte_range+0x5a/0x70
 [<c0149dee>] zeromap_page_range+0x17e/0x240
 [<c01ed0af>] mmap_zero+0x3f/0x50
 [<c014d297>] do_mmap_pgoff+0x4a7/0x7f0
 [<c0108c17>] sys_mmap2+0x87/0xd0
 [<c010285d>] sysenter_past_esp+0x52/0x75
AMD Athlon(tm) MP 2000+
Distribution: Fedora
Hardware Environment: Dual processor computer, kernel BUG at mm/memory.c:1001!
invalid operand: 0000 [#1]
SMP
Modules linked in: w83781d eeprom i2c_sensor i2c_isa nfs lockd autofs4 sunrpc
dm_mod md5 ipv6 i2c_amd756 i2c_core dl2k floppy ext3 jbd
CPU:    1
EIP:    0060:[<c0149c5a>]    Not tainted VLI
EFLAGS: 00010206   (2.6.11.6nf1)
EIP is at zeromap_pte_range+0x5a/0x70
eax: 10000000   ebx: d81ccd48   ecx: 00352000   edx: e64e2001
esi: 003cd025   edi: 00360000   ebp: e6bc80cc   esp: e64e2ebc
ds: 007b   es: 007b   ss: 0068
Process yap (pid: 19935, threadinfo=e64e2000 task=f6cc7020)
Stack: d81ccd40 00350000 0cb50000 c0149dee d81ccd40 0cb50000 00010000 00000025
       f6cc967c 00360000 0c800000 00360000 0c800000 00350000 e6bc80c8 00000032
       f6cc9640 0cb60000 0cb60000 0cb50000 e6bc80c8 00000032 ed5656fc 00010000
Call Trace:
 [<c0149dee>] zeromap_page_range+0x17e/0x240
 [<c01ed0af>] mmap_zero+0x3f/0x50
 [<c014d297>] do_mmap_pgoff+0x4a7/0x7f0
 [<c0108c17>] sys_mmap2+0x87/0xd0
 [<c010285d>] sysenter_past_esp+0x52/0x75
Code: ff 0b 74 24 1c 83 e6 fd 8b 03 85 c0 75 1d 89 33 83 c3 04 81 c1 00 10 00 00
0f 95 c2 31 c0 39 f9 0f 92 c0 85 c2 75 e1 5b 5e 5f c3 <0f> 0b e9 03 55 27 31 c0
eb d9 8d b6 00 00 00 00 8d bf 00 00 00
 <6>note: yap[19935] exited with preempt_count 1
scheduling while atomic: yap/0x00000001/19935
 [<c02feb5e>] schedule+0x57e/0x640
 [<c0119fb0>] __call_console_drivers+0x50/0x60
 [<c011a0c5>] call_console_drivers+0x65/0x140
 [<c02ff819>] rwsem_down_read_failed+0x89/0x180
 [<c011a530>] release_console_sem+0x80/0xc0
 [<c011de92>] .text.lock.exit+0x27/0x85
 [<c011c7f7>] do_exit+0xa7/0x330
 [<c0103ae6>] die+0x186/0x190
 [<c0103e70>] do_invalid_op+0x0/0xb0
 [<c0103f12>] do_invalid_op+0xa2/0xb0
 [<c013eaa7>] __rmqueue+0xb7/0x100
 [<c0149c5a>] zeromap_pte_range+0x5a/0x70
 [<c01099fd>] convert_fxsr_to_user+0x11d/0x180
 [<c011401d>] try_to_wake_up+0x23d/0x280
 [<c0175169>] __d_lookup+0xd9/0x110
 [<c0129b53>] in_group_p+0x43/0x90
 [<c0103333>] error_code+0x2b/0x30
 [<c0149c5a>] zeromap_pte_range+0x5a/0x70
 [<c0149dee>] zeromap_page_range+0x17e/0x240
 [<c01ed0af>] mmap_zero+0x3f/0x50
 [<c014d297>] do_mmap_pgoff+0x4a7/0x7f0
 [<c0108c17>] sys_mmap2+0x87/0xd0
 [<c010285d>] sysenter_past_esp+0x52/0x75
AMD Athlon(tm) MP 2000+
Distribution: Fedora
Hardware Environment: Dual processor computer, kernel BUG at mm/memory.c:1001!
invalid operand: 0000 [#1]
SMP
Modules linked in: w83781d eeprom i2c_sensor i2c_isa nfs lockd autofs4 sunrpc
dm_mod md5 ipv6 i2c_amd756 i2c_core dl2k floppy ext3 jbd
CPU:    1
EIP:    0060:[<c0149c5a>]    Not tainted VLI
EFLAGS: 00010206   (2.6.11.6nf1)
EIP is at zeromap_pte_range+0x5a/0x70
eax: 10000000   ebx: d81ccd48   ecx: 00352000   edx: e64e2001
esi: 003cd025   edi: 00360000   ebp: e6bc80cc   esp: e64e2ebc
ds: 007b   es: 007b   ss: 0068
Process yap (pid: 19935, threadinfo=e64e2000 task=f6cc7020)
Stack: d81ccd40 00350000 0cb50000 c0149dee d81ccd40 0cb50000 00010000 00000025
       f6cc967c 00360000 0c800000 00360000 0c800000 00350000 e6bc80c8 00000032
       f6cc9640 0cb60000 0cb60000 0cb50000 e6bc80c8 00000032 ed5656fc 00010000
Call Trace:
 [<c0149dee>] zeromap_page_range+0x17e/0x240
 [<c01ed0af>] mmap_zero+0x3f/0x50
 [<c014d297>] do_mmap_pgoff+0x4a7/0x7f0
 [<c0108c17>] sys_mmap2+0x87/0xd0
 [<c010285d>] sysenter_past_esp+0x52/0x75
Code: ff 0b 74 24 1c 83 e6 fd 8b 03 85 c0 75 1d 89 33 83 c3 04 81 c1 00 10 00 00
0f 95 c2 31 c0 39 f9 0f 92 c0 85 c2 75 e1 5b 5e 5f c3 <0f> 0b e9 03 55 27 31 c0
eb d9 8d b6 00 00 00 00 8d bf 00 00 00
 <6>note: yap[19935] exited with preempt_count 1
scheduling while atomic: yap/0x00000001/19935
 [<c02feb5e>] schedule+0x57e/0x640
 [<c0119fb0>] __call_console_drivers+0x50/0x60
 [<c011a0c5>] call_console_drivers+0x65/0x140
 [<c02ff819>] rwsem_down_read_failed+0x89/0x180
 [<c011a530>] release_console_sem+0x80/0xc0
 [<c011de92>] .text.lock.exit+0x27/0x85
 [<c011c7f7>] do_exit+0xa7/0x330
 [<c0103ae6>] die+0x186/0x190
 [<c0103e70>] do_invalid_op+0x0/0xb0
 [<c0103f12>] do_invalid_op+0xa2/0xb0
 [<c013eaa7>] __rmqueue+0xb7/0x100
 [<c0149c5a>] zeromap_pte_range+0x5a/0x70
 [<c01099fd>] convert_fxsr_to_user+0x11d/0x180
 [<c011401d>] try_to_wake_up+0x23d/0x280
 [<c0175169>] __d_lookup+0xd9/0x110
 [<c0129b53>] in_group_p+0x43/0x90
 [<c0103333>] error_code+0x2b/0x30
 [<c0149c5a>] zeromap_pte_range+0x5a/0x70
 [<c0149dee>] zeromap_page_range+0x17e/0x240
 [<c01ed0af>] mmap_zero+0x3f/0x50
 [<c014d297>] do_mmap_pgoff+0x4a7/0x7f0
 [<c0108c17>] sys_mmap2+0x87/0xd0
 [<c010285d>] sysenter_past_esp+0x52/0x75

Distribution: Fedora
Hardware Environment: Dual processor computer ( kernel BUG at mm/memory.c:1001!
invalid operand: 0000 [#1]
SMP
Modules linked in: w83781d eeprom i2c_sensor i2c_isa nfs lockd autofs4 sunrpc
dm_mod md5 ipv6 i2c_amd756 i2c_core dl2k floppy ext3 jbd
CPU:    1
EIP:    0060:[<c0149c5a>]    Not tainted VLI
EFLAGS: 00010206   (2.6.11.6nf1)
EIP is at zeromap_pte_range+0x5a/0x70
eax: 10000000   ebx: d81ccd48   ecx: 00352000   edx: e64e2001
esi: 003cd025   edi: 00360000   ebp: e6bc80cc   esp: e64e2ebc
ds: 007b   es: 007b   ss: 0068
Process yap (pid: 19935, threadinfo=e64e2000 task=f6cc7020)
Stack: d81ccd40 00350000 0cb50000 c0149dee d81ccd40 0cb50000 00010000 00000025
       f6cc967c 00360000 0c800000 00360000 0c800000 00350000 e6bc80c8 00000032
       f6cc9640 0cb60000 0cb60000 0cb50000 e6bc80c8 00000032 ed5656fc 00010000
Call Trace:
 [<c0149dee>] zeromap_page_range+0x17e/0x240
 [<c01ed0af>] mmap_zero+0x3f/0x50
 [<c014d297>] do_mmap_pgoff+0x4a7/0x7f0
 [<c0108c17>] sys_mmap2+0x87/0xd0
 [<c010285d>] sysenter_past_esp+0x52/0x75
Code: ff 0b 74 24 1c 83 e6 fd 8b 03 85 c0 75 1d 89 33 83 c3 04 81 c1 00 10 00 00
0f 95 c2 31 c0 39 f9 0f 92 c0 85 c2 75 e1 5b 5e 5f c3 <0f> 0b e9 03 55 27 31 c0
eb d9 8d b6 00 00 00 00 8d bf 00 00 00
 <6>note: yap[19935] exited with preempt_count 1
scheduling while atomic: yap/0x00000001/19935
 [<c02feb5e>] schedule+0x57e/0x640
 [<c0119fb0>] __call_console_drivers+0x50/0x60
 [<c011a0c5>] call_console_drivers+0x65/0x140
 [<c02ff819>] rwsem_down_read_failed+0x89/0x180
 [<c011a530>] release_console_sem+0x80/0xc0
 [<c011de92>] .text.lock.exit+0x27/0x85
 [<c011c7f7>] do_exit+0xa7/0x330
 [<c0103ae6>] die+0x186/0x190
 [<c0103e70>] do_invalid_op+0x0/0xb0
 [<c0103f12>] do_invalid_op+0xa2/0xb0
 [<c013eaa7>] __rmqueue+0xb7/0x100
 [<c0149c5a>] zeromap_pte_range+0x5a/0x70
 [<c01099fd>] convert_fxsr_to_user+0x11d/0x180
 [<c011401d>] try_to_wake_up+0x23d/0x280
 [<c0175169>] __d_lookup+0xd9/0x110
 [<c0129b53>] in_group_p+0x43/0x90
 [<c0103333>] error_code+0x2b/0x30
 [<c0149c5a>] zeromap_pte_range+0x5a/0x70
 [<c0149dee>] zeromap_page_range+0x17e/0x240
 [<c01ed0af>] mmap_zero+0x3f/0x50
 [<c014d297>] do_mmap_pgoff+0x4a7/0x7f0
 [<c0108c17>] sys_mmap2+0x87/0xd0
 [<c010285d>] sysenter_past_esp+0x52/0x75
Distribution: Fedora
Hardware Environment: Dual AMD Athlon(tm) MP 2000+ computer, 2GB RAM.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
