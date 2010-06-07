Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE8DD6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 04:30:15 -0400 (EDT)
Received: by vws8 with SMTP id 8so220670vws.14
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 01:30:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTilb4QNYznFeJVfMmvPAlBY-B02EY0i0d7NK9X7O@mail.gmail.com>
References: <AANLkTilb4QNYznFeJVfMmvPAlBY-B02EY0i0d7NK9X7O@mail.gmail.com>
Date: Mon, 7 Jun 2010 16:30:12 +0800
Message-ID: <AANLkTinwRWd0Uskfy-Z4f0RrDCivnkorWYgVWW2Bpy63@mail.gmail.com>
Subject: Re: mmotm 2010-06-03-16-36 lots of suspected kmemleak
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 4, 2010 at 4:27 PM, Dave Young <hidave.darkstar@gmail.com> wrot=
e:
> Hi,
>
> With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks
>
> [ =C2=A0667.904928] kmemleak: 3179 new suspected memory leaks (see
> /sys/kernel/debug/kmemleak)
> [ 1270.774766] kmemleak: 24037 new suspected memory leaks (see
> /sys/kernel/debug/kmemleak)
> [ 1873.679754] kmemleak: 2256 new suspected memory leaks (see
> /sys/kernel/debug/kmemleak)
>
> unreferenced object 0xdf8f9700 (size 128):
> =C2=A0comm "swapper", pid 1, jiffies 4294877413 (age 1491.496s)
> =C2=A0hex dump (first 32 bytes):
> =C2=A0 =C2=A000 00 00 e0 ff ff bf fe 40 df 99 df 00 02 00 00 =C2=A0......=
..@.......
> =C2=A0 =C2=A000 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =C2=A0......=
..........
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c14a2c3e>] pci_acpi_scan_root+0x135/0x1cc
> =C2=A0 =C2=A0[<c1497fe6>] acpi_pci_root_add+0x159/0x261
> =C2=A0 =C2=A0[<c12b4414>] acpi_device_probe+0x44/0xfa
> =C2=A0 =C2=A0[<c13234ac>] driver_probe_device+0x108/0x22b
> =C2=A0 =C2=A0[<c1323616>] __driver_attach+0x47/0x63
> =C2=A0 =C2=A0[<c1322d1b>] bus_for_each_dev+0x3d/0x67
> =C2=A0 =C2=A0[<c1323267>] driver_attach+0x14/0x16
> =C2=A0 =C2=A0[<c13226cc>] bus_add_driver+0xc4/0x20f
> =C2=A0 =C2=A0[<c132386f>] driver_register+0x8b/0xeb
> =C2=A0 =C2=A0[<c12b586d>] acpi_bus_register_driver+0x3a/0x3d
> =C2=A0 =C2=A0[<c1787429>] acpi_pci_root_init+0x1b/0x2a
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> =C2=A0 =C2=A0[<c176237e>] kernel_init+0x132/0x1b3
> =C2=A0 =C2=A0[<c1002dfa>] kernel_thread_helper+0x6/0x10
> unreferenced object 0xdf99df40 (size 16):
> =C2=A0comm "swapper", pid 1, jiffies 4294877413 (age 1491.496s)
> =C2=A0hex dump (first 16 bytes):
> =C2=A0 =C2=A050 43 49 20 42 75 73 20 30 30 30 30 3a 30 30 00 =C2=A0PCI Bu=
s 0000:00.
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c1289078>] kvasprintf+0x28/0x45
> =C2=A0 =C2=A0[<c12890a6>] kasprintf+0x11/0x13
> =C2=A0 =C2=A0[<c14a2c5a>] pci_acpi_scan_root+0x151/0x1cc
> =C2=A0 =C2=A0[<c1497fe6>] acpi_pci_root_add+0x159/0x261
> =C2=A0 =C2=A0[<c12b4414>] acpi_device_probe+0x44/0xfa
> =C2=A0 =C2=A0[<c13234ac>] driver_probe_device+0x108/0x22b
> =C2=A0 =C2=A0[<c1323616>] __driver_attach+0x47/0x63
> =C2=A0 =C2=A0[<c1322d1b>] bus_for_each_dev+0x3d/0x67
> =C2=A0 =C2=A0[<c1323267>] driver_attach+0x14/0x16
> =C2=A0 =C2=A0[<c13226cc>] bus_add_driver+0xc4/0x20f
> =C2=A0 =C2=A0[<c132386f>] driver_register+0x8b/0xeb
> =C2=A0 =C2=A0[<c12b586d>] acpi_bus_register_driver+0x3a/0x3d
> =C2=A0 =C2=A0[<c1787429>] acpi_pci_root_init+0x1b/0x2a
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> unreferenced object 0xdfa7d800 (size 2048):
> =C2=A0comm "swapper", pid 1, jiffies 4294877624 (age 1490.796s)
> =C2=A0hex dump (first 32 bytes):
> =C2=A0 =C2=A000 75 ff ff f4 ff ff ff f4 ff ff ff f4 ff ff ff =C2=A0.u....=
..........
> =C2=A0 =C2=A0f4 ff ff ff c4 ff ff ff c4 ff ff ff f4 ff ff ff =C2=A0......=
..........
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c10c4a87>] kzalloc+0xb/0xd
> =C2=A0 =C2=A0[<c10c4aa1>] pcpu_mem_alloc+0x18/0x35
> =C2=A0 =C2=A0[<c10c53af>] pcpu_extend_area_map+0x1c/0xaa
> =C2=A0 =C2=A0[<c10c55c5>] pcpu_alloc+0x188/0x735
> =C2=A0 =C2=A0[<c10c5b8b>] __alloc_percpu+0xa/0xf
> =C2=A0 =C2=A0[<c129133e>] __percpu_counter_init+0x42/0x92
> =C2=A0 =C2=A0[<c10a9b3d>] bdi_init+0x114/0x15f
> =C2=A0 =C2=A0[<c12721b9>] blk_alloc_queue_node+0x60/0x167
> =C2=A0 =C2=A0[<c12722cb>] blk_alloc_queue+0xb/0xd
> =C2=A0 =C2=A0[<c132c91f>] loop_alloc+0x6c/0x149
> =C2=A0 =C2=A0[<c178b778>] loop_init+0x83/0x16c
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> =C2=A0 =C2=A0[<c176237e>] kernel_init+0x132/0x1b3
> =C2=A0 =C2=A0[<c1002dfa>] kernel_thread_helper+0x6/0x10
> unreferenced object 0xdf24e9d8 (size 8):
> =C2=A0comm "swapper", pid 1, jiffies 4294878263 (age 1488.670s)
> =C2=A0hex dump (first 8 bytes):
> =C2=A0 =C2=A030 00 24 df 00 00 00 00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.$.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c1289078>] kvasprintf+0x28/0x45
> =C2=A0 =C2=A0[<c1281579>] kobject_set_name_vargs+0x21/0x50
> =C2=A0 =C2=A0[<c12815c0>] kobject_add_varg+0x18/0x41
> =C2=A0 =C2=A0[<c128164e>] kobject_add+0x43/0x49
> =C2=A0 =C2=A0[<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
> =C2=A0 =C2=A0[<c179054c>] memmap_init+0x12/0x2c
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> =C2=A0 =C2=A0[<c176237e>] kernel_init+0x132/0x1b3
> =C2=A0 =C2=A0[<c1002dfa>] kernel_thread_helper+0x6/0x10
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdf24e9e8 (size 8):
> =C2=A0comm "swapper", pid 1, jiffies 4294878263 (age 1488.670s)
> =C2=A0hex dump (first 8 bytes):
> =C2=A0 =C2=A031 00 24 df 00 00 00 00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01.$.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c1289078>] kvasprintf+0x28/0x45
> =C2=A0 =C2=A0[<c1281579>] kobject_set_name_vargs+0x21/0x50
> =C2=A0 =C2=A0[<c12815c0>] kobject_add_varg+0x18/0x41
> =C2=A0 =C2=A0[<c128164e>] kobject_add+0x43/0x49
> =C2=A0 =C2=A0[<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
> =C2=A0 =C2=A0[<c179054c>] memmap_init+0x12/0x2c
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> =C2=A0 =C2=A0[<c176237e>] kernel_init+0x132/0x1b3
> =C2=A0 =C2=A0[<c1002dfa>] kernel_thread_helper+0x6/0x10
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdf24e9f8 (size 8):
> =C2=A0comm "swapper", pid 1, jiffies 4294878263 (age 1488.673s)
> =C2=A0hex dump (first 8 bytes):
> =C2=A0 =C2=A032 00 24 df 00 00 00 00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02.$.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c1289078>] kvasprintf+0x28/0x45
> =C2=A0 =C2=A0[<c1281579>] kobject_set_name_vargs+0x21/0x50
> =C2=A0 =C2=A0[<c12815c0>] kobject_add_varg+0x18/0x41
> =C2=A0 =C2=A0[<c128164e>] kobject_add+0x43/0x49
> =C2=A0 =C2=A0[<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
> =C2=A0 =C2=A0[<c179054c>] memmap_init+0x12/0x2c
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> =C2=A0 =C2=A0[<c176237e>] kernel_init+0x132/0x1b3
> =C2=A0 =C2=A0[<c1002dfa>] kernel_thread_helper+0x6/0x10
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdf24ea08 (size 8):
> =C2=A0comm "swapper", pid 1, jiffies 4294878263 (age 1488.673s)
> =C2=A0hex dump (first 8 bytes):
> =C2=A0 =C2=A033 00 24 df 00 00 00 00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.$.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c1289078>] kvasprintf+0x28/0x45
> =C2=A0 =C2=A0[<c1281579>] kobject_set_name_vargs+0x21/0x50
> =C2=A0 =C2=A0[<c12815c0>] kobject_add_varg+0x18/0x41
> =C2=A0 =C2=A0[<c128164e>] kobject_add+0x43/0x49
> =C2=A0 =C2=A0[<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
> =C2=A0 =C2=A0[<c179054c>] memmap_init+0x12/0x2c
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> =C2=A0 =C2=A0[<c176237e>] kernel_init+0x132/0x1b3
> =C2=A0 =C2=A0[<c1002dfa>] kernel_thread_helper+0x6/0x10
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdf24ea18 (size 8):
> =C2=A0comm "swapper", pid 1, jiffies 4294878263 (age 1488.673s)
> =C2=A0hex dump (first 8 bytes):
> =C2=A0 =C2=A034 00 24 df 00 00 00 00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04.$.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c1289078>] kvasprintf+0x28/0x45
> =C2=A0 =C2=A0[<c1281579>] kobject_set_name_vargs+0x21/0x50
> =C2=A0 =C2=A0[<c12815c0>] kobject_add_varg+0x18/0x41
> =C2=A0 =C2=A0[<c128164e>] kobject_add+0x43/0x49
> =C2=A0 =C2=A0[<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
> =C2=A0 =C2=A0[<c179054c>] memmap_init+0x12/0x2c
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> =C2=A0 =C2=A0[<c176237e>] kernel_init+0x132/0x1b3
> =C2=A0 =C2=A0[<c1002dfa>] kernel_thread_helper+0x6/0x10
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdf24ea28 (size 8):
> =C2=A0comm "swapper", pid 1, jiffies 4294878263 (age 1488.673s)
> =C2=A0hex dump (first 8 bytes):
> =C2=A0 =C2=A035 00 24 df 00 00 00 00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A05.$.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c2259>] __kmalloc+0x147/0x16b
> =C2=A0 =C2=A0[<c1289078>] kvasprintf+0x28/0x45
> =C2=A0 =C2=A0[<c1281579>] kobject_set_name_vargs+0x21/0x50
> =C2=A0 =C2=A0[<c12815c0>] kobject_add_varg+0x18/0x41
> =C2=A0 =C2=A0[<c128164e>] kobject_add+0x43/0x49
> =C2=A0 =C2=A0[<c13f89f7>] add_sysfs_fw_map_entry+0x56/0x6f
> =C2=A0 =C2=A0[<c179054c>] memmap_init+0x12/0x2c
> =C2=A0 =C2=A0[<c1001139>] do_one_initcall+0x4c/0x13f
> =C2=A0 =C2=A0[<c176237e>] kernel_init+0x132/0x1b3
> =C2=A0 =C2=A0[<c1002dfa>] kernel_thread_helper+0x6/0x10
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdec4e0c0 (size 44):
> =C2=A0comm "init", pid 1, jiffies 4294878357 (age 1488.363s)
> =C2=A0hex dump (first 32 bytes):
> =C2=A0 =C2=A002 02 00 00 ad 4e ad de ff ff ff ff ff ff ff ff =C2=A0.....N=
..........
> =C2=A0 =C2=A098 c2 d8 c1 00 00 00 00 3c 7d 63 c1 30 e0 c4 de =C2=A0......=
..<}c.0...
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c1aca>] kmem_cache_alloc+0xde/0x12a
> =C2=A0 =C2=A0[<c10b4217>] anon_vma_fork+0x31/0x88
> =C2=A0 =C2=A0[<c102c71d>] dup_mm+0x1d3/0x38f
> =C2=A0 =C2=A0[<c102d20d>] copy_process+0x8ce/0xf39
> =C2=A0 =C2=A0[<c102d990>] do_fork+0x118/0x295
> =C2=A0 =C2=A0[<c1007fe0>] sys_clone+0x1f/0x24
> =C2=A0 =C2=A0[<c10029b1>] ptregs_clone+0x15/0x24
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdec4e240 (size 44):
> =C2=A0comm "init", pid 768, jiffies 4294878359 (age 1488.356s)
> =C2=A0hex dump (first 32 bytes):
> =C2=A0 =C2=A0fc fc 00 00 ad 4e ad de ff ff ff ff ff ff ff ff =C2=A0.....N=
..........
> =C2=A0 =C2=A098 c2 d8 c1 00 00 00 00 3c 7d 63 c1 40 e2 c4 de =C2=A0......=
..<}c.@...
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c1aca>] kmem_cache_alloc+0xde/0x12a
> =C2=A0 =C2=A0[<c10b42e0>] anon_vma_prepare+0x72/0x12e
> =C2=A0 =C2=A0[<c10ad3e1>] handle_mm_fault+0x153/0x60d
> =C2=A0 =C2=A0[<c10ada62>] __get_user_pages+0x1c7/0x2c6
> =C2=A0 =C2=A0[<c10adbd3>] get_user_pages+0x39/0x41
> =C2=A0 =C2=A0[<c10cc80a>] get_arg_page+0x33/0x83
> =C2=A0 =C2=A0[<c10cc922>] copy_strings+0xc8/0x165
> =C2=A0 =C2=A0[<c10cc9db>] copy_strings_kernel+0x1c/0x2b
> =C2=A0 =C2=A0[<c10cdd10>] do_execve+0x14d/0x257
> =C2=A0 =C2=A0[<c1007f13>] sys_execve+0x2b/0x53
> =C2=A0 =C2=A0[<c1002946>] ptregs_execve+0x12/0x18
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdec4e210 (size 44):
> =C2=A0comm "rc.S", pid 768, jiffies 4294878359 (age 1488.356s)
> =C2=A0hex dump (first 32 bytes):
> =C2=A0 =C2=A0eb eb 00 00 ad 4e ad de ff ff ff ff ff ff ff ff =C2=A0.....N=
..........
> =C2=A0 =C2=A098 c2 d8 c1 00 00 00 00 3c 7d 63 c1 10 e2 c4 de =C2=A0......=
..<}c.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c1aca>] kmem_cache_alloc+0xde/0x12a
> =C2=A0 =C2=A0[<c10b42e0>] anon_vma_prepare+0x72/0x12e
> =C2=A0 =C2=A0[<c10abad2>] __do_fault+0x73/0x307
> =C2=A0 =C2=A0[<c10ad52a>] handle_mm_fault+0x29c/0x60d
> =C2=A0 =C2=A0[<c14b046e>] do_page_fault+0x2ee/0x304
> =C2=A0 =C2=A0[<c14ae177>] error_code+0x6b/0x70
> =C2=A0 =C2=A0[<c10f94c3>] load_elf_binary+0x6d7/0x111c
> =C2=A0 =C2=A0[<c10cca88>] search_binary_handler+0x9e/0x20c
> =C2=A0 =C2=A0[<c10f7917>] load_script+0x177/0x188
> =C2=A0 =C2=A0[<c10cca88>] search_binary_handler+0x9e/0x20c
> =C2=A0 =C2=A0[<c10cdd6a>] do_execve+0x1a7/0x257
> =C2=A0 =C2=A0[<c1007f13>] sys_execve+0x2b/0x53
> =C2=A0 =C2=A0[<c1002946>] ptregs_execve+0x12/0x18
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdec4e1e0 (size 44):
> =C2=A0comm "rc.S", pid 768, jiffies 4294878360 (age 1488.353s)
> =C2=A0hex dump (first 32 bytes):
> =C2=A0 =C2=A0e5 e5 00 00 ad 4e ad de ff ff ff ff ff ff ff ff =C2=A0.....N=
..........
> =C2=A0 =C2=A098 c2 d8 c1 00 00 00 00 3c 7d 63 c1 e0 e1 c4 de =C2=A0......=
..<}c.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c1aca>] kmem_cache_alloc+0xde/0x12a
> =C2=A0 =C2=A0[<c10b42e0>] anon_vma_prepare+0x72/0x12e
> =C2=A0 =C2=A0[<c10abad2>] __do_fault+0x73/0x307
> =C2=A0 =C2=A0[<c10ad52a>] handle_mm_fault+0x29c/0x60d
> =C2=A0 =C2=A0[<c14b046e>] do_page_fault+0x2ee/0x304
> =C2=A0 =C2=A0[<c14ae177>] error_code+0x6b/0x70
> =C2=A0 =C2=A0[<c10f9782>] load_elf_binary+0x996/0x111c
> =C2=A0 =C2=A0[<c10cca88>] search_binary_handler+0x9e/0x20c
> =C2=A0 =C2=A0[<c10f7917>] load_script+0x177/0x188
> =C2=A0 =C2=A0[<c10cca88>] search_binary_handler+0x9e/0x20c
> =C2=A0 =C2=A0[<c10cdd6a>] do_execve+0x1a7/0x257
> =C2=A0 =C2=A0[<c1007f13>] sys_execve+0x2b/0x53
> =C2=A0 =C2=A0[<c1002946>] ptregs_execve+0x12/0x18
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdec4e1b0 (size 44):
> =C2=A0comm "rc.S", pid 768, jiffies 4294878360 (age 1488.356s)
> =C2=A0hex dump (first 32 bytes):
> =C2=A0 =C2=A0fe fe 00 00 ad 4e ad de ff ff ff ff ff ff ff ff =C2=A0.....N=
..........
> =C2=A0 =C2=A098 c2 d8 c1 00 00 00 00 3c 7d 63 c1 b0 e1 c4 de =C2=A0......=
..<}c.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c1aca>] kmem_cache_alloc+0xde/0x12a
> =C2=A0 =C2=A0[<c10b42e0>] anon_vma_prepare+0x72/0x12e
> =C2=A0 =C2=A0[<c10ad3e1>] handle_mm_fault+0x153/0x60d
> =C2=A0 =C2=A0[<c14b046e>] do_page_fault+0x2ee/0x304
> =C2=A0 =C2=A0[<c14ae177>] error_code+0x6b/0x70
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> unreferenced object 0xdec4e180 (size 44):
> =C2=A0comm "rc.S", pid 768, jiffies 4294878360 (age 1488.356s)
> =C2=A0hex dump (first 32 bytes):
> =C2=A0 =C2=A0fe fe 00 00 ad 4e ad de ff ff ff ff ff ff ff ff =C2=A0.....N=
..........
> =C2=A0 =C2=A098 c2 d8 c1 00 00 00 00 3c 7d 63 c1 80 e1 c4 de =C2=A0......=
..<}c.....
> =C2=A0backtrace:
> =C2=A0 =C2=A0[<c149338a>] kmemleak_alloc+0x4a/0x83
> =C2=A0 =C2=A0[<c10c1aca>] kmem_cache_alloc+0xde/0x12a
> =C2=A0 =C2=A0[<c10b42e0>] anon_vma_prepare+0x72/0x12e
> =C2=A0 =C2=A0[<c10abad2>] __do_fault+0x73/0x307
> =C2=A0 =C2=A0[<c10ad52a>] handle_mm_fault+0x29c/0x60d
> =C2=A0 =C2=A0[<c14b046e>] do_page_fault+0x2ee/0x304
> =C2=A0 =C2=A0[<c14ae177>] error_code+0x6b/0x70
> =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
>
> [snip similar vma issue .....]
>
> --
> Regards
> dave
>

Another kmemleak problem:
In kvm guest (i386), kmemleak Oops:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Linux version 2.6.35-rc1-mm1 (dave@darkstar) (gcc
version 4.3.3 (GCC) ) #9 SMP Mon Jun 7 15:45:24 CST 2010
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
[    0.000000]  BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000001fffd000 (usable)
[    0.000000]  BIOS-e820: 000000001fffd000 - 0000000020000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fffbc000 - 0000000100000000 (reserved)
[    0.000000] Notice: NX (Execute Disable) protection cannot be
enabled: non-PAE kernel!
[    0.000000] DMI 2.4 present.
[    0.000000] e820 update range: 0000000000000000 - 0000000000001000
(usable) =3D=3D> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usab=
le)
[    0.000000] last_pfn =3D 0x1fffd max_arch_pfn =3D 0x100000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] PAT not supported by CPU.
[    0.000000] initial memory mapped : 0 - 02000000
[    0.000000] found SMP MP-table at [c00f89a0] f89a0
[    0.000000] init_memory_mapping: 0000000000000000-000000001fffd000
[    0.000000]  0000000000 - 0000400000 page 4k
[    0.000000]  0000400000 - 001fc00000 page 2M
[    0.000000]  001fc00000 - 001fffd000 page 4k
[    0.000000] kernel direct mapping tables up to 1fffd000 @ 7000-c000
[    0.000000] ACPI: RSDP 000f8950 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 1fffde30 00034 (v01 BOCHS  BXPCRSDT 00000001
BXPC 00000001)
[    0.000000] ACPI: FACP 1ffffe70 00074 (v01 BOCHS  BXPCFACP 00000001
BXPC 00000001)
[    0.000000] ACPI: DSDT 1fffdfd0 01E22 (v01   BXPC   BXDSDT 00000001
INTL 20090123)
[    0.000000] ACPI: FACS 1ffffe00 00040
[    0.000000] ACPI: SSDT 1fffdf90 00037 (v01 BOCHS  BXPCSSDT 00000001
BXPC 00000001)
[    0.000000] ACPI: APIC 1fffdeb0 00072 (v01 BOCHS  BXPCAPIC 00000001
BXPC 00000001)
[    0.000000] ACPI: HPET 1fffde70 00038 (v01 BOCHS  BXPCHPET 00000001
BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 511MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 1fffd000
[    0.000000]   low ram: 0 - 1fffd000
[    0.000000] kvm-clock: Using msrs 12 and 11
[    0.000000] kvm-clock: cpu 0, msr 0:17e22c1, boot clock
[    0.000000] sizeof(struct page) =3D 32
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000001 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x0001fffd
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000001 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0001fffd
[    0.000000] On node 0 totalpages: 130971
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3966 pages, LIFO batch:0
[    0.000000]   Normal zone: 992 pages used for memmap
[    0.000000]   Normal zone: 125981 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level=
)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level=
)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] early_res array is doubled to 64 at [8000 - 87ff]
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000=
a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000=
f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 00000000001=
00000
[    0.000000] Allocating PCI resources starting at 20000000 (gap:
20000000:dffbc000)
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:1
nr_node_ids:1
[    0.000000] PERCPU: Embedded 14 pages/cpu @c2400000 s35584 r0 d21760 u41=
94304
[    0.000000] pcpu-alloc: s35584 r0 d21760 u4194304 alloc=3D1*4194304
[    0.000000] pcpu-alloc: [0] 0
[    0.000000] kvm-clock: cpu 0, msr 0:24082c1, primary cpu clock
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 129947
[    0.000000] Kernel command line: BOOT_IMAGE=3Dmm1 ro root=3Dfd02 rootfst=
ype=3Dext4
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] Subtract (45 early reservations)
[    0.000000]   #1 [0000001000 - 0000002000]   EX TRAMPOLINE
[    0.000000]   #2 [0001000000 - 0001dc4bc0]   TEXT DATA BSS
[    0.000000]   #3 [0001dc5000 - 0001dcd049]             BRK
[    0.000000]   #4 [000009f400 - 00000f89a0]   BIOS reserved
[    0.000000]   #5 [00000f89a0 - 00000f89b0]    MP-table mpf
[    0.000000]   #6 [00000f8a98 - 0000100000]   BIOS reserved
[    0.000000]   #7 [00000f89b0 - 00000f8a98]    MP-table mpc
[    0.000000]   #8 [0000002000 - 0000003000]      TRAMPOLINE
[    0.000000]   #9 [0000003000 - 0000007000]     ACPI WAKEUP
[    0.000000]   #10 [0000007000 - 0000008000]         PGTABLE
[    0.000000]   #11 [0001dce000 - 0001dcf000]         BOOTMEM
[    0.000000]   #12 [0001dc4cc0 - 0001dc4d00]         BOOTMEM
[    0.000000]   #13 [0001dcf000 - 0001e4f000]         BOOTMEM
[    0.000000]   #14 [0001e4f000 - 0001ecf000]         BOOTMEM
[    0.000000]   #15 [0001ecf000 - 0001f4f000]         BOOTMEM
[    0.000000]   #16 [0001f4f000 - 0001fcf000]         BOOTMEM
[    0.000000]   #17 [0001fcf000 - 000204f000]         BOOTMEM
[    0.000000]   #18 [000204f000 - 00020cf000]         BOOTMEM
[    0.000000]   #19 [00020cf000 - 000214f000]         BOOTMEM
[    0.000000]   #20 [000214f000 - 00021cf000]         BOOTMEM
[    0.000000]   #21 [0001dc4d00 - 0001dc4f40]         BOOTMEM
[    0.000000]   #22 [00021cf000 - 00021d3800]         BOOTMEM
[    0.000000]   #23 [0001dc4bc0 - 0001dc4be5]         BOOTMEM
[    0.000000]   #24 [0001dc4c00 - 0001dc4c27]         BOOTMEM
[    0.000000]   #25 [0001dcd080 - 0001dcd144]         BOOTMEM
[    0.000000]   #26 [0001dc4c40 - 0001dc4c80]         BOOTMEM
[    0.000000]   #27 [0001dc4c80 - 0001dc4cc0]         BOOTMEM
[    0.000000]   #28 [0001dc4f40 - 0001dc4f80]         BOOTMEM
[    0.000000]   #29 [0001dc4f80 - 0001dc4fc0]         BOOTMEM
[    0.000000]   #30 [0001dc4fc0 - 0001dc5000]         BOOTMEM
[    0.000000]   #31 [0001dcd180 - 0001dcd1c0]         BOOTMEM
[    0.000000]   #32 [0001dcd1c0 - 0001dcd1d0]         BOOTMEM
[    0.000000]   #33 [0001dcd200 - 0001dcd22c]         BOOTMEM
[    0.000000]   #34 [0001dcd240 - 0001dcd26c]         BOOTMEM
[    0.000000]   #35 [0002400000 - 000240e000]         BOOTMEM
[    0.000000]   #36 [0001dcd280 - 0001dcd284]         BOOTMEM
[    0.000000]   #37 [0001dcd2c0 - 0001dcd2c4]         BOOTMEM
[    0.000000]   #38 [0001dcd300 - 0001dcd304]         BOOTMEM
[    0.000000]   #39 [0001dcd340 - 0001dcd344]         BOOTMEM
[    0.000000]   #40 [0001dcd380 - 0001dcd430]         BOOTMEM
[    0.000000]   #41 [0001dcd440 - 0001dcd4e8]         BOOTMEM
[    0.000000]   #42 [00021d3800 - 00021d5800]         BOOTMEM
[    0.000000]   #43 [00021d5800 - 0002215800]         BOOTMEM
[    0.000000]   #44 [0002215800 - 0002235800]         BOOTMEM
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 505152k/524276k available (4834k kernel code,
18732k reserved, 2755k data, 484k init, 0k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff8d000 - 0xfffff000   ( 456 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xe07fd000 - 0xff7fe000   ( 496 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xdfffd000   ( 511 MB)
[    0.000000]       .init : 0xc176a000 - 0xc17e3000   ( 484 kB)
[    0.000000]       .data : 0xc14b8a35 - 0xc1769790   (2755 kB)
[    0.000000]       .text : 0xc1000000 - 0xc14b8a35   (4834 kB)
[    0.000000] Checking if this processor honours the WP bit even in
supervisor mode...Ok.
[    0.000000] SLUB: Genslabs=3D13, HWalign=3D64, Order=3D0-3, MinObjects=
=3D0,
CPUs=3D1, Nodes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU debugfs-based tracing is enabled.
[    0.000000] 	RCU-based detection of stalled CPUs is disabled.
[    0.000000] 	Verbose stalled-CPUs detection is disabled.
[    0.000000] NR_IRQS:320
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat,
Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] hpet clockevent registered
[    0.000000] Detected 2925.456 MHz processor.
[    0.013332] Calibrating delay loop (skipped) preset value.. 5853.70
BogoMIPS (lpj=3D9751520)
[    0.013332] pid_max: default: 32768 minimum: 301
[    0.013332] Security Framework initialized
[    0.013332] Mount-cache hash table entries: 512
[    0.013332] Initializing cgroup subsys ns
[    0.013332] Initializing cgroup subsys cpuacct
[    0.013332] Initializing cgroup subsys blkio
[    0.013332] Performance Events: unsupported p6 CPU model 2 no PMU
driver, software events only.
[    0.020305] SMP alternatives: switching to UP code
[    0.210069] Freeing SMP alternatives: 20k freed
[    0.210082] ACPI: Core revision 20100428
[    0.223616] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.226109] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.226114] CPU0: Intel QEMU Virtual CPU version 0.12.3 stepping 03
[    0.226666] NMI watchdog failed to create perf event on cpu0: ffffffed
[    0.226666] Brought up 1 CPUs
[    0.226666] Total of 1 processors activated (5853.70 BogoMIPS).
[    0.226666] khelper used greatest stack depth: 6988 bytes left
[    0.228315] regulator: core version 0.5
[    0.228568] Time: 15:48:17  Date: 06/07/10
[    0.228891] NET: Registered protocol family 16
[    0.230461] khelper used greatest stack depth: 6876 bytes left
[    0.232109] ACPI: bus type pci registered
[    0.233463] PCI: PCI BIOS revision 2.10 entry at 0xffe77, last bus=3D0
[    0.233468] PCI: Using configuration type 1 for base access
[    0.265365] bio: create slab <bio-0> at 0
[    0.267764] ACPI: EC: Look up EC in DSDT
[    0.296433] ACPI: Interpreter enabled
[    0.296439] ACPI: (supports S0 S3 S4 S5)
[    0.296696] ACPI: Using IOAPIC for interrupt routing
[    0.344811] ACPI: No dock devices found.
[    0.344823] PCI: Ignoring host bridge windows from ACPI; if
necessary, use "pci=3Duse_crs" and report a bug
[    0.344964] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.345485] pci_root PNP0A03:00: host bridge window [io
0x0000-0x0cf7] (ignored)
[    0.345487] pci_root PNP0A03:00: host bridge window [io
0x0d00-0xffff] (ignored)
[    0.345490] pci_root PNP0A03:00: host bridge window [mem
0x000a0000-0x000bffff] (ignored)
[    0.345492] pci_root PNP0A03:00: host bridge window [mem
0xe0000000-0xfebfffff] (ignored)
[    0.347414] pci 0000:00:01.1: reg 20: [io  0xc000-0xc00f]
[    0.348110] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by
PIIX4 ACPI
[    0.348132] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.353444] pci 0000:00:02.0: reg 10: [mem 0xf0000000-0xf1ffffff pref]
[    0.356776] pci 0000:00:02.0: reg 14: [mem 0xf2000000-0xf2000fff]
[    0.371362] pci 0000:00:02.0: reg 30: [mem 0xf2010000-0xf201ffff pref]
[    0.373791] pci 0000:00:03.0: reg 10: [io  0xc020-0xc03f]
[    0.373882] pci 0000:00:03.0: reg 14: [mem 0xf2020000-0xf2020fff]
[    0.374123] pci 0000:00:03.0: reg 30: [mem 0xf2030000-0xf203ffff pref]
[    0.374612] pci 0000:00:04.0: reg 10: [io  0xc040-0xc07f]
[    0.374676] pci 0000:00:04.0: reg 14: [mem 0xf2040000-0xf2040fff]
[    0.375554] pci_bus 0000:00: on NUMA node 0
[    0.375672] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.451690] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.452518] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.453278] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.454057] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.455342] vgaarb: device added:
PCI:0000:00:02.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
[    0.455364] vgaarb: loaded
[    0.457328] SCSI subsystem initialized
[    0.457478] libata version 3.00 loaded.
[    0.458535] usbcore: registered new interface driver usbfs
[    0.458763] usbcore: registered new interface driver hub
[    0.459020] usbcore: registered new device driver usb
[    0.460897] Advanced Linux Sound Architecture Driver Version 1.0.23.
[    0.460910] PCI: Using ACPI for IRQ routing
[    0.460919] PCI: pci_cache_line_size set to 64 bytes
[    0.461462] reserve RAM buffer: 000000000009f400 - 000000000009ffff
[    0.461486] reserve RAM buffer: 000000001fffd000 - 000000001fffffff
[    0.462822] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.462887] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.462894] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.466842] Switching to clocksource kvm-clock
[    0.487027] pnp: PnP ACPI init
[    0.487089] ACPI: bus type pnp registered
[    0.494429] pnp: PnP ACPI: found 8 devices
[    0.494434] ACPI: ACPI bus type pnp unregistered
[    0.532210] pci_bus 0000:00: resource 0 [io  0x0000-0xffff]
[    0.532212] pci_bus 0000:00: resource 1 [mem 0x00000000-0xffffffff]
[    0.532322] NET: Registered protocol family 2
[    0.532555] IP route cache hash table entries: 4096 (order: 2, 16384 byt=
es)
[    0.533175] TCP established hash table entries: 16384 (order: 5,
131072 bytes)
[    0.533481] TCP bind hash table entries: 16384 (order: 7, 524288 bytes)
[    0.535102] TCP: Hash tables configured (established 16384 bind 16384)
[    0.535122] TCP reno registered
[    0.535130] UDP hash table entries: 256 (order: 2, 20480 bytes)
[    0.535175] UDP-Lite hash table entries: 256 (order: 2, 20480 bytes)
[    0.535453] NET: Registered protocol family 1
[    0.535501] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.535532] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.535584] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.535666] pci 0000:00:02.0: Boot video device
[    0.535729] PCI: CLS 0 bytes, default 64
[    0.539167] microcode: CPU0 sig=3D0x623, pf=3D0x0, revision=3D0x0
[    0.539418] microcode: Microcode Update Driver: v2.00
<tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.540620] audit: initializing netlink socket (disabled)
[    0.540676] type=3D2000 audit(1275896899.539:1): initialized
[    0.555242] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[    0.571475] VFS: Disk quotas dquot_6.5.2
[    0.571855] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.577062] OCFS2 1.5.0
[    0.577859] ocfs2: Registered cluster interface o2cb
[    0.577872] OCFS2 DLMFS 1.5.0
[    0.578243] OCFS2 User DLM kernel interface loaded
[    0.578256] OCFS2 Node Manager 1.5.0
[    0.579036] OCFS2 DLM 1.5.0
[    0.581055] Btrfs loaded
[    0.581085] msgmni has been set to 986
[    0.582106] cryptomgr_test used greatest stack depth: 6832 bytes left
[    0.583461] cryptomgr_test used greatest stack depth: 6652 bytes left
[    0.583730] alg: No test for stdrng (krng)
[    0.584265] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 253)
[    0.584292] io scheduler noop registered
[    0.584296] io scheduler deadline registered
[    0.584331] io scheduler cfq registered (default)
[    0.586228] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.588118] ALI M7101 PMU not found.
[    0.588575] vesafb: framebuffer at 0xf0000000, mapped to
0xe0880000, using 1536k, total 4096k
[    0.588582] vesafb: mode is 1024x768x8, linelength=3D1024, pages=3D4
[    0.588586] vesafb: scrolling: redraw
[    0.588594] vesafb: Pseudocolor: size=3D6:6:6:6, shift=3D0:0:0:0
[    0.591956] Console: switching to colour frame buffer device 128x48
[    0.593394] fb0: VESA VGA frame buffer device
[    0.594622] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.594668] ACPI: Power Button [PWRF]
[    0.595587] ACPI: acpi_idle registered with cpuidle
[    0.611626] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    0.611699] virtio-pci 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI
11 (level, high) -> IRQ 11
[    0.611772] virtio-pci 0000:00:03.0: setting latency timer to 64
[    0.615540] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
[    0.615674] virtio-pci 0000:00:04.0: PCI INT A -> Link[LNKD] -> GSI
10 (level, high) -> IRQ 10
[    0.615803] virtio-pci 0000:00:04.0: setting latency timer to 64
[    0.636137] Non-volatile memory driver v1.3
[    0.636565] Linux agpgart interface v0.103
[    0.637007] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180
seconds, margin is 60 seconds).
[    0.637043] Hangcheck: Using getrawmonotonic().
[    0.637069] ramoops: invalid size specification
[    0.637286] [drm] Initialized drm 1.1.0 20060810
[    0.637360] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.890932] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    0.893681] 00:06: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    0.905906] brd: module loaded
[    0.911846] loop: module loaded
[    0.912232] virtio-pci 0000:00:04.0: irq 40 for MSI/MSI-X
[    0.912265] virtio-pci 0000:00:04.0: irq 41 for MSI/MSI-X
[    0.931835]  vda: vda1 vda2
[    0.934704] Uniform Multi-Platform E-IDE driver
[    0.935161] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    0.935351] piix 0000:00:01.1: not 100% native mode: will probe irqs lat=
er
[    0.935409]     ide0: BM-DMA at 0xc000-0xc007
[    0.936381]     ide1: BM-DMA at 0xc008-0xc00f
[    0.936865] Probing IDE interface ide0...
[    1.477215] Probing IDE interface ide1...
[    2.177152] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    2.817200] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    2.817301] hdc: MWDMA2 mode selected
[    2.818636] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    2.819097] ide1 at 0x170-0x177,0x376 on irq 15
[    2.820548] ide_generic: please use "probe_mask=3D0x3f" module
parameter for probing all legacy ISA IDE ports
[    2.820924] ide-gd driver 1.18
[    2.822003] Loading iSCSI transport class v2.0-870.
[    2.827720] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    2.828106] e100: Copyright(c) 1999-2006 Intel Corporation
[    2.829042] sky2: driver version 1.28
[    2.829602] PPP generic driver version 2.4.2
[    2.830552] PPP Deflate Compression module registered
[    2.830942] PPP BSD Compression module registered
[    2.831996] PPP MPPE Compression module registered
[    2.833164] NET: Registered protocol family 24
[    2.834361] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels,
max=3D256) (6 bit encapsulation enabled).
[    2.835027] CSLIP: code copyright 1989 Regents of the University of
California.
[    2.835483] SLIP linefill/keepalive option.
[    2.835995] console [netcon0] enabled
[    2.836430] netconsole: network logging started
[    2.837363] virtio-pci 0000:00:03.0: irq 42 for MSI/MSI-X
[    2.837396] virtio-pci 0000:00:03.0: irq 43 for MSI/MSI-X
[    2.837428] virtio-pci 0000:00:03.0: irq 44 for MSI/MSI-X
[    2.868464] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.870350] uhci_hcd: USB Universal Host Controller Interface driver
[    2.871225] Initializing USB Mass Storage driver...
[    2.871936] usbcore: registered new interface driver usb-storage
[    2.872356] USB Mass Storage support registered.
[    2.873128] usbcore: registered new interface driver libusual
[    2.874060] usbcore: registered new interface driver usbserial
[    2.874652] USB Serial support registered for generic
[    2.875267] usbcore: registered new interface driver usbserial_generic
[    2.875662] usbserial: USB Serial Driver core
[    2.876487] PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at
0x60,0x64 irq 1,12
[    2.878495] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.878924] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.880441] mice: PS/2 mouse device common for all mice
[    2.882712] input: AT Translated Set 2 keyboard as
/devices/platform/i8042/serio0/input/input1
[    2.889364] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    2.889979] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[    2.890653] i2c /dev entries driver
[    2.892054] piix4_smbus 0000:00:01.3: SMBus Host Controller at
0xb100, revision 0
[    2.893908] coretemp: CPU (model=3D0x2) has no thermal sensor.
[    2.894757] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.06
[    2.895642] iTCO_wdt: No card detected
[    2.896057] iTCO_vendor_support: vendor-support=3D0
[    2.897866] device-mapper: ioctl: 4.17.0-ioctl (2010-03-05)
initialised: dm-devel@redhat.com
[    2.899836] device-mapper: dm-log-userspace: version 1.0.0 loaded
[    2.900956] cpuidle: using governor ladder
[    2.901523] cpuidle: using governor menu
[    2.902791] dcdbas dcdbas: Dell Systems Management Base Driver
(version 5.6.0-3.2)
[    2.909647] usbcore: registered new interface driver hiddev
[    2.911138] usbcore: registered new interface driver usbhid
[    2.911552] usbhid: USB HID core driver
[    2.911962] ALSA device list:
[    2.912361]   No soundcards found.
[    2.912786] Netfilter messages via NETLINK v0.30.
[    2.913276] nf_conntrack version 0.5.0 (7893 buckets, 31572 max)
[    2.914611] ctnetlink v0.93: registering with nfnetlink.
[    2.916207] ip_tables: (C) 2000-2006 Netfilter Core Team
[    2.916822] TCP cubic registered
[    2.917220] NET: Registered protocol family 17
[    2.917883] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com=
>
[    2.918287] All bugs added by David S. Miller <davem@redhat.com>
[    2.918750] lib80211: common routines for IEEE802.11 drivers
[    2.919171] lib80211_crypt: registered algorithm 'NULL'
[    2.919329] Using IPI No-Shortcut mode
[    2.920485] PM: Resume from disk failed.
[    2.920551] registered taskstats version 1
[    2.921053] kmemleak: Kernel memory leak detector initialized
[    2.921869]   Magic number: 14:901:840
[    2.922309] BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
[    2.922871] kmemleak: Automatic memory scanning thread started
[    2.923529] Initalizing network drop monitor service
[    3.089273] input: ImExPS/2 Generic Explorer Mouse as
/devices/platform/i8042/serio1/input/input2
[    3.091182] md: Waiting for all devices to be available before autodetec=
t
[    3.091591] md: If you don't use raid, use raid=3Dnoautodetect
[    3.093396] md: Autodetecting RAID arrays.
[    3.093807] md: Scanned 0 and added 0 devices.
[    3.094234] md: autorun ...
[    3.094637] md: ... autorun DONE.
[    3.098939] EXT4-fs (vda2): mounted filesystem with ordered data
mode. Opts: (null)
[    3.099434] VFS: Mounted root (ext4 filesystem) readonly on device 253:2=
.
[    3.099923] Freeing unused kernel memory: 484k freed
[    3.106435] Write protecting the kernel text: 4836k
[    3.125907] Write protecting the kernel read-only data: 2332k
[    3.176963] mount used greatest stack depth: 6172 bytes left
[    3.187162] grep used greatest stack depth: 6148 bytes left
[    3.246353] sed used greatest stack depth: 6000 bytes left
[    3.405101] udevd used greatest stack depth: 5908 bytes left
[    4.648317] vol_id used greatest stack depth: 5848 bytes left
[    6.467111] Adding 208808k swap on /dev/vda1.  Priority:-1
extents:1 across:208808k
[    6.521158] fuse init (API version 7.14)
[    7.372612] EXT4-fs (vda2): re-mounted. Opts: (null)
[    7.406416] JBD: barrier-based sync failed on vda2-8 - disabling barrier=
s
[    7.470224] EXT4-fs (vda2): re-mounted. Opts: (null)
[    7.473650] mount used greatest stack depth: 5764 bytes left
[    7.632695] 8139cp: 8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 200=
4)
[   10.842385] rc.S used greatest stack depth: 5472 bytes left
[   13.403327] JBD: barrier-based sync failed on vda2-8 - disabling barrier=
s
[   91.990395] git used greatest stack depth: 5400 bytes left
[  664.731399] BUG: unable to handle kernel paging request at 07200824
[  664.731412] IP: [<c1053be5>] __lock_acquire+0xbb/0xc93
[  664.731456] *pde =3D 00000000
[  664.731458] Oops: 0002 [#1] SMP
[  664.731466] last sysfs file: /sys/devices/virtual/vc/vcsa7/dev
[  664.731474] Modules linked in: 8139cp fuse
[  664.731486]
[  664.731494] Pid: 758, comm: kmemleak Not tainted 2.6.35-rc1-mm1 #9 /Boch=
s
[  664.731496] EIP: 0060:[<c1053be5>] EFLAGS: 00010002 CPU: 0
[  664.731499] EIP is at __lock_acquire+0xbb/0xc93
[  664.731501] EAX: 00000001 EBX: 07200720 ECX: df15de20 EDX: 00000000
[  664.731503] ESI: 00000000 EDI: 00000002 EBP: dec1ff18 ESP: dec1fe78
[  664.731505]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[  664.731507] Process kmemleak (pid: 758, ti=3Ddec1e000 task=3Ddec3bd80
task.ti=3Ddec1e000)
[  664.731509] Stack:
[  664.731510]  dec1fe80 c10532be dec1fe8c 00000005 5803801e dec3c230
0000001e 00000000
[  664.731515] <0> df15de20 dec3bd80 00000002 00000000 dec3bd80
c183cb68 c183c968 c183c768
[  664.731521] <0> c183c568 c197f444 c1033409 00000002 dec1fed8
00000006 dec1fecc dec3c238
[  664.731527] Call Trace:
[  664.731531]  [<c10532be>] ? trace_hardirqs_on+0xb/0xd
[  664.731546]  [<c1033409>] ? __do_softirq+0x4f/0x170
[  664.731549]  [<c1052d32>] ? mark_lock+0x1e/0x21c
[  664.731552]  [<c1052f73>] ? mark_held_locks+0x43/0x5b
[  664.731554]  [<c105485e>] ? lock_acquire+0xa1/0xc4
[  664.731568]  [<c10c64b9>] ? kmemleak_scan+0x40/0x3ef
[  664.731594]  [<c14b2d92>] ? _raw_spin_lock_irqsave+0x2f/0x3f
[  664.731598]  [<c10c64b9>] ? kmemleak_scan+0x40/0x3ef
[  664.731600]  [<c10c64b9>] ? kmemleak_scan+0x40/0x3ef
[  664.731603]  [<c10c6c3d>] ? kmemleak_scan_thread+0x0/0x91
[  664.731606]  [<c14b23bb>] ? mutex_lock_nested+0x30/0x38
[  664.731609]  [<c10c6c3d>] ? kmemleak_scan_thread+0x0/0x91
[  664.731611]  [<c10c6c92>] ? kmemleak_scan_thread+0x55/0x91
[  664.731619]  [<c1043199>] ? kthread+0x61/0x66
[  664.731622]  [<c1043138>] ? kthread+0x0/0x66
[  664.731629]  [<c1002dfa>] ? kernel_thread_helper+0x6/0x10
[  664.731631] Code: 00 81 39 04 d4 84 c1 0f 44 f8 85 f6 75 07 8b 59
04 85 db 75 16 31 c9 89 f2 8b 45 80 e8 93 e6 ff ff 89 c3 85 c0 0f 84
5f 0b 00 00 <3e> ff 83 04 01 00 00 8b 35 20 b7 7f c1 8b 45 84 85 f6 8b
80 80
[  664.731662] EIP: [<c1053be5>] __lock_acquire+0xbb/0xc93 SS:ESP 0068:dec1=
fe78
[  664.731666] CR2: 0000000007200824
[  664.731669] ---[ end trace 5a5a88cab8c70071 ]---

--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
