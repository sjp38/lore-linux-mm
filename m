From: Okrain Genady <mafteah@mafteah.co.il>
Subject: Re: Some errors with 2.6.0-test4-mm2
Date: Wed, 27 Aug 2003 11:30:42 +0300
References: <200308271047.47794.mafteah@mafteah.co.il> <20030827012346.50d4955a.akpm@osdl.org>
In-Reply-To: <20030827012346.50d4955a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_1wGT/jt+/vDx2eh";
  charset="windows-1255"
Content-Transfer-Encoding: 7bit
Message-Id: <200308271130.45751.mafteah@mafteah.co.il>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-02=_1wGT/jt+/vDx2eh
Content-Type: text/plain;
  charset="windows-1255"
Content-Transfer-Encoding: quoted-printable
Content-Description: signed data
Content-Disposition: inline

# strace lilo
execve("/sbin/lilo", ["lilo"], [/* 49 vars */]) =3D 0
uname({sys=3D"Linux", node=3D"Gentoo", ...}) =3D 0
brk(0)                                  =3D 0x8076000
open("/etc/ld.so.preload", O_RDONLY)    =3D -1 ENOENT (No such file or=20
directory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 3
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D67144, ...}) =3D 0
mmap2(NULL, 67144, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0x40000000
close(3)                                =3D 0
open("/lib/libc.so.6", O_RDONLY)        =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\360\353"..., 1024)=
 =3D=20
1024
fstat64(3, {st_mode=3DS_IFREG|0755, st_size=3D1425235, ...}) =3D 0
mmap2(0x4c819000, 1237380, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) =3D=20
0x4c819000
mprotect(0x4c940000, 29060, PROT_NONE)  =3D 0
mmap2(0x4c940000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3,=20
0x126) =3D 0x4c940000
mmap2(0x4c945000, 8580, PROT_READ|PROT_WRITE,=20
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0x4c945000
close(3)                                =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
=3D=20
0x40011000
munmap(0x40000000, 67144)               =3D 0
brk(0)                                  =3D 0x8076000
brk(0x8077000)                          =3D 0x8077000
brk(0)                                  =3D 0x8077000
open("/etc/lilo.conf", O_RDONLY)        =3D 3
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D645, ...}) =3D 0
mmap2(NULL, 131072, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)=
 =3D=20
0x40012000
read(3, "boot =3D /dev/hda\nprompt\nmap =3D /bo"..., 131072) =3D 645
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D645, ...}) =3D 0
brk(0)                                  =3D 0x8077000
brk(0x8078000)                          =3D 0x8078000
brk(0)                                  =3D 0x8078000
brk(0x8079000)                          =3D 0x8079000
brk(0)                                  =3D 0x8079000
brk(0x807a000)                          =3D 0x807a000
open("/dev/mem", O_RDONLY)              =3D 4
lseek(4, 1536, SEEK_SET)                =3D 1536
read(4, "\271O\'\231LiLo\5\0\334\0\200\3\2\20B\0b\0\224\0\32\0 "..., 2560) =
=3D=20
2560
close(4)                                =3D 0
open("/etc/disktab", O_RDONLY)          =3D -1 ENOENT (No such file or=20
directory)
stat64("/dev/hda", {st_mode=3DS_IFBLK|0600, st_rdev=3Dmakedev(3, 0), ...}) =
=3D 0
stat64("/boot/System.map", {st_mode=3DS_IFREG|0600, st_size=3D147968, ...})=
 =3D 0
open("/dev/hda", O_RDWR)                =3D 4
fstat64(4, {st_mode=3DS_IFBLK|0600, st_rdev=3Dmakedev(3, 0), ...}) =3D 0
open("/dev/hda", O_RDONLY)              =3D 5
fstat64(5, {st_mode=3DS_IFBLK|0600, st_rdev=3Dmakedev(3, 0), ...}) =3D 0
open("/proc/partitions", O_RDONLY)      =3D 6
fstat64(6, {st_mode=3DS_IFREG|0444, st_size=3D0, ...}) =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
=3D=20
0x40032000
read(6, "major minor  #blocks  name\n\n   3"..., 1024) =3D 243
stat64("/dev/hda", {st_mode=3DS_IFBLK|0600, st_rdev=3Dmakedev(3, 0), ...}) =
=3D 0
stat64("/dev/hda1", {st_mode=3DS_IFBLK|0600, st_rdev=3Dmakedev(3, 1), ...})=
 =3D 0
stat64("/dev/hda", {st_mode=3DS_IFBLK|0600, st_rdev=3Dmakedev(3, 0), ...}) =
=3D 0
open("/dev/hda", O_RDONLY)              =3D 7
read(7, "\372\353\37\1\262\1LILO\26\5\245jL?\0\0\0\0W\271\345\1"..., 512) =
=3D=20
512
close(7)                                =3D 0
stat64("/dev/hda", {st_mode=3DS_IFBLK|0600, st_rdev=3Dmakedev(3, 0), ...}) =
=3D 0
stat64("/dev/hda", {st_mode=3DS_IFBLK|0600, st_rdev=3Dmakedev(3, 0), ...}) =
=3D 0
open("/dev/hda", 0x4)                   =3D 7
ioctl(7, 0x301 <unfinished ...>
+++ killed by SIGSEGV +++

On Wednesday 27 August 2003 11:23, you wrote:
> Okrain Genady <mafteah@mafteah.co.il> wrote:
> > 1)
> > On reboot:
> >
> > Debug: sleeping function called from invalid context at
> > include/linux/rwsem.h:43
> > Call Trace:
> >  [<c011cc3f>] __might_sleep+0x5f/0x70
> >  [<c0119eff>] do_page_fault+0x19f/0x4ca
> >  [<c0121e20>] it_real_fn+0x0/0x70
> >  [<c0126f82>] run_timer_softirq+0x112/0x1c0
> >  [<c0127120>] do_timer+0xe0/0xf0
> >  [<c011b5b2>] schedule+0x1b2/0x3c0
> >  [<c010cff6>] do_IRQ+0x116/0x160
> >  [<c0119d60>] do_page_fault+0x0/0x4ca
> >  [<c010b4e5>] error_code+0x2d/0x38
> >
> > btw I had it on 2.6.0-test4 and on -bk2 and on -mm1
>
> Not sure what that is.
>
> > 2)
> > This error started with -mm2:
> >
> > # lilo
> > <1>Unable to handle kernel NULL pointer dereference at virtual address
> > 00000000
> >  printing eip:
> > c029f9b2
> > *pde =3D 00000000
> > Oops: 0000 [#4]
> > PREEMPT
> > CPU:    0
> > EIP:    0060:[<c029f9b2>]    Tainted: PF  VLI
>
> What's the taint?
>
> > EFLAGS: 00010246
> > EIP is at generic_ide_ioctl+0x352/0x8b0
> > eax: 00000000   ebx: bfffec70   ecx: 0000e7a2   edx: 00000000
> > esi: bfffec68   edi: c87ca000   ebp: c87cbf68   esp: c87cbf2c
> > ds: 007b   es: 007b   ss: 0068
> > Process lilo (pid: 5503, threadinfo=3Dc87ca000 task=3Dc8eac080)
> > Stack: c03c76db 0000064e c7853200 fffffff2 00000000 00000000 e7a20003
> > c04ccb8c cfa7e000 c87cbf9c c0153b66 cf5ae6c0 cfd33e40 c02a3a60 cf619680
> > c87cbf90 c0268235 cfd33e40 00000301 bfffec68 bfffec68 00000001 00000301
> > c7853200 Call Trace:
> >  [<c0153b66>] filp_open+0x66/0x70
> >  [<c02a3a60>] idedisk_ioctl+0x0/0x30
> >  [<c0268235>] blkdev_ioctl+0xa5/0x447
> >  [<c0167b84>] sys_ioctl+0xf4/0x290
> >  [<c0397e07>] syscall_call+0x7/0xb
>
> Works OK here.  Could you please do `strace lilo', see what the offending
> ioctl args are?
>
> > setfont sets font only for the current tty and not for all ttys like 2.4
> > do.
>
> hm, I wonder who to blame that on.

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

--Boundary-02=_1wGT/jt+/vDx2eh
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/TGw1H3z3n0CNSu4RAhLeAJ4t+IiyeuwFRxDMRXc/NmEzVajXawCgqwAK
e2LNkXbkvUVmsORp4g/t9gM=
=Ljdv
-----END PGP SIGNATURE-----

--Boundary-02=_1wGT/jt+/vDx2eh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
