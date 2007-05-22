Received: from ibook.localnet ([192.168.0.5] helo=alea.gnuu.de)
	by alea.gnuu.de with esmtp (Exim 4.63)
	(envelope-from <joerg@alea.gnuu.de>)
	id 1HqahP-0001Wx-FY
	for linux-mm@kvack.org; Tue, 22 May 2007 22:11:15 +0200
Received: from joerg by alea.gnuu.de with local (Exim 4.67)
	(envelope-from <joerg@alea.gnuu.de>)
	id 1HqXqh-0001Gj-Sb
	for linux-mm@kvack.org; Tue, 22 May 2007 19:08:39 +0200
Date: Tue, 22 May 2007 19:08:39 +0200
From: =?iso-8859-1?Q?J=F6rg?= Sommer <joerg@alea.gnuu.de>
Subject: Badness at mm/slab.c:777
Message-ID: <20070522170839.GA4862@alea.gnuu.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

% uname -a
Linux ibook 2.6.22-rc2 #1 Mon May 21 23:23:33 CEST 2007 ppc GNU/Linux
% cat /proc/cpuinfo
processor	: 0
cpu		: 7455, altivec supported
clock		: 606.000000MHz
revision	: 0.3 (pvr 8001 0303)
bogomips	: 36.73
timebase	: 18432000
platform	: PowerMac
machine		: PowerBook6,3
motherboard	: PowerBook6,3 MacRISC3 Power Macintosh
detected as	: 287 (iBook G4)
pmac flags	: 0000001b
L2 cache	: 256K unified
pmac-generation	: NewWorld

[19187.923501] device eth0 entered promiscuous mode
[19187.947461] device eth0 left promiscuous mode
[19196.499436] eth0: no IPv6 routers present
[25788.153585] ------------[ cut here ]------------
[25788.153618] Badness at mm/slab.c:777
[25788.153624] Call Trace:
[25788.153631] [e63cdcf0] [c0008810] show_stack+0x4c/0x1ac (unreliable)
[25788.153662] [e63cdd30] [c0104258] report_bug+0xac/0xe4
[25788.153687] [e63cdd40] [c000f9c8] program_check_exception+0xd4/0x598
[25788.153707] [e63cdd80] [c00116e4] ret_from_except_full+0x0/0x4c
[25788.153722] --- Exception: 700 at __kmalloc+0xe0/0x114
[25788.153749]     LR =3D drm_rmdraw+0x24c/0x278
[25788.153756] [e63cde40] [c017ded4] radeon_cp_buffers+0x18c/0x2c8 (unrelia=
ble)
[25788.153774] [e63cde60] [c01748d8] drm_rmdraw+0x24c/0x278
[25788.153787] [e63cdea0] [c0175334] drm_ioctl+0xe4/0x25c
[25788.153800] [e63cded0] [c0083b4c] do_ioctl+0x94/0x98
[25788.153820] [e63cdee0] [c0083e1c] vfs_ioctl+0x2cc/0x41c
[25788.153833] [e63cdf10] [c0083fac] sys_ioctl+0x40/0x74
[25788.153846] [e63cdf40] [c0011088] ret_from_syscall+0x0/0x38
[25788.153858] --- Exception: c01 at 0xfd33d38
[25788.153885]     LR =3D 0xfd33cd0
[25803.544830] agpgart: Putting AGP V2 device at 0000:00:0b.0 into 1x mode
[25803.544855] agpgart: Putting AGP V2 device at 0000:00:10.0 into 1x mode
[25803.544928] [drm] Loading R200 Microcode

Upon suspending the machine to RAM with pbbuttonsd the program died and
nothing else happend.

If you need more informations, tell me.

Have a nice day, J=C3=B6rg.
--=20
=E2=80=9CUnfortunately, the current generation of mail programs do not have
 checkers to see if the sender knows what he is talking about=E2=80=9D
            (Andrew S. Tanenbaum)

--BOKacYhQ+x31HxR3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQEVAwUBRlMjl4Z13Cz2nwVYAQLd6Qf+JyUNL+tYUXbxSbxg9qJvE8iVNYcdSCjz
DGoTkjZpCKHK4n8zsIbhfk+BlnkoaxNWNzrPdqMdjwI+mefRM0+cWDSXioZtidR7
/oX+LlsCcDOJsVVGSHGoCPrD96jh0RkmO4+BYhzPULELb9F5wOCdVBCy9aZhKeU5
rTyxfRkzC9J75B4g0qcEJboh9U14qXV6/abd2ZrRa6mK4iGlHU8dp7GBhzByzaR4
HCDA9fqNemUnp4vbOxBoXFJYXb0hyvIgbOeeD9wNNj7WbAcA/rPcHo0TCjMPUETC
08keFH/HtoJM6HM69WxDrYk3BFe7s+ya9yV+39pMDBKH0XwRCazliQ==
=20cf
-----END PGP SIGNATURE-----

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
