Subject: 2.6.20-rc6-mm3 possible circular lock on mmap_sem
From: Zan Lynx <zlynx@acm.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vSQv17GaBM4+cBcxX4Nx"
Date: Thu, 01 Feb 2007 17:43:35 -0700
Message-Id: <1170377015.7233.11.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-vSQv17GaBM4+cBcxX4Nx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I just noticed this in my logs, from the lock checker:

[  142.299455]=20
[  142.299458] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  142.299473] [ INFO: possible circular locking dependency detected ]
[  142.299478] 2.6.20-rc6-mm3 #2
[  142.299482] -------------------------------------------------------
[  142.299547] evolution-data-/6909 is trying to acquire lock:
[  142.299551]  (&mm->mmap_sem){----}, at: [<ffffffff80266096>] do_page_fau=
lt+0x3f6/0x8a0
[  142.299742]=20
[  142.299743] but task is already holding lock:
[  142.299749]  (&data->latch){----}, at: [<ffffffff8034f221>] get_exclusiv=
e_access+0x11/0x20
[  142.299880]=20
[  142.299880] which lock already depends on the new lock.
[  142.299882]=20
[  142.299947]=20
[  142.299948] the existing dependency chain (in reverse order) is:
[  142.300010]=20
[  142.300011] -> #1 (&data->latch){----}:
[  142.300138]        [<ffffffff8029e968>] __lock_acquire+0xd48/0xff0
[  142.300390]        [<ffffffff8029ec5b>] lock_acquire+0x4b/0x70
[  142.300583]        [<ffffffff8034f221>] get_exclusive_access+0x11/0x20
[  142.300833]        [<ffffffff80298db4>] down_write+0x34/0x40
[  142.301084]        [<ffffffff8034f221>] get_exclusive_access+0x11/0x20
[  142.301277]        [<ffffffff8034e58e>] mmap_unix_file+0x8e/0x1a0
[  142.301526]        [<ffffffff8020d80b>] do_mmap_pgoff+0x4eb/0x820
[  142.301777]        [<ffffffff8029d496>] mark_held_locks+0x76/0xa0
[  142.301969]        [<ffffffff80263bf4>] _spin_unlock_irq+0x24/0x30
[  142.302219]        [<ffffffff80263bf4>] _spin_unlock_irq+0x24/0x30
[  142.302468]        [<ffffffff80233e73>] elf_map+0xa3/0x100
[  142.302662]        [<ffffffff80217990>] load_elf_binary+0x920/0x1cd0
[  142.302912]        [<ffffffff8020ab35>] kfree+0xd5/0xf0
[  142.303162]        [<ffffffff80282860>] load_aout_binary+0x0/0x990
[  142.303356]        [<ffffffff80217070>] load_elf_binary+0x0/0x1cd0
[  142.303606]        [<ffffffff8023f68d>] search_binary_handler+0x9d/0x240
[  142.303857]        [<ffffffff8024cef1>] load_script+0x211/0x240
[  142.304050]        [<ffffffff80217070>] load_elf_binary+0x0/0x1cd0
[  142.304300]        [<ffffffff8024cce0>] load_script+0x0/0x240
[  142.304549]        [<ffffffff8024cce0>] load_script+0x0/0x240
[  142.304741]        [<ffffffff8023f68d>] search_binary_handler+0x9d/0x240
[  142.304991]        [<ffffffff8023ea8a>] do_execve+0x17a/0x220
[  142.305241]        [<ffffffff80292920>] __call_usermodehelper+0x0/0x80
[  142.305434]        [<ffffffff80252734>] sys_execve+0x44/0xb0
[  142.305684]        [<ffffffff8025cb44>] kernel_execve+0x64/0xd0
[  142.305878]        [<ffffffff80292920>] __call_usermodehelper+0x0/0x80
[  142.306127]        [<ffffffff80292d21>] ____call_usermodehelper+0x161/0x=
170
[  142.306377]        [<ffffffff8025cad8>] child_rip+0xa/0x12
[  142.306569]        [<ffffffff80263bf4>] _spin_unlock_irq+0x24/0x30
[  142.306818]        [<ffffffff8025c6bc>] restore_args+0x0/0x30
[  142.307068]        [<ffffffff80292bc0>] ____call_usermodehelper+0x0/0x17=
0
[  142.307260]        [<ffffffff8025cace>] child_rip+0x0/0x12
[  142.307510]        [<ffffffffffffffff>] 0xffffffffffffffff
[  142.307752]=20
[  142.307752] -> #0 (&mm->mmap_sem){----}:
[  142.307878]        [<ffffffff8029cadb>] print_circular_bug_header+0xdb/0=
x100
[  142.308128]        [<ffffffff8029e827>] __lock_acquire+0xc07/0xff0
[  142.308378]        [<ffffffff8029d496>] mark_held_locks+0x76/0xa0
[  142.308570]        [<ffffffff8029ec5b>] lock_acquire+0x4b/0x70
[  142.308820]        [<ffffffff80266096>] do_page_fault+0x3f6/0x8a0
[  142.309013]        [<ffffffff80298cd7>] down_read+0x37/0x40
[  142.309263]        [<ffffffff80266096>] do_page_fault+0x3f6/0x8a0
[  142.309513]        [<ffffffff8029d496>] mark_held_locks+0x76/0xa0
[  142.309705]        [<ffffffff8026412d>] error_exit+0x0/0x96
[  142.309954]        [<ffffffff8020c883>] file_read_actor+0x43/0x180
[  142.310147]        [<ffffffff8026170f>] __wait_on_bit_lock+0x6f/0x80
[  142.310399]        [<ffffffff8020b94b>] do_generic_mapping_read+0x25b/0x=
580
[  142.310649]        [<ffffffff8020c840>] file_read_actor+0x0/0x180
[  142.310841]        [<ffffffff80215eca>] generic_file_aio_read+0x19a/0x1f=
0
[  142.311091]        [<ffffffff8020c50b>] do_sync_read+0xdb/0x130
[  142.311340]        [<ffffffff80296540>] wake_bit_function+0x0/0x30
[  142.311533]        [<ffffffff80263897>] _spin_unlock+0x17/0x20
[  142.311783]        [<ffffffff8033257e>] reiser4_grab+0xae/0xd0
[  142.311977]        [<ffffffff8034d28b>] read_unix_file+0xdb/0x450
[  142.312227]        [<ffffffff8021604b>] vma_merge+0x12b/0x1e0
[  142.312476]        [<ffffffff8020ac0a>] vfs_read+0xba/0x180
[  142.312669]        [<ffffffff80210753>] sys_read+0x53/0x90
[  142.312918]        [<ffffffff8025c11e>] system_call+0x7e/0x83
[  142.313111]        [<ffffffffffffffff>] 0xffffffffffffffff
[  142.313361]=20
[  142.313361] other info that might help us debug this:
[  142.313363]=20
[  142.313428] 1 lock held by evolution-data-/6909:
[  142.313432]  #0:  (&data->latch){----}, at: [<ffffffff8034f221>] get_exc=
lusive_access+0x11/0x20
[  142.313619]=20
[  142.313619] stack backtrace:
[  142.313682]=20
[  142.313682] Call Trace:
[  142.313690]  [<ffffffff8029c714>] print_circular_bug_tail+0x74/0x90
[  142.313754]  [<ffffffff8029cadb>] print_circular_bug_header+0xdb/0x100
[  142.313760]  [<ffffffff8029e827>] __lock_acquire+0xc07/0xff0
[  142.313766]  [<ffffffff8029d496>] mark_held_locks+0x76/0xa0
[  142.313830]  [<ffffffff8029ec5b>] lock_acquire+0x4b/0x70
[  142.313835]  [<ffffffff80266096>] do_page_fault+0x3f6/0x8a0
[  142.313898]  [<ffffffff80298cd7>] down_read+0x37/0x40
[  142.313904]  [<ffffffff80266096>] do_page_fault+0x3f6/0x8a0
[  142.313913]  [<ffffffff8029d496>] mark_held_locks+0x76/0xa0
[  142.313977]  [<ffffffff8026412d>] error_exit+0x0/0x96
[  142.313985]  [<ffffffff8020c883>] file_read_actor+0x43/0x180
[  142.313991]  [<ffffffff8026170f>] __wait_on_bit_lock+0x6f/0x80
[  142.314055]  [<ffffffff8020b94b>] do_generic_mapping_read+0x25b/0x580
[  142.314060]  [<ffffffff8020c840>] file_read_actor+0x0/0x180
[  142.314071]  [<ffffffff80215eca>] generic_file_aio_read+0x19a/0x1f0
[  142.314135]  [<ffffffff8020c50b>] do_sync_read+0xdb/0x130
[  142.314143]  [<ffffffff80296540>] wake_bit_function+0x0/0x30
[  142.314150]  [<ffffffff80263897>] _spin_unlock+0x17/0x20
[  142.314213]  [<ffffffff8033257e>] reiser4_grab+0xae/0xd0
[  142.314219]  [<ffffffff8034d28b>] read_unix_file+0xdb/0x450
[  142.314225]  [<ffffffff8021604b>] vma_merge+0x12b/0x1e0
[  142.314291]  [<ffffffff8020ac0a>] vfs_read+0xba/0x180
[  142.314297]  [<ffffffff80210753>] sys_read+0x53/0x90
[  142.314360]  [<ffffffff8025c11e>] system_call+0x7e/0x83
[  142.314366]=20

--=20
Zan Lynx <zlynx@acm.org>


--=-vSQv17GaBM4+cBcxX4Nx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.1 (GNU/Linux)

iD8DBQBFwok3G8fHaOLTWwgRAuJJAKCms7Eri0atCpOy57fqJ89wKLrXBQCfS2zj
E1I9OTwDe/PaCG9FSp/rgkA=
=e9Uw
-----END PGP SIGNATURE-----

--=-vSQv17GaBM4+cBcxX4Nx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
