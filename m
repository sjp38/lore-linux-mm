Date: Thu, 17 Oct 2002 18:14:39 +0200
From: Sebastian Benoit <benoit-lists@fb12.de>
Subject: 2.5.43-mm2 gets network connection stuck
Message-ID: <20021017181439.A8089@turing.fb12.de>
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com> <20021016154943.GA13695@hswn.dk> <20021017200843.D29405@in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Content-Disposition: inline
In-Reply-To: <20021017200843.D29405@in.ibm.com>; from maneesh@in.ibm.com on Thu, Oct 17, 2002 at 08:08:43PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,=20

funny problem w. 2.5.43-mm2:

i'm running 2.5.43-mm2 on my workstation. Normal workload, X-windows, a few
xterms, editor, mozilla, etc. (host A)

I have a NFS/SAMBA-mount (both show the problem) to host B. Host B runs
2.4.19rc5aa1.

I can get a xterm, in which i have a ssh-connection to a third host C
'stuck' by simply cat'ing a large file from the NFS/SAMBA server to
/dev/null.

The xterm/ssh seems stuck, that is no key i press is received on the other
end, but output of the program running on host C is updated in the xterm. I
checked with tcpdump: the keypress does not generate a packet, my host only
sends ACK's on that ssh connection to host C.

The ssh-connection is not unstuck by stopping the data transfer from host B.

I checked that plain 2.5.42 and 2.5.43-mm1 do not have this problem: here my
input goes through to C. At least for small amounts of input, i did not test
anything beyond typing a few hundret chars.

recap:

 "mount /mnt/hostB"
 "ssh hostC" -> type random stuff in that connection
 at the same time do "cat /mnt/hostB/bigfile > /dev/null"
 ssh gets stuck.

hardware: PIII/600, 3c905B on 10baseT half-duplex

I'm sorry i cant do any further checks until Friday afternoon (MET).

/B.
--=20
Sebastian Benoit <benoit-lists@fb12.de>
My mail is GnuPG signed -- Unsigned ones are bogus -- http://www.gnupg.org/
GnuPG 0x5BA22F00 2001-07-31 2999 9839 6C9E E4BF B540  C44B 4EC4 E1BE 5BA2 2=
F00

Oxymoron #654: Fatally Injured

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEARECAAYFAj2u4e8ACgkQTsThvluiLwCrSgCdGuKzP+7+ieuNZ/GZL+TZw/ow
ybkAoIud5K4HAlCy3wzXtuqEmUNzBdTk
=WyUd
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
