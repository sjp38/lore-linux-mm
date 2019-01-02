Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33A3E8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 20:04:16 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 41so37395418qto.17
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 17:04:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r55sor43347215qtb.7.2019.01.01.17.04.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 17:04:14 -0800 (PST)
MIME-Version: 1.0
References: <CALaQ_hpCKoLxp-0cgxw9TqPGBSzY7RhrnFZ0jGAQ11HbOZkZ3w@mail.gmail.com>
In-Reply-To: <CALaQ_hpCKoLxp-0cgxw9TqPGBSzY7RhrnFZ0jGAQ11HbOZkZ3w@mail.gmail.com>
From: Nathan Royce <nroycea+kernel@gmail.com>
Date: Tue, 1 Jan 2019 19:04:02 -0600
Message-ID: <CALaQ_hpfSBM7sY0dW-k32K2wDyTHuYJm_V1gMc46nG7ZBiPazQ@mail.gmail.com>
Subject: Re: kmemleak: Cannot allocate a kmemleak_object structure - Kernel 4.19.13
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, catalin.marinas@arm.com

It was unrelated to my USB issue. It happened again after I rebooted
within 4 hours of uptime.
This time there were 2 traces, one right after the other and included
another line number.
*****
Jan 01 17:47:54 computername plasmashell[1048]: qt.qpa.xcb:
QXcbConnection: XCB error: 2 (BadValue), sequence: 45625, resource id:
69206018, major code: 142 (Unknown), minor code: 3
Jan 01 17:50:14 computername kernel: WARNING: CPU: 3 PID: 2154 at
mm/page_alloc.c:4262 __alloc_pages_nodemask+0xf74/0xfb0
Jan 01 17:50:15 computername kernel: Modules linked in: rfcomm ccm
bnep nct6775 hwmon_vid nls_iso8859_1 nls_cp437 vfat fat tda18271
au8522_dig au8522_common au0828 tveeprom dvb_core arc4 v4l2_common
intel_rapl snd_soc_rt5640 iTCO_wdt rtl8821ae x86_pkg_temp_thermal
btcoexist i>
Jan 01 17:50:16 computername kernel:  soundcore mei_me lpc_ich mei
crypto_user ip_tables x_tables serpent_avx2 serpent_avx_x86_64
serpent_sse2_x86_64 serpent_generic xts algif_skcipher af_alg uas
usb_storage dm_crypt dm_mod sr_mod cdrom sd_mod hid_logitech_hidpp
hid_logitech_>
Jan 01 17:50:16 computername kernel: CPU: 3 PID: 2154 Comm:
PeripBusCEC Not tainted 4.19.13-dirty #2
Jan 01 17:50:16 computername kernel: Hardware name: To Be Filled By
O.E.M. To Be Filled By O.E.M./H97M-ITX/ac, BIOS P1.80 07/27/2015
Jan 01 17:50:16 computername kernel: RIP:
0010:__alloc_pages_nodemask+0xf74/0xfb0
Jan 01 17:50:16 computername kernel: Code: ff 0f 0b e9 dc fc ff ff 0f
0b 48 8b b4 24 80 00 00 00 8b 7c 24 18 44 89 f1 48 c7 c2 40 9e 4a b6
e8 91 ef ff ff e9 d3 f1 ff ff <0f> 0b e9 a9 fc ff ff e8 c0 7f ea ff 85
d2 0f 85 15 fd ff ff 48 c7
Jan 01 17:50:16 computername kernel: RSP: 0018:ffff999e032731e0 EFLAGS: 00010202
Jan 01 17:50:16 computername kernel: RAX: ffff8bbcbabc0040 RBX:
0000000000400000 RCX: 0000000000200000
Jan 01 17:50:16 computername kernel: RDX: 0000000000000000 RSI:
0000000000000002 RDI: ffff8bbd9fdfc000
Jan 01 17:50:16 computername kernel: RBP: 0000000000200000 R08:
0000000000000040 R09: 0000000000000f82
Jan 01 17:50:16 computername kernel: R10: 0000000000200000 R11:
0000000000000000 R12: 0000000000000000
Jan 01 17:50:16 computername kernel: R13: 0000000000000000 R14:
0000000000000000 R15: 0000000000000000
Jan 01 17:50:16 computername kernel: FS:  00007f9515642700(0000)
GS:ffff8bbd98180000(0000) knlGS:0000000000000000
Jan 01 17:50:16 computername kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Jan 01 17:50:16 computername kernel: CR2: 00007fdbd95b1000 CR3:
000000011087c003 CR4: 00000000001626e0
Jan 01 17:50:16 computername kernel: Call Trace:
Jan 01 17:50:16 computername kernel:  ? ___slab_alloc+0x43f/0x630
Jan 01 17:50:16 computername kernel:  ? orc_find+0x108/0x190
Jan 01 17:50:16 computername kernel:  ? kmem_cache_alloc+0x1c5/0x210
Jan 01 17:50:16 computername kernel:  ? unwind_next_frame+0x2f8/0x460
Jan 01 17:50:16 computername kernel:  new_slab+0x2fb/0x6f0
Jan 01 17:50:16 computername kernel:  ? _raw_spin_unlock+0x16/0x30
Jan 01 17:50:16 computername kernel:  ? deactivate_slab.isra.27+0x5b4/0x690
Jan 01 17:50:16 computername kernel:  ___slab_alloc+0x43f/0x630
Jan 01 17:50:16 computername kernel:  ? alloc_extent_state+0x1f/0xd0 [btrfs]
Jan 01 17:50:16 computername kernel:  ? create_object+0x43/0x2a0
Jan 01 17:50:16 computername kernel:  ? ___slab_alloc+0x58d/0x630
Jan 01 17:50:16 computername kernel:  ? create_object+0x43/0x2a0
Jan 01 17:50:16 computername kernel:  __slab_alloc.isra.28+0x52/0x70
Jan 01 17:50:16 computername kernel:  ? create_object+0x43/0x2a0
Jan 01 17:50:16 computername kernel:  kmem_cache_alloc+0x1c5/0x210
Jan 01 17:50:16 computername kernel:  ? alloc_extent_state+0x1f/0xd0 [btrfs]
Jan 01 17:50:16 computername kernel:  create_object+0x43/0x2a0
Jan 01 17:50:16 computername kernel:  ? alloc_extent_state+0x1f/0xd0 [btrfs]
Jan 01 17:50:16 computername kernel:  kmem_cache_alloc+0x1a6/0x210
Jan 01 17:50:16 computername kernel:  alloc_extent_state+0x1f/0xd0 [btrfs]
Jan 01 17:50:16 computername kernel:  __clear_extent_bit+0x297/0x390 [btrfs]
Jan 01 17:50:16 computername kernel:  ? _raw_spin_unlock+0x16/0x30
Jan 01 17:50:16 computername kernel:
try_release_extent_mapping+0x1b4/0x220 [btrfs]
Jan 01 17:50:16 computername kernel:  btrfs_releasepage+0x45/0x60 [btrfs]
Jan 01 17:50:16 computername kernel:  shrink_page_list+0xb20/0xc80
Jan 01 17:50:16 computername kernel:  shrink_inactive_list+0x29f/0x6b0
Jan 01 17:50:16 computername kernel:  shrink_node_memcg+0x20f/0x780
Jan 01 17:50:16 computername kernel:  shrink_node+0xcf/0x4a0
Jan 01 17:50:16 computername kernel:  do_try_to_free_pages+0xc6/0x370
Jan 01 17:50:16 computername kernel:  try_to_free_pages+0xca/0x1e0
Jan 01 17:50:16 computername kernel:  __alloc_pages_nodemask+0x616/0xfb0
Jan 01 17:50:16 computername kernel:  ? __kernel_text_address+0xe/0x30
Jan 01 17:50:16 computername kernel:  ? unwind_get_return_address+0x1b/0x30
Jan 01 17:50:16 computername kernel:  ? __save_stack_trace+0x92/0x100
Jan 01 17:50:16 computername kernel:  new_slab+0x2fb/0x6f0
Jan 01 17:50:16 computername kernel:  ___slab_alloc+0x43f/0x630
Jan 01 17:50:16 computername kernel:  ? __alloc_file+0x2a/0xe0
Jan 01 17:50:16 computername kernel:  ? unwind_get_return_address+0x1b/0x30
Jan 01 17:50:16 computername kernel:  ? preempt_count_add+0x79/0xb0
Jan 01 17:50:16 computername kernel:  ? _raw_spin_lock+0x13/0x40
Jan 01 17:50:16 computername kernel:  ? _raw_spin_unlock+0x16/0x30
Jan 01 17:50:16 computername kernel:  ? deactivate_slab.isra.27+0x5b4/0x690
Jan 01 17:50:16 computername kernel:  ? __alloc_file+0x2a/0xe0
Jan 01 17:50:16 computername kernel:  __slab_alloc.isra.28+0x52/0x70
Jan 01 17:50:16 computername kernel:  ? __alloc_file+0x2a/0xe0
Jan 01 17:50:16 computername kernel:  kmem_cache_alloc+0x1c5/0x210
Jan 01 17:50:16 computername kernel:  __alloc_file+0x2a/0xe0
Jan 01 17:50:16 computername kernel:  alloc_empty_file+0x43/0xc0
Jan 01 17:50:16 computername kernel:  ? getname_flags+0x4a/0x1e0
Jan 01 17:50:16 computername kernel:  path_openat+0x4c/0x14e0
Jan 01 17:50:16 computername kernel:  ? is_bpf_text_address+0x1e/0x30
Jan 01 17:50:16 computername kernel:  ? kernel_text_address+0xe5/0xf0
Jan 01 17:50:16 computername kernel:  ? __kernel_text_address+0xe/0x30
Jan 01 17:50:16 computername kernel:  ? unwind_get_return_address+0x1b/0x30
Jan 01 17:50:16 computername kernel:  ? __save_stack_trace+0x92/0x100
Jan 01 17:50:16 computername kernel:  do_filp_open+0x93/0x100
Jan 01 17:50:16 computername kernel:  ? preempt_count_add+0x79/0xb0
Jan 01 17:50:16 computername kernel:  ? _raw_write_lock_irqsave+0x25/0x50
Jan 01 17:50:16 computername kernel:  ? _raw_write_unlock_irqrestore+0x1c/0x30
Jan 01 17:50:16 computername kernel:  ? create_object+0x249/0x2a0
Jan 01 17:50:16 computername kernel:  ? __check_object_size+0x102/0x189
Jan 01 17:50:16 computername kernel:  ? _raw_spin_unlock+0x16/0x30
Jan 01 17:50:16 computername kernel:  do_sys_open+0x186/0x210
Jan 01 17:50:16 computername kernel:  do_syscall_64+0x5b/0x170
Jan 01 17:50:16 computername kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9
Jan 01 17:50:16 computername kernel: RIP: 0033:0x7f9551bb8976
Jan 01 17:50:16 computername kernel: Code: 89 54 24 08 e8 7b f4 ff ff
8b 74 24 0c 48 8b 3c 24 41 89 c0 44 8b 54 24 08 b8 01 01 00 00 89 f2
48 89 fe bf 9c ff ff ff 0f 05 <48> 3d 00 f0 ff ff 77 30 44 89 c7 89 44
24 08 e8 a6 f4 ff ff 8b 44
Jan 01 17:50:16 computername kernel: RSP: 002b:00007f951563c0d0
EFLAGS: 00000293 ORIG_RAX: 0000000000000101
Jan 01 17:50:16 computername kernel: RAX: ffffffffffffffda RBX:
00007f94f80adb40 RCX: 00007f9551bb8976
Jan 01 17:50:16 computername kernel: RDX: 00000000002a0000 RSI:
00007f954f9693da RDI: 00000000ffffff9c
Jan 01 17:50:16 computername kernel: RBP: 00007f951563c2b0 R08:
0000000000000000 R09: 0000000000000018
Jan 01 17:50:16 computername kernel: R10: 0000000000000000 R11:
0000000000000293 R12: 0000000000000000
Jan 01 17:50:16 computername kernel: R13: 00007f94f80e4640 R14:
0000000000000001 R15: 000000000000000a
Jan 01 17:50:16 computername kernel: ---[ end trace 2a9048666fdb2310 ]---
Jan 01 17:50:16 computername kernel: WARNING: CPU: 0 PID: 12528 at
mm/page_alloc.c:4254 __alloc_pages_nodemask+0xf52/0xfb0
Jan 01 17:50:16 computername kernel: Modules linked in: rfcomm ccm
bnep nct6775 hwmon_vid nls_iso8859_1 nls_cp437 vfat fat tda18271
au8522_dig au8522_common au0828 tveeprom dvb_core arc4 v4l2_common
intel_rapl snd_soc_rt5640 iTCO_wdt rtl8821ae x86_pkg_temp_thermal
btcoexist i>
Jan 01 17:50:16 computername kernel:  soundcore mei_me lpc_ich mei
crypto_user ip_tables x_tables serpent_avx2 serpent_avx_x86_64
serpent_sse2_x86_64 serpent_generic xts algif_skcipher af_alg uas
usb_storage dm_crypt dm_mod sr_mod cdrom sd_mod hid_logitech_hidpp
hid_logitech_>
Jan 01 17:50:16 computername kernel: CPU: 0 PID: 12528 Comm:
kworker/u9:5 Tainted: G        W         4.19.13-dirty #2
Jan 01 17:50:16 computername kernel: Hardware name: To Be Filled By
O.E.M. To Be Filled By O.E.M./H97M-ITX/ac, BIOS P1.80 07/27/2015
Jan 01 17:50:16 computername kernel: Workqueue: kcryptd kcryptd_crypt [dm_crypt]
Jan 01 17:50:16 computername kernel: RIP:
0010:__alloc_pages_nodemask+0xf52/0xfb0
Jan 01 17:50:16 computername kernel: Code: c7 44 24 54 00 00 00 00 25
ff ff f7 ff 89 44 24 18 e9 ea f3 ff ff 48 89 9c 24 80 00 00 00 e9 ad
f3 ff ff 0f 0b e9 dc fc ff ff <0f> 0b 48 8b b4 24 80 00 00 00 8b 7c 24
18 44 89 f1 48 c7 c2 40 9e
Jan 01 17:50:16 computername kernel: RSP: 0018:ffff999e030ef9f0 EFLAGS: 00010046
Jan 01 17:50:16 computername kernel: RAX: 0000000000000000 RBX:
0000000000400000 RCX: 0000000000000000
Jan 01 17:50:16 computername kernel: RDX: 0000000000000000 RSI:
0000000000000002 RDI: ffff8bbd9fdfc000
Jan 01 17:50:16 computername kernel: RBP: 0000000000000000 R08:
0000000000000040 R09: 0000000000000f82
Jan 01 17:50:16 computername kernel: R10: 0000000000000000 R11:
0000000000000000 R12: 0000000000000000
Jan 01 17:50:16 computername kernel: R13: 0000000000000000 R14:
0000000000000000 R15: 0000000000000000
Jan 01 17:50:16 computername kernel: FS:  0000000000000000(0000)
GS:ffff8bbd98000000(0000) knlGS:0000000000000000
Jan 01 17:50:16 computername kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Jan 01 17:50:16 computername kernel: CR2: 00005636c5b233d0 CR3:
0000000150a0a006 CR4: 00000000001626f0
Jan 01 17:50:16 computername kernel: Call Trace:
Jan 01 17:50:16 computername kernel:  ? orc_find+0x108/0x190
Jan 01 17:50:16 computername kernel:  ? unwind_next_frame+0x121/0x460
Jan 01 17:50:16 computername kernel:  ? kcryptd_crypt+0x1d1/0x3a0 [dm_crypt]
Jan 01 17:50:16 computername kernel:  ? _raw_spin_lock+0x2e/0x40
Jan 01 17:50:16 computername kernel:  ? _raw_spin_unlock+0x16/0x30
Jan 01 17:50:16 computername kernel:  new_slab+0x2fb/0x6f0
Jan 01 17:50:16 computername kernel:  ? _raw_spin_lock+0x13/0x40
Jan 01 17:50:16 computername kernel:  ? deactivate_slab.isra.27+0x5b4/0x690
Jan 01 17:50:16 computername kernel:  ___slab_alloc+0x43f/0x630
Jan 01 17:50:16 computername kernel:  ? create_object+0x43/0x2a0
Jan 01 17:50:16 computername kernel:  ? ___slab_alloc+0x58d/0x630
Jan 01 17:50:16 computername kernel:  ? create_object+0x43/0x2a0
Jan 01 17:50:16 computername kernel:  __slab_alloc.isra.28+0x52/0x70
Jan 01 17:50:16 computername kernel:  ? create_object+0x43/0x2a0
Jan 01 17:50:16 computername kernel:  kmem_cache_alloc+0x1c5/0x210
Jan 01 17:50:16 computername kernel:  ? mempool_alloc+0x65/0x180
Jan 01 17:50:16 computername kernel:  create_object+0x43/0x2a0
Jan 01 17:50:16 computername kernel:  ? mempool_alloc+0x65/0x180
Jan 01 17:50:16 computername kernel:  kmem_cache_alloc+0x1a6/0x210
Jan 01 17:50:16 computername kernel:  ? wait_woken+0x80/0x80
Jan 01 17:50:16 computername kernel:  mempool_alloc+0x65/0x180
Jan 01 17:50:16 computername kernel:  ? crypt_convert+0x96b/0xf50 [dm_crypt]
Jan 01 17:50:16 computername kernel:  bio_alloc_bioset+0x14c/0x220
Jan 01 17:50:16 computername kernel:  ? _raw_spin_lock_irqsave+0x25/0x50
Jan 01 17:50:16 computername kernel:  kcryptd_crypt+0x1d1/0x3a0 [dm_crypt]
Jan 01 17:50:16 computername kernel:  process_one_work+0x1eb/0x410
Jan 01 17:50:16 computername kernel:  worker_thread+0x2d/0x3d0
Jan 01 17:50:16 computername kernel:  ? process_one_work+0x410/0x410
Jan 01 17:50:16 computername kernel:  kthread+0x112/0x130
Jan 01 17:50:16 computername kernel:  ? kthread_park+0x80/0x80
Jan 01 17:50:16 computername kernel:  ret_from_fork+0x35/0x40
Jan 01 17:50:16 computername kernel: ---[ end trace 2a9048666fdb2311 ]---
Jan 01 17:50:16 computername kernel: kmemleak: Cannot allocate a
kmemleak_object structure
Jan 01 17:50:16 computername kernel: kmemleak: Kernel memory leak
detector disabled
Jan 01 17:50:16 computername kernel: kmemleak: Automatic memory
scanning thread ended
Jan 01 17:50:16 computername kernel: kmemleak: Kmemleak disabled
without freeing internal data. Reclaim the memory with "echo clear >
/sys/kernel/debug/kmemleak".
Jan 01 17:50:25 computername plasmashell[1048]: qt.qpa.xcb:
QXcbConnection: XCB error: 2 (BadValue), sequence: 47417, resource id:
71303170, major code: 142 (Unknown), minor code: 3
*****

On Tue, Jan 1, 2019 at 1:17 PM Nathan Royce <nroycea+kernel@gmail.com> wrote:
>
> Kernel 4.19.13
>
> *****
> Jan 01 02:04:20 computername kernel: xhci_hcd 0000:00:14.0: ERROR
> unknown event type 37
> Jan 01 02:04:20 computername kernel: WARNING: CPU: 2 PID: 2236 at
> mm/page_alloc.c:4254 __alloc_pages_nodemask+0xf52/0xfb0
> Jan 01 02:04:20 computername kernel: Modules linked in: rfcomm ccm
> bnep nct6775 hwmon_vid nls_iso8859_1 nls_cp437 vfat fat tda18271
> au8522_dig au8522_common au0828 snd_usb_audio tveeprom snd_usbmidi_lib
> dvb_core mousedev snd_rawmidi snd_seq_device btusb v4l2_common btrtl
> vide>
> Jan 01 02:04:20 computername kernel:  llc intel_rapl_perf soundcore
> alx i2c_i801 mdio evdev lpc_ich mei_me mei pcc_cpufreq mac_hid
> crypto_user ip_tables x_tables serpent_avx2 serpent_avx_x86_64
> serpent_sse2_x86_64 serpent_generic xts algif_skcipher af_alg uas
> usb_storage dm_c>
> Jan 01 02:04:20 computername kernel: CPU: 2 PID: 2236 Comm:
> MainLoopThread Tainted: G        W         4.19.13-dirty #2
> Jan 01 02:04:20 computername kernel: Hardware name: To Be Filled By
> O.E.M. To Be Filled By O.E.M./H97M-ITX/ac, BIOS P1.80 07/27/2015
> Jan 01 02:04:20 computername kernel: RIP:
> 0010:__alloc_pages_nodemask+0xf52/0xfb0
> Jan 01 02:04:20 computername kernel: Code: c7 44 24 54 00 00 00 00 25
> ff ff f7 ff 89 44 24 18 e9 ea f3 ff ff 48 89 9c 24 80 00 00 00 e9 ad
> f3 ff ff 0f 0b e9 dc fc ff ff <0f> 0b 48 8b b4 24 80 00 00 00 8b 7c 24
> 18 44 89 f1 48 c7 c2 40 9e
> Jan 01 02:04:20 computername kernel: RSP: 0018:ffffaf9f81066e90 EFLAGS: 00010046
> Jan 01 02:04:20 computername kernel: RAX: 0000000000000000 RBX:
> 0000000000400000 RCX: 0000000000000000
> Jan 01 02:04:20 computername kernel: RDX: 0000000000000000 RSI:
> 0000000000000002 RDI: ffff9d26dfdfc000
> Jan 01 02:04:20 computername kernel: RBP: 0000000000000000 R08:
> 0000000000000040 R09: 0000000000000f82
> Jan 01 02:04:20 computername kernel: R10: 0000000000000000 R11:
> 0000000000000000 R12: 0000000000000000
> Jan 01 02:04:20 computername kernel: R13: 0000000000000000 R14:
> 0000000000000000 R15: 0000000000000000
> Jan 01 02:04:20 computername kernel: FS:  00007f7db94d5700(0000)
> GS:ffff9d26d8100000(0000) knlGS:0000000000000000
> Jan 01 02:04:20 computername kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
> 0000000080050033
> Jan 01 02:04:20 computername kernel: CR2: 0000000092c9da10 CR3:
> 00000001baefe002 CR4: 00000000001626e0
> Jan 01 02:04:20 computername kernel: Call Trace:
> Jan 01 02:04:20 computername kernel:  ?
> __dm_make_request.isra.18+0x3f/0xa0 [dm_mod]
> Jan 01 02:04:20 computername kernel:  ? orc_find+0x108/0x190
> Jan 01 02:04:20 computername kernel:  ? do_try_to_free_pages+0xc6/0x370
> Jan 01 02:04:20 computername kernel:  new_slab+0x2fb/0x6f0
> Jan 01 02:04:20 computername kernel:  ? _raw_spin_lock+0x13/0x40
> Jan 01 02:04:20 computername kernel:  ? deactivate_slab.isra.27+0x5b4/0x690
> Jan 01 02:04:20 computername kernel:  ___slab_alloc+0x43f/0x630
> Jan 01 02:04:20 computername kernel:  ? create_object+0x43/0x2a0
> Jan 01 02:04:20 computername kernel:  ? ___slab_alloc+0x58d/0x630
> Jan 01 02:04:20 computername kernel:  ? create_object+0x43/0x2a0
> Jan 01 02:04:20 computername kernel:  __slab_alloc.isra.28+0x52/0x70
> Jan 01 02:04:20 computername kernel:  ? create_object+0x43/0x2a0
> Jan 01 02:04:20 computername kernel:  kmem_cache_alloc+0x1c5/0x210
> Jan 01 02:04:20 computername kernel:  ? mempool_alloc+0x65/0x180
> Jan 01 02:04:20 computername kernel:  create_object+0x43/0x2a0
> Jan 01 02:04:20 computername kernel:  ? mempool_alloc+0x65/0x180
> Jan 01 02:04:20 computername kernel:  kmem_cache_alloc+0x1a6/0x210
> Jan 01 02:04:20 computername kernel:  ? wait_woken+0x80/0x80
> Jan 01 02:04:20 computername kernel:  mempool_alloc+0x65/0x180
> Jan 01 02:04:20 computername kernel:  ? __process_bio+0x170/0x170 [dm_mod]
> Jan 01 02:04:20 computername kernel:  bio_alloc_bioset+0x14c/0x220
> Jan 01 02:04:20 computername kernel:  ? create_object+0x249/0x2a0
> Jan 01 02:04:20 computername kernel:  ? __process_bio+0x170/0x170 [dm_mod]
> Jan 01 02:04:20 computername kernel:  alloc_io+0x24/0x120 [dm_mod]
> Jan 01 02:04:20 computername kernel:
> __split_and_process_bio+0x53/0x1a0 [dm_mod]
> Jan 01 02:04:20 computername kernel:  ? generic_make_request_checks+0x49a/0x6f0
> Jan 01 02:04:20 computername kernel:  ? blk_queue_enter+0x233/0x260
> Jan 01 02:04:20 computername kernel:
> __dm_make_request.isra.18+0x3f/0xa0 [dm_mod]
> Jan 01 02:04:20 computername kernel:  generic_make_request+0x1b9/0x3d0
> Jan 01 02:04:20 computername kernel:  ? __se_sys_madvise.cold.2+0xbd/0xbd
> Jan 01 02:04:20 computername kernel:  submit_bio+0x45/0x140
> Jan 01 02:04:20 computername kernel:  __swap_writepage+0x133/0x3c0
> Jan 01 02:04:20 computername kernel:  ? __frontswap_store+0x6e/0xf0
> Jan 01 02:04:20 computername kernel:  shmem_writepage+0x229/0x310
> Jan 01 02:04:20 computername kernel:  pageout.isra.11+0x117/0x350
> Jan 01 02:04:20 computername kernel:  shrink_page_list+0x7ea/0xc80
> Jan 01 02:04:20 computername kernel:  shrink_inactive_list+0x29f/0x6b0
> Jan 01 02:04:20 computername kernel:  shrink_node_memcg+0x20f/0x780
> Jan 01 02:04:20 computername kernel:  shrink_node+0xcf/0x4a0
> Jan 01 02:04:20 computername kernel:  do_try_to_free_pages+0xc6/0x370
> Jan 01 02:04:20 computername kernel:  try_to_free_pages+0xca/0x1e0
> Jan 01 02:04:20 computername kernel:  __alloc_pages_nodemask+0x616/0xfb0
> Jan 01 02:04:20 computername kernel:  ? reweight_entity+0x15b/0x1a0
> Jan 01 02:04:20 computername kernel:  ? check_preempt_wakeup+0x113/0x230
> Jan 01 02:04:20 computername kernel:  __get_free_pages+0xd/0x30
> Jan 01 02:04:20 computername kernel:  __pollwait+0x8a/0xd0
> Jan 01 02:04:20 computername kernel:  tcp_poll+0x3a/0x260
> Jan 01 02:04:20 computername kernel:  sock_poll+0x83/0xb0
> Jan 01 02:04:20 computername kernel:  do_sys_poll+0x252/0x520
> Jan 01 02:04:20 computername kernel:  ? ioapic_service+0x117/0x140 [kvm]
> Jan 01 02:04:20 computername kernel:  ? poll_initwait+0x40/0x40
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  ?
> compat_poll_select_copy_remaining+0x150/0x150
> Jan 01 02:04:20 computername kernel:  __se_sys_ppoll+0x154/0x180
> Jan 01 02:04:20 computername kernel:  ? ksys_ioctl+0x71/0x90
> Jan 01 02:04:20 computername kernel:  do_syscall_64+0x5b/0x170
> Jan 01 02:04:20 computername kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> Jan 01 02:04:20 computername kernel: RIP: 0033:0x7f7dc5d22d16
> Jan 01 02:04:20 computername kernel: Code: 7c 24 08 e8 6c 84 01 00 41
> b8 08 00 00 00 4c 8b 54 24 18 48 89 da 41 89 c1 48 8b 74 24 10 48 8b
> 7c 24 08 b8 0f 01 00 00 0f 05 <48> 3d 00 f0 ff ff 77 25 44 89 cf 89 44
> 24 08 e8 96 84 01 00 8b 44
> Jan 01 02:04:20 computername kernel: RSP: 002b:00007f7db94d4540
> EFLAGS: 00000293 ORIG_RAX: 000000000000010f
> Jan 01 02:04:20 computername kernel: RAX: ffffffffffffffda RBX:
> 00007f7db94d4560 RCX: 00007f7dc5d22d16
> Jan 01 02:04:20 computername kernel: RDX: 00007f7db94d4560 RSI:
> 000000000000001d RDI: 00007f7da80ae750
> Jan 01 02:04:20 computername kernel: RBP: 0000000000000000 R08:
> 0000000000000008 R09: 0000000000000000
> Jan 01 02:04:20 computername kernel: R10: 0000000000000000 R11:
> 0000000000000293 R12: 00007f7db94d45bc
> Jan 01 02:04:20 computername kernel: R13: 00000000023c31c8 R14:
> 00007f7da80a92a0 R15: 00000000009826c9
> Jan 01 02:04:20 computername kernel: ---[ end trace 8ed9f92f3ae55658 ]---
> Jan 01 02:04:20 computername kernel: kmemleak: Cannot allocate a
> kmemleak_object structure
> Jan 01 02:04:20 computername kernel: kmemleak: Kernel memory leak
> detector disabled
> Jan 01 02:04:20 computername kernel: kmemleak: Automatic memory
> scanning thread ended
> Jan 01 02:04:20 computername kernel: kmemleak: Kmemleak disabled
> without freeing internal data. Reclaim the memory with "echo clear >
> /sys/kernel/debug/kmemleak".
> Jan 01 02:04:20 computername kernel: xhci_hcd 0000:00:14.0: ERROR
> unknown event type 37
> *****
>
> Reference Mail: kernel: xhci_hcd 0000:00:14.0: ERROR unknown event
> type 37 - Kernel 4.19.13
>
> I had a leak somewhere and I was directed to look into SUnreclaim
> which was 5.5 GB after an uptime of a little over 1 month on an 8 GB
> system. kmalloc-2048 was a problem.
> I just had enough and needed to find out the cause for my lagging system.
>
> I finally upgraded from 4.18.16 to 4.19.13 and enabled kmemleak to
> hunt for the culprit. I don't think a day had elapsed before kmemleak
> crashed and disabled itself.
>
> I'm thinking my USB TV tuner or Intel USB controller may have been too
> much for kmemleak given it occured in the middle of one of the
> "unknown event type 37" log spams.
