Received: from northrelay04.pok.ibm.com (northrelay04.pok.ibm.com [9.56.224.206])
	by e2.ny.us.ibm.com (8.12.2/8.12.2) with ESMTP id gAEMEWtQ129610
	for <linux-mm@kvack.org>; Thu, 14 Nov 2002 17:14:32 -0500
Received: from localhost.localdomain (plars.austin.ibm.com [9.53.216.72])
	by northrelay04.pok.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id gAEMETfp007442
	for <linux-mm@kvack.org>; Thu, 14 Nov 2002 17:14:30 -0500
Subject: 2.5.47-mm2 - oops with scp
From: Paul Larson <plars@linuxtestproject.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-NVJnTZuJQORga5KCZIcm"
Date: 14 Nov 2002 16:10:47 -0600
Message-Id: <1037311851.10626.126.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-NVJnTZuJQORga5KCZIcm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

This has been opened as bug #21 on bugme.osdl.org.
http://bugme.osdl.org/show_bug.cgi?id=3D21

When trying to scp a file to the victim machine, I got this message then
the oops:

Attempt to release alive inet socket cdb59b60

ksymoops 2.4.4 on i686 2.4.18-3.  Options used
     -V (default)
     -K (specified)
     -L (specified)
     -O (specified)
     -m System.map (specified)

Unable to handle kernel paging request at virtual address 5a5a5a5a
c0115eea
*pde =3D 00000000
Oops: 0002
CPU:    0
EIP:    0060:[<c0115eea>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010082
eax: cdb59b8c   ebx: 5a5a5a5a   ecx: cdb3dea0   edx: cdb3de94
esi: 00000202   edi: 00000001   ebp: 00001354   esp: cdb3de68
ds: 0068   es: 0068   ss: 0068
Stack: cdb3c000 cdb59b60 c02a51db 00000000 ce3f8740 c0114e50 00000000
00000000
       0001c67f cdb3de9c c011d9e5 00000001 ce3f8740 c0114e50 cdb59b8c
5a5a5a5a
       000005a8 4b87ad6e c011d950 c033b929 cdb3c000 cdb59b60 c02bec57
cdb59b60
Call Trace: [<c02a51db>]  [<c0114e50>]  [<c011d9e5>]  [<c0114e50>]=20
[<c011d950>]
 [<c02bec57>]  [<c0114e50>]  [<c0114e50>]  [<c02c7e52>]  [<c02d7b57>]=20
[<c02a28c0>]  [<c02a311d>]  [<c013e0a2>]  [<c02a3d81>]  [<c013c9ed>]=20
[<c013ca45>]  [<c010a62f>]
Code: 89 0b 56 9d 5b 5e c3 eb 0d 90 90 90 90 90 90 90 90 90 90 90

>>EIP; c0115eea <add_wait_queue_exclusive+1a/30>   <=3D=3D=3D=3D=3D
Trace; c02a51db <__lock_sock+7b/f0>
Trace; c0114e50 <default_wake_function+0/40>
Trace; c011d9e5 <schedule_timeout+85/a0>
Trace; c0114e50 <default_wake_function+0/40>
Trace; c011d950 <process_timeout+0/10>
Trace; c02bec57 <tcp_close+337/690>
Trace; c0114e50 <default_wake_function+0/40>
Trace; c0114e50 <default_wake_function+0/40>
Trace; c02c7e52 <tcp_send_fin+1b2/280>
Trace; c02d7b57 <inet_release+47/50>
Trace; c02a28c0 <sock_release+10/50>
Trace; c02a311d <sock_close+2d/40>
Trace; c013e0a2 <__fput+32/d0>
Trace; c02a3d81 <sys_shutdown+31/40>
Trace; c013c9ed <filp_close+4d/60>
Trace; c013ca45 <sys_close+45/60>
Trace; c010a62f <syscall_call+7/b>
Code;  c0115eea <add_wait_queue_exclusive+1a/30>
00000000 <_EIP>:
Code;  c0115eea <add_wait_queue_exclusive+1a/30>   <=3D=3D=3D=3D=3D
   0:   89 0b                     mov    %ecx,(%ebx)   <=3D=3D=3D=3D=3D
Code;  c0115eec <add_wait_queue_exclusive+1c/30>
   2:   56                        push   %esi
Code;  c0115eed <add_wait_queue_exclusive+1d/30>
   3:   9d                        popf
Code;  c0115eee <add_wait_queue_exclusive+1e/30>
   4:   5b                        pop    %ebx
Code;  c0115eef <add_wait_queue_exclusive+1f/30>
   5:   5e                        pop    %esi
Code;  c0115ef0 <add_wait_queue_exclusive+20/30>
   6:   c3                        ret
Code;  c0115ef1 <add_wait_queue_exclusive+21/30>
   7:   eb 0d                     jmp    16 <_EIP+0x16> c0115f00
<remove_wait_queue+0/20>
Code;  c0115ef3 <add_wait_queue_exclusive+23/30>
   9:   90                        nop
Code;  c0115ef4 <add_wait_queue_exclusive+24/30>
   a:   90                        nop
Code;  c0115ef5 <add_wait_queue_exclusive+25/30>
   b:   90                        nop
Code;  c0115ef6 <add_wait_queue_exclusive+26/30>
   c:   90                        nop
Code;  c0115ef7 <add_wait_queue_exclusive+27/30>
   d:   90                        nop
Code;  c0115ef8 <add_wait_queue_exclusive+28/30>
   e:   90                        nop
Code;  c0115ef9 <add_wait_queue_exclusive+29/30>
   f:   90                        nop
Code;  c0115efa <add_wait_queue_exclusive+2a/30>
  10:   90                        nop
Code;  c0115efb <add_wait_queue_exclusive+2b/30>
  11:   90                        nop
Code;  c0115efc <add_wait_queue_exclusive+2c/30>
  12:   90                        nop
Code;  c0115efd <add_wait_queue_exclusive+2d/30>
  13:   90                        nop

<0>Kernel panic: Aiee, killing interrupt handler!

Steps to reproduce:
scp anyfile user@target:/tmp

It asks for the password, and finishes copying the file.  After it's
complete
though, the server crashes.


--=-NVJnTZuJQORga5KCZIcm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEABECAAYFAj3UH2cACgkQbkpggQiFDqf4JgCbBR+fYMbthBdJzFPBv3vL4C6b
JLoAnRWuAwvg33RSjSGR88pwk3M0iyAQ
=ty83
-----END PGP SIGNATURE-----

--=-NVJnTZuJQORga5KCZIcm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
