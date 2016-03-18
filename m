Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id C89C1828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 16:41:31 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id a36so78791668qge.0
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 13:41:31 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id c81si13587536qha.130.2016.03.18.13.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Mar 2016 13:41:31 -0700 (PDT)
Subject: KASAN overhead?
From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1458333684_2471P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 18 Mar 2016 16:41:24 -0400
Message-ID: <7300.1458333684@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1458333684_2471P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <7276.1458333675.1@turing-police.cc.vt.edu>
Content-Transfer-Encoding: quoted-printable

So I built linux-next next-20160417 with KASAN enabled:

CONFIG_KASAN_SHADOW_OFFSET=3D0xdffffc0000000000
CONFIG_HAVE_ARCH_KASAN=3Dy        =

CONFIG_KASAN=3Dy                  =

# CONFIG_KASAN_OUTLINE is not set
CONFIG_KASAN_INLINE=3Dy           =

CONFIG_TEST_KASAN=3Dm

and saw an *amazing* slowdown.  For comparison, here is the time taken
to reach various points in the dmesg:

% grep -i free dmesg.0317*
dmesg.0317:[    1.560907] Freeing SMP alternatives memory: 28K (ffffffff93=
d3e000 - ffffffff93d45000)
dmesg.0317:[   12.041550] Freeing initrd memory: 10432K (ffff88003f5cb000 =
- ffff88003fffb000)
dmesg.0317:[   16.458451] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY=
 FREEZE LOCK) filtered out
dmesg.0317:[   16.545603] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY=
 FREEZE LOCK) filtered out
dmesg.0317:[   17.818934] Freeing unused kernel memory: 1628K (ffffffff93b=
a7000 - ffffffff93d3e000)
dmesg.0317:[   17.820234] Freeing unused kernel memory: 1584K (ffff880012c=
74000 - ffff880012e00000)
dmesg.0317:[   17.828426] Freeing unused kernel memory: 1524K (ffff8800134=
83000 - ffff880013600000)
dmesg.0317-nokasan:[    0.028821] Freeing SMP alternatives memory: 28K (ff=
ffffffaf104000 - ffffffffaf10b000)
dmesg.0317-nokasan:[    1.587232] Freeing initrd memory: 10432K (ffff88003=
f5cb000 - ffff88003fffb000)
dmesg.0317-nokasan:[    2.433557] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (=
SECURITY FREEZE LOCK) filtered out
dmesg.0317-nokasan:[    2.439411] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (=
SECURITY FREEZE LOCK) filtered out
dmesg.0317-nokasan:[    2.488113] Freeing unused kernel memory: 1324K (fff=
fffffaefb9000 - ffffffffaf104000)
dmesg.0317-nokasan:[    2.488518] Freeing unused kernel memory: 88K (ffff8=
8002e9ea000 - ffff88002ea00000)
dmesg.0317-nokasan:[    2.489490] Freeing unused kernel memory: 388K (ffff=
88002ed9f000 - ffff88002ee00000)

Only config difference was changing to CONFIG_KASAN=3Dn.

Is this level of slowdown expected? Or is my kernel unexpectedly off in th=
e weeds?

--==_Exmh_1458333684_2471P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVuxn9AdmEQWDXROgAQKAbhAAvonR2LPjBviulz1xHSXgJ9tTvMmfAlrU
anvPgBBp6iW9bVk/7KtPyS1mtoYo0uc+T8XUCbykQFzyh+JTzuJsvNtVqREq2LwE
Ao6RbX/NyHYtYS/Vtx2lg9X3X7RiURgTXnAN4AmrnqxLVL8L3LzwCzWIsqHrcXHi
Ds2QleZuX3f5wqTMBtYr89XbHyFyJfHyc8/giLKaD/aOmubTrGkcMGWfZqxOhmZj
NoDoN0SsTtOfYiixQP+r7yANBMw3g63T59TaVnxArdgAFAx+IrqffOkbXqiNtRgS
7gh6iso6cmg3gGTh5J2QG7ZprzyCfCsI3VQ6h9oRxKlFzId/1DCcMGKowSSYsqhN
2f3DNMghMMHmlcuNkeTf5D3n1L+egzoS1Cr5EmpIQ2gi30mZbfidtoRSY7ljGjg6
OezzHMdbWqkNSL58RYyGSzKcVQU/4SnTK6jMrV5JcoYqwlfkpX/PCs9mVCbwWr++
Cy8KX/G8RB0mtvnmNMqCGMC4A2riLEQEoj1DjcSy12v0m8fzx/mouYzPX2ThHfLR
iBIRLXrcBKm3Mrb0F51066He3s8QbixJIPRlK45uQcLN2sVzGY8WOzzM6cUfhnm0
Y9ujoeeJufoEEtjf8gRQHGWgEJBOZDvV8dBPtJOdcuXa3B5XeqHPT/7UeZeWHi4/
5MnGrYj/eg4=
=oxXs
-----END PGP SIGNATURE-----

--==_Exmh_1458333684_2471P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
