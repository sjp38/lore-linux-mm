Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0BEA06B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 04:28:10 -0400 (EDT)
Received: by vws13 with SMTP id 13so1485036vws.14
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 01:28:07 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 4 Jun 2010 16:27:54 +0800
Message-ID: <AANLkTilb4QNYznFeJVfMmvPAlBY-B02EY0i0d7NK9X7O@mail.gmail.com>
Subject: mmotm 2010-06-03-16-36 lots of suspected kmemleak
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks

[  667.904928] kmemleak: 3179 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)
[ 1270.774766] kmemleak: 24037 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)
[ 1873.679754] kmemleak: 2256 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)

unreferenced object 0xdf8f9700 (size 128):
  comm "swapper", pid 1, jiffies 4294877413 (age 1491.496s)
  hex dump (first 32 bytes):
    00 00 00 e0 ff ff bf fe 40 df 99 df 00 02 00 00  ........@.......
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c14a2c3e>] pci_acpi_scan_root+0x135/0x1cc
    [<c1497fe6>] acpi_pci_root_add+0x159/0x261
    [<c12b4414>] acpi_device_probe+0x44/0xfa
    [<c13234ac>] driver_probe_device+0x108/0x22b
    [<c1323616>] __driver_attach+0x47/0x63
    [<c1322d1b>] bus_for_each_dev+0x3d/0x67
    [<c1323267>] driver_attach+0x14/0x16
    [<c13226cc>] bus_add_driver+0xc4/0x20f
    [<c132386f>] driver_register+0x8b/0xeb
    [<c12b586d>] acpi_bus_register_driver+0x3a/0x3d
    [<c1787429>] acpi_pci_root_init+0x1b/0x2a
    [<c1001139>] do_one_initcall+0x4c/0x13f
    [<c176237e>] kernel_init+0x132/0x1b3
    [<c1002dfa>] kernel_thread_helper+0x6/0x10
unreferenced object 0xdf99df40 (size 16):
  comm "swapper", pid 1, jiffies 4294877413 (age 1491.496s)
  hex dump (first 16 bytes):
    50 43 49 20 42 75 73 20 30 30 30 30 3a 30 30 00  PCI Bus 0000:00.
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c1289078>] kvasprintf+0x28/0x45
    [<c12890a6>] kasprintf+0x11/0x13
    [<c14a2c5a>] pci_acpi_scan_root+0x151/0x1cc
    [<c1497fe6>] acpi_pci_root_add+0x159/0x261
    [<c12b4414>] acpi_device_probe+0x44/0xfa
    [<c13234ac>] driver_probe_device+0x108/0x22b
    [<c1323616>] __driver_attach+0x47/0x63
    [<c1322d1b>] bus_for_each_dev+0x3d/0x67
    [<c1323267>] driver_attach+0x14/0x16
    [<c13226cc>] bus_add_driver+0xc4/0x20f
    [<c132386f>] driver_register+0x8b/0xeb
    [<c12b586d>] acpi_bus_register_driver+0x3a/0x3d
    [<c1787429>] acpi_pci_root_init+0x1b/0x2a
    [<c1001139>] do_one_initcall+0x4c/0x13f
unreferenced object 0xdfa7d800 (size 2048):
  comm "swapper", pid 1, jiffies 4294877624 (age 1490.796s)
  hex dump (first 32 bytes):
    00 75 ff ff f4 ff ff ff f4 ff ff ff f4 ff ff ff  .u..............
    f4 ff ff ff c4 ff ff ff c4 ff ff ff f4 ff ff ff  ................
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c10c4a87>] kzalloc+0xb/0xd
    [<c10c4aa1>] pcpu_mem_alloc+0x18/0x35
    [<c10c53af>] pcpu_extend_area_map+0x1c/0xaa
    [<c10c55c5>] pcpu_alloc+0x188/0x735
    [<c10c5b8b>] __alloc_percpu+0xa/0xf
    [<c129133e>] __percpu_counter_init+0x42/0x92
    [<c10a9b3d>] bdi_init+0x114/0x15f
    [<c12721b9>] blk_alloc_queue_node+0x60/0x167
    [<c12722cb>] blk_alloc_queue+0xb/0xd
    [<c132c91f>] loop_alloc+0x6c/0x149
    [<c178b778>] loop_init+0x83/0x16c
    [<c1001139>] do_one_initcall+0x4c/0x13f
    [<c176237e>] kernel_init+0x132/0x1b3
    [<c1002dfa>] kernel_thread_helper+0x6/0x10
unreferenced object 0xdf24e9d8 (size 8):
  comm "swapper", pid 1, jiffies 4294878263 (age 1488.670s)
  hex dump (first 8 bytes):
    30 00 24 df 00 00 00 00                          0.$.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c1289078>] kvasprintf+0x28/0x45
    [<c1281579>] kobject_set_name_vargs+0x21/0x50
    [<c12815c0>] kobject_add_varg+0x18/0x41
    [<c128164e>] kobject_add+0x43/0x49
    [<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
    [<c179054c>] memmap_init+0x12/0x2c
    [<c1001139>] do_one_initcall+0x4c/0x13f
    [<c176237e>] kernel_init+0x132/0x1b3
    [<c1002dfa>] kernel_thread_helper+0x6/0x10
    [<ffffffff>] 0xffffffff
unreferenced object 0xdf24e9e8 (size 8):
  comm "swapper", pid 1, jiffies 4294878263 (age 1488.670s)
  hex dump (first 8 bytes):
    31 00 24 df 00 00 00 00                          1.$.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c1289078>] kvasprintf+0x28/0x45
    [<c1281579>] kobject_set_name_vargs+0x21/0x50
    [<c12815c0>] kobject_add_varg+0x18/0x41
    [<c128164e>] kobject_add+0x43/0x49
    [<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
    [<c179054c>] memmap_init+0x12/0x2c
    [<c1001139>] do_one_initcall+0x4c/0x13f
    [<c176237e>] kernel_init+0x132/0x1b3
    [<c1002dfa>] kernel_thread_helper+0x6/0x10
    [<ffffffff>] 0xffffffff
unreferenced object 0xdf24e9f8 (size 8):
  comm "swapper", pid 1, jiffies 4294878263 (age 1488.673s)
  hex dump (first 8 bytes):
    32 00 24 df 00 00 00 00                          2.$.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c1289078>] kvasprintf+0x28/0x45
    [<c1281579>] kobject_set_name_vargs+0x21/0x50
    [<c12815c0>] kobject_add_varg+0x18/0x41
    [<c128164e>] kobject_add+0x43/0x49
    [<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
    [<c179054c>] memmap_init+0x12/0x2c
    [<c1001139>] do_one_initcall+0x4c/0x13f
    [<c176237e>] kernel_init+0x132/0x1b3
    [<c1002dfa>] kernel_thread_helper+0x6/0x10
    [<ffffffff>] 0xffffffff
unreferenced object 0xdf24ea08 (size 8):
  comm "swapper", pid 1, jiffies 4294878263 (age 1488.673s)
  hex dump (first 8 bytes):
    33 00 24 df 00 00 00 00                          3.$.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c1289078>] kvasprintf+0x28/0x45
    [<c1281579>] kobject_set_name_vargs+0x21/0x50
    [<c12815c0>] kobject_add_varg+0x18/0x41
    [<c128164e>] kobject_add+0x43/0x49
    [<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
    [<c179054c>] memmap_init+0x12/0x2c
    [<c1001139>] do_one_initcall+0x4c/0x13f
    [<c176237e>] kernel_init+0x132/0x1b3
    [<c1002dfa>] kernel_thread_helper+0x6/0x10
    [<ffffffff>] 0xffffffff
unreferenced object 0xdf24ea18 (size 8):
  comm "swapper", pid 1, jiffies 4294878263 (age 1488.673s)
  hex dump (first 8 bytes):
    34 00 24 df 00 00 00 00                          4.$.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c1289078>] kvasprintf+0x28/0x45
    [<c1281579>] kobject_set_name_vargs+0x21/0x50
    [<c12815c0>] kobject_add_varg+0x18/0x41
    [<c128164e>] kobject_add+0x43/0x49
    [<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
    [<c179054c>] memmap_init+0x12/0x2c
    [<c1001139>] do_one_initcall+0x4c/0x13f
    [<c176237e>] kernel_init+0x132/0x1b3
    [<c1002dfa>] kernel_thread_helper+0x6/0x10
    [<ffffffff>] 0xffffffff
unreferenced object 0xdf24ea28 (size 8):
  comm "swapper", pid 1, jiffies 4294878263 (age 1488.673s)
  hex dump (first 8 bytes):
    35 00 24 df 00 00 00 00                          5.$.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c2259>] __kmalloc+0x147/0x16b
    [<c1289078>] kvasprintf+0x28/0x45
    [<c1281579>] kobject_set_name_vargs+0x21/0x50
    [<c12815c0>] kobject_add_varg+0x18/0x41
    [<c128164e>] kobject_add+0x43/0x49
    [<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
    [<c179054c>] memmap_init+0x12/0x2c
    [<c1001139>] do_one_initcall+0x4c/0x13f
    [<c176237e>] kernel_init+0x132/0x1b3
    [<c1002dfa>] kernel_thread_helper+0x6/0x10
    [<ffffffff>] 0xffffffff
unreferenced object 0xdec4e0c0 (size 44):
  comm "init", pid 1, jiffies 4294878357 (age 1488.363s)
  hex dump (first 32 bytes):
    02 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 c2 d8 c1 00 00 00 00 3c 7d 63 c1 30 e0 c4 de  ........<}c.0...
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c1aca>] kmem_cache_alloc+0xde/0x12a
    [<c10b4217>] anon_vma_fork+0x31/0x88
    [<c102c71d>] dup_mm+0x1d3/0x38f
    [<c102d20d>] copy_process+0x8ce/0xf39
    [<c102d990>] do_fork+0x118/0x295
    [<c1007fe0>] sys_clone+0x1f/0x24
    [<c10029b1>] ptregs_clone+0x15/0x24
    [<ffffffff>] 0xffffffff
unreferenced object 0xdec4e240 (size 44):
  comm "init", pid 768, jiffies 4294878359 (age 1488.356s)
  hex dump (first 32 bytes):
    fc fc 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 c2 d8 c1 00 00 00 00 3c 7d 63 c1 40 e2 c4 de  ........<}c.@...
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c1aca>] kmem_cache_alloc+0xde/0x12a
    [<c10b42e0>] anon_vma_prepare+0x72/0x12e
    [<c10ad3e1>] handle_mm_fault+0x153/0x60d
    [<c10ada62>] __get_user_pages+0x1c7/0x2c6
    [<c10adbd3>] get_user_pages+0x39/0x41
    [<c10cc80a>] get_arg_page+0x33/0x83
    [<c10cc922>] copy_strings+0xc8/0x165
    [<c10cc9db>] copy_strings_kernel+0x1c/0x2b
    [<c10cdd10>] do_execve+0x14d/0x257
    [<c1007f13>] sys_execve+0x2b/0x53
    [<c1002946>] ptregs_execve+0x12/0x18
    [<ffffffff>] 0xffffffff
unreferenced object 0xdec4e210 (size 44):
  comm "rc.S", pid 768, jiffies 4294878359 (age 1488.356s)
  hex dump (first 32 bytes):
    eb eb 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 c2 d8 c1 00 00 00 00 3c 7d 63 c1 10 e2 c4 de  ........<}c.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c1aca>] kmem_cache_alloc+0xde/0x12a
    [<c10b42e0>] anon_vma_prepare+0x72/0x12e
    [<c10abad2>] __do_fault+0x73/0x307
    [<c10ad52a>] handle_mm_fault+0x29c/0x60d
    [<c14b046e>] do_page_fault+0x2ee/0x304
    [<c14ae177>] error_code+0x6b/0x70
    [<c10f94c3>] load_elf_binary+0x6d7/0x111c
    [<c10cca88>] search_binary_handler+0x9e/0x20c
    [<c10f7917>] load_script+0x177/0x188
    [<c10cca88>] search_binary_handler+0x9e/0x20c
    [<c10cdd6a>] do_execve+0x1a7/0x257
    [<c1007f13>] sys_execve+0x2b/0x53
    [<c1002946>] ptregs_execve+0x12/0x18
    [<ffffffff>] 0xffffffff
unreferenced object 0xdec4e1e0 (size 44):
  comm "rc.S", pid 768, jiffies 4294878360 (age 1488.353s)
  hex dump (first 32 bytes):
    e5 e5 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 c2 d8 c1 00 00 00 00 3c 7d 63 c1 e0 e1 c4 de  ........<}c.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c1aca>] kmem_cache_alloc+0xde/0x12a
    [<c10b42e0>] anon_vma_prepare+0x72/0x12e
    [<c10abad2>] __do_fault+0x73/0x307
    [<c10ad52a>] handle_mm_fault+0x29c/0x60d
    [<c14b046e>] do_page_fault+0x2ee/0x304
    [<c14ae177>] error_code+0x6b/0x70
    [<c10f9782>] load_elf_binary+0x996/0x111c
    [<c10cca88>] search_binary_handler+0x9e/0x20c
    [<c10f7917>] load_script+0x177/0x188
    [<c10cca88>] search_binary_handler+0x9e/0x20c
    [<c10cdd6a>] do_execve+0x1a7/0x257
    [<c1007f13>] sys_execve+0x2b/0x53
    [<c1002946>] ptregs_execve+0x12/0x18
    [<ffffffff>] 0xffffffff
unreferenced object 0xdec4e1b0 (size 44):
  comm "rc.S", pid 768, jiffies 4294878360 (age 1488.356s)
  hex dump (first 32 bytes):
    fe fe 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 c2 d8 c1 00 00 00 00 3c 7d 63 c1 b0 e1 c4 de  ........<}c.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c1aca>] kmem_cache_alloc+0xde/0x12a
    [<c10b42e0>] anon_vma_prepare+0x72/0x12e
    [<c10ad3e1>] handle_mm_fault+0x153/0x60d
    [<c14b046e>] do_page_fault+0x2ee/0x304
    [<c14ae177>] error_code+0x6b/0x70
    [<ffffffff>] 0xffffffff
unreferenced object 0xdec4e180 (size 44):
  comm "rc.S", pid 768, jiffies 4294878360 (age 1488.356s)
  hex dump (first 32 bytes):
    fe fe 00 00 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    98 c2 d8 c1 00 00 00 00 3c 7d 63 c1 80 e1 c4 de  ........<}c.....
  backtrace:
    [<c149338a>] kmemleak_alloc+0x4a/0x83
    [<c10c1aca>] kmem_cache_alloc+0xde/0x12a
    [<c10b42e0>] anon_vma_prepare+0x72/0x12e
    [<c10abad2>] __do_fault+0x73/0x307
    [<c10ad52a>] handle_mm_fault+0x29c/0x60d
    [<c14b046e>] do_page_fault+0x2ee/0x304
    [<c14ae177>] error_code+0x6b/0x70
    [<ffffffff>] 0xffffffff

[snip similar vma issue .....]

-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
