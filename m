From: Okrain Genady <mafteah@mafteah.co.il>
Subject: Some errors with 2.6.0-test4-mm2
Date: Wed, 27 Aug 2003 10:47:43 +0300
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_jIGT/F82hCnsyZR";
  charset="windows-1255"
Content-Transfer-Encoding: 7bit
Message-Id: <200308271047.47794.mafteah@mafteah.co.il>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-02=_jIGT/F82hCnsyZR
Content-Type: text/plain;
  charset="windows-1255"
Content-Transfer-Encoding: quoted-printable
Content-Description: signed data
Content-Disposition: inline

1)
On reboot:

Debug: sleeping function called from invalid context at=20
include/linux/rwsem.h:43
Call Trace:
 [<c011cc3f>] __might_sleep+0x5f/0x70
 [<c0119eff>] do_page_fault+0x19f/0x4ca
 [<c0121e20>] it_real_fn+0x0/0x70
 [<c0126f82>] run_timer_softirq+0x112/0x1c0
 [<c0127120>] do_timer+0xe0/0xf0
 [<c011b5b2>] schedule+0x1b2/0x3c0
 [<c010cff6>] do_IRQ+0x116/0x160
 [<c0119d60>] do_page_fault+0x0/0x4ca
 [<c010b4e5>] error_code+0x2d/0x38

btw I had it on 2.6.0-test4 and on -bk2 and on -mm1

2)
This error started with -mm2:

# lilo
<1>Unable to handle kernel NULL pointer dereference at virtual address=20
00000000
 printing eip:
c029f9b2
*pde =3D 00000000
Oops: 0000 [#4]
PREEMPT
CPU:    0
EIP:    0060:[<c029f9b2>]    Tainted: PF  VLI
EFLAGS: 00010246
EIP is at generic_ide_ioctl+0x352/0x8b0
eax: 00000000   ebx: bfffec70   ecx: 0000e7a2   edx: 00000000
esi: bfffec68   edi: c87ca000   ebp: c87cbf68   esp: c87cbf2c
ds: 007b   es: 007b   ss: 0068
Process lilo (pid: 5503, threadinfo=3Dc87ca000 task=3Dc8eac080)
Stack: c03c76db 0000064e c7853200 fffffff2 00000000 00000000 e7a20003 c04cc=
b8c
       cfa7e000 c87cbf9c c0153b66 cf5ae6c0 cfd33e40 c02a3a60 cf619680 c87cb=
f90
       c0268235 cfd33e40 00000301 bfffec68 bfffec68 00000001 00000301 c7853=
200
Call Trace:
 [<c0153b66>] filp_open+0x66/0x70
 [<c02a3a60>] idedisk_ioctl+0x0/0x30
 [<c0268235>] blkdev_ioctl+0xa5/0x447
 [<c0167b84>] sys_ioctl+0xf4/0x290
 [<c0397e07>] syscall_call+0x7/0xb

Code: 4e 06 00 00 c7 04 24 db 76 3c c0 e8 b9 c5 e7 ff 83 c3 04 83 c3 04 19 =
c0=20
39 5f 18 83 d8 00 85 c0 75 11 8b
 46 38 8b
55 d4 8b 75 10 <8b> 00 89 46 04 89 55 d0 8b 4d d0 ba f2 ff ff ff 85 c9 0f 4=
4=20
55
 Segmentation fault

3)
setfont sets font only for the current tty and not for all ttys like 2.4 do.

=2D-=20
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|
			Okrain Genady
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|
 E-Mail		: mafteah@mafteah.co.il
 ICQ		: 73163402
 Home Page	: http://www.mafteah.co.il/
 GnuGP		: 0x4F892EE6 At http://pgp.mit.edu/
 Fingerprint	: 5853 E821 5EF2 69BC A9AE 3F24 1F7C F79F 408D 4AEE
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|

--Boundary-02=_jIGT/F82hCnsyZR
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/TGIjH3z3n0CNSu4RAnhsAJ9MLQKk018qRTRmHLj//I/lIKWSeACfTlQ3
JLyKUqnZpJVuph71mfM5Oq8=
=XJXy
-----END PGP SIGNATURE-----

--Boundary-02=_jIGT/F82hCnsyZR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
