Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 120126B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 08:52:48 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id t92so5890511wrc.13
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 05:52:48 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id e22si772665wme.235.2017.12.01.05.52.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 05:52:46 -0800 (PST)
Received: from mail-wr0-f198.google.com ([209.85.128.198])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <juerg.haefliger@canonical.com>)
	id 1eKlkE-0007G9-3B
	for linux-mm@kvack.org; Fri, 01 Dec 2017 13:52:46 +0000
Received: by mail-wr0-f198.google.com with SMTP id c9so5174140wrb.4
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 05:52:46 -0800 (PST)
From: Juerg Haefliger <juerg.haefliger@canonical.com>
Subject: KAISER: kexec triggers a warning
Message-ID: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
Date: Fri, 1 Dec 2017 14:52:42 +0100
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="3DgGouCBFu1hUkItwB7BI4E9cU6IK6qCI"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, dave.hansen@linux.intel.com, hughd@google.com, luto@kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3DgGouCBFu1hUkItwB7BI4E9cU6IK6qCI
Content-Type: multipart/mixed; boundary="6NpgQ10fXwkjWJSITRTfMoiMGL2E2xHum";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@canonical.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org,
 dave.hansen@linux.intel.com, hughd@google.com, luto@kernel.org
Message-ID: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
Subject: KAISER: kexec triggers a warning

--6NpgQ10fXwkjWJSITRTfMoiMGL2E2xHum
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

Loading a kexec kernel using today's linux-tip master with KAISER=3Dy
triggers the following warning:

[   18.054017] ------------[ cut here ]------------
[   18.054024] WARNING: CPU: 0 PID: 1183 at
=2E/arch/x86/include/asm/pgtable_64.h:258 native_set_p4d+0x5f/0x80
[   18.054025] Modules linked in: nls_utf8 isofs ppdev nls_iso8859_1
kvm_intel kvm irqbypass input_leds serio_raw i2c_piix4 parport_pc
parport qemu_fw_cfg mac_hid 9p fscache ib_iser rdma_cm iw_cm ib_cm
ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi
9pnet_virtio 9pnet ip_tables x_tables autofs4 btrfs zstd_decompress
zstd_compress xxhash raid10 raid456 async_raid6_recov async_memcpy
async_pq async_xor async_tx xor raid6_pq libcrc32c raid1 raid0 multipath
linear cirrus ttm drm_kms_helper syscopyarea sysfillrect sysimgblt
fb_sys_fops psmouse virtio_blk virtio_net drm floppy pata_acpi
[   18.054047] CPU: 0 PID: 1183 Comm: kexec Not tainted 4.14.0-kaiser+ #2=

[   18.054047] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.10.2-1ubuntu1 04/01/2014
[   18.054048] task: ffff8a53f9d0ab80 task.stack: ffffaba640890000
[   18.054049] RIP: 0010:native_set_p4d+0x5f/0x80
[   18.054050] RSP: 0018:ffffaba640893e20 EFLAGS: 00010246
[   18.054051] RAX: 0000000038ac9063 RBX: 000000003ffda000 RCX:
000000003ffda000
[   18.054051] RDX: ffff8a53fd1f6ff8 RSI: 0000000038ac9063 RDI:
ffff8a53f71ba000
[   18.054051] RBP: 000000003ffda000 R08: 000075abc0000000 R09:
ffff8a53f8ac9000
[   18.054052] R10: 0000000000000003 R11: 000000003ffda000 R12:
ffff8a53f71ba000
[   18.054052] R13: ffffaba640893e78 R14: 0000000000000000 R15:
ffffff8000000000
[   18.054053] FS:  00007f0e95188740(0000) GS:ffff8a53ffc00000(0000)
knlGS:0000000000000000
[   18.054054] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   18.054054] CR2: 00007f0e94bf0fa0 CR3: 000000003c452000 CR4:
00000000000006f0
[   18.054056] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[   18.054056] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
0000000000000400
[   18.054057] Call Trace:
[   18.054065]  kernel_ident_mapping_init+0x147/0x190
[   18.054069]  machine_kexec_prepare+0xc8/0x490
[   18.054071]  ? trace_clock_x86_tsc+0x10/0x10
[   18.054074]  do_kexec_load+0x1d7/0x2d0
[   18.054079]  SyS_kexec_load+0x84/0xc0
[   18.054083]  entry_SYSCALL_64_fastpath+0x1e/0x81
[   18.054087] RIP: 0033:0x7f0e94c9c9f9
[   18.054087] RSP: 002b:00007ffe0d1a83e8 EFLAGS: 00000246 ORIG_RAX:
00000000000000f6
[   18.054088] RAX: ffffffffffffffda RBX: 000055a491d71240 RCX:
00007f0e94c9c9f9
[   18.054089] RDX: 000055a492aaa570 RSI: 0000000000000003 RDI:
000000003ffd1730
[   18.054089] RBP: 00007ffe0d1a8510 R08: 0000000000000008 R09:
0000000000000001
[   18.054089] R10: 00000000003e0000 R11: 0000000000000246 R12:
0000000000000100
[   18.054090] R13: 0000000000000040 R14: 0000000001b1d820 R15:
000000000007c7e0
[   18.054090] Code: 37 c3 f6 07 04 74 1b 48 89 f8 25 ff 0f 00 00 48 3d
ff 07 00 00 77 18 48 89 f8 80 cc 10 48 89 30 eb dc 83 3d 07 6d ff 00 02
75 d3 <0f> ff eb cf 0f ff eb cb 48 b8 00 00 00 00 00 00 00 80 48 09 c6
[   18.054104] ---[ end trace f206deb161cf8af0 ]---

=2E..Juerg


--6NpgQ10fXwkjWJSITRTfMoiMGL2E2xHum--

--3DgGouCBFu1hUkItwB7BI4E9cU6IK6qCI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQI7BAEBCAAlBQJaIV6qHhxqdWVyZy5oYWVmbGlnZXJAY2Fub25pY2FsLmNvbQAK
CRB1TDqW+fi0jFpSD/kBP1v4v9fWoIHZEL3MDTKZS2yV8ECBgiahkORvG4z+/RZv
XeAB5lzpz2TIPHY/wrKw0J6domPE48qYCCUqlbr8++X4WFSYvqAkM6oSnsY0vmEo
KEG+DUP8vpGP0vBnJ+sr2CY2ItDzur9azSCx8Xtrfat1LGfDTzlVcjbaXV357Nk4
2eVabFvYUFtlAz+wFwdjtVxBKeMVSvIqD+jersLPIqtr5IGo6PoB/2neiaDYMybY
OhguwPL7JVsVg1Lj/Pn4d3ywhOU5XAE0pIsSkkxSK04LISivBKGtzsEbxO++3VuT
qRZEFYkqmL28+u/Wsj8tDjV+eotvMQTwCD70kLnxRPWvEuc5Yr32ZX5GXxhOYdJs
k3c5MkKnopoc/CIAWlptAhIzkvqCLZGftbtxrotbc2sXRCCyfjUVFD1J9Un7ro9q
Wt8HtJ2PN/TiOY8STkOjNA7r2FDj/W6nKmCGIQuhX1AcfBPzzZATitfF+1iAp6vR
l1vmhi4IFTlXKWaDSy5eI7m3aFWQNRQbA5Zky97oHWjtYr8kdGhS/XUl30tL1Xhx
B+AMf4DNEnYkvuOhlbTo87sI3BLxTeWC2R8u4ep1cTt5PZVFYY6lvvyFQmOiBmqd
BmbgqW+12/5D9ZvAp0/jboQk3DojXDOwDtKbOGdFGWRy3LM3ZwCVX2Jhkt277g==
=YwjK
-----END PGP SIGNATURE-----

--3DgGouCBFu1hUkItwB7BI4E9cU6IK6qCI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
