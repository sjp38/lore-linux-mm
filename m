From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Thu, 6 Mar 2008 23:21:55 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <200803062253.00034.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061354210.15083@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803061354210.15083@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1723672.gHEuZt8tL2";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803062321.55581.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

--nextPart1723672.gHEuZt8tL2
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


> Then check 2.6.22 and specify the boot parameter "slub_debug". Make sure=
=20
> to compile the kernel with slub support. Is there any way you could get=20

With 2.6.22, slub on and slub_debug on the command line I get

PID hash table entries: 4096 (order: 12, 32768 bytes)
Console: colour dummy device 80x25
Dentry cache hash table entries: 262144 (order: 5, 2097152 bytes0005416c/2
Call Trace:
[c00000000ff87ce8] [c00000000000f2cc] .show_stack+0x68/0x1b0 (unreliable)
[c00000000ff87d88] [c000000000347d3c] .schedule+0xa4/0x8f0
[c00000000ff87e88] [c0000000003486f4] .wait_for_completion+0xd8/0x174
[c00000000ff87f48] [c000000000071770] .kthreadd+0x124/0x1b8
[c00000000ff87fd8] [c0000000000256f8] .kernel_thread+0x4c/0x68
BUG: scheduling while atomic: kthreadd/0x0005416c/2
Call Trace:
[c00000000ff87da8] [c00000000000f2cc] .show_stack+0x68/0x1b0 (unreliable)
[c00000000ff87e48] [c000000000347d3c] .schedule+0xa4/0x8f0
[c00000000ff87f48] [c0000000000716e0] .kthreadd+0x94/0x1b8
[c00000000ff87fd8] [c0000000000256f8] .kernel_thread+0x4c/0x68
BUG: scheduling while atomic: kthreadd/0x0005416c/2
Call Trace:
[c00000000ff87ce8] [c00000000000f2cc] .show_stack+0x68/0x1b0 (unreliable)
[c00000000ff87d88] [c000000000347d3c] .schedule+0xa4/0x8f0
[c00000000ff87e88] [c0000000003486f4] .wait_for_completion+0xd8/0x174
[c00000000ff87f48] [c000000000071770] .kthreadd+0x124/0x1b8
[c00000000ff87fd8] [c0000000000256f8] .kernel_thread+0x4c/0x68
BUG: scheduling while atomic: kthreadd/0x0183eeb8/4
Call Trace:
[c00000000ff9bf10] [c00000000000f2cc] .show_stack+0x68/0x1b0 (unreliable)
[c00000000ff9bfb0] [c000000000347d3c] .schedule+0xa4/0x8f0
[c00000000ff9c0b0] [c000000000071960] .kthread+0x40/0xc4
[c00000000ff9c140] [c0000000000256f8] .kernel_thread+0x4c/0x68
BUG: scheduling while atomic: kthreadd/0x0005416c/2
Call Trace:
[c00000000ff87da8] [c00000000000f2cc] .show_stack+0x68/0x1b0 (unreliable)
[c00000000ff87e48] [c000000000347d3c] .schedule+0xa4/0x8f0
[c00000000ff87f48] [c0000000000716e0] .kthreadd+0x94/0x1b8
[c00000000ff87fd8] [c0000000000256f8] .kernel_thread+0x4c/0x68

> us further information about the problem?

Sure, what do you need ?

The system is a Cell Blade with 2G memory, hence numa support enabled.
I built the 2.6.22 with cell_defconfig and manually selected SLUB.

Gru=DF,
	Jens

--nextPart1723672.gHEuZt8tL2
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0G6DP1aZ9bkt7XMRAnFiAJ48om84jubBz2o9feZvHjuPYBKCvgCgoJRO
+9Za0hl5rmP8lydQ77/ocoQ=
=QU52
-----END PGP SIGNATURE-----

--nextPart1723672.gHEuZt8tL2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
