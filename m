Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 13F2D9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:19:18 -0400 (EDT)
Date: Fri, 30 Sep 2011 14:19:14 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 0/9] V2: idle page tracking / working set estimation
Message-ID: <20110930181914.GA17817@mgebm.net>
References: <1317170947-17074-1-git-send-email-walken@google.com>
 <20110929164319.GA3509@mgebm.net>
 <CANN689H1G-USQYQrOTb47Hrc7KMjLdxkppYCDKsTUy5WhuRs7w@mail.gmail.com>
 <4186d5662b3fb21af1b45f8a335414d3@mgebm.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Content-Disposition: inline
In-Reply-To: <4186d5662b3fb21af1b45f8a335414d3@mgebm.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 29 Sep 2011, Eric B Munson wrote:

> On Thu, 29 Sep 2011 13:25:00 -0700, Michel Lespinasse wrote:
> >On Thu, Sep 29, 2011 at 9:43 AM, Eric B Munson <emunson@mgebm.net>
> >wrote:
> >>I have been trying to test these patches since yesterday
> >>afternoon. =A0When my
> >>machine is idle, they behave fine. =A0I started looking at
> >>performance to make
> >>sure they were a big regression by testing kernel builds with
> >>the scanner
> >>disabled, and then enabled (set to 120 seconds). =A0The scanner
> >>disabled builds
> >>work fine, but with the scanner enabled the second time I build
> >>my kernel hangs
> >>my machine every time. =A0Unfortunately, I do not have any more
> >>information than
> >>that for you at the moment. =A0My next step is to try the same
> >>tests in qemu to
> >>see if I can get more state information when the kernel hangs.
> >
> >Could you please send me your .config file ? Also, did you apply the
> >patches on top of straight v3.0 and what is your machine like ?
> >
> >Thanks,
>=20
>=20
> My .config will come separately to you.  I applied the patches to
> Linus' master branch as of yesterday.  My machine is a single Xeon
> 5690 with 12G of ram (do you need more details than that?)
>=20
> Thanks,
> Eric

I am able to recreate on a second desktop I have here (same model CPU but a
different MB so I am fairly sure it isn't dying hardware).  It looks to me =
like
a CPU softlocks and it stalls the process active there, so most recently th=
at
was XOrg.  The machine lets me login via ssh for a few minutes, but things =
like
ps and cat or /proc files will start to work and give some output but hang.
I cannot call reboot, nor can I sync the fs and reboot via SysRq.  My next =
step
is to setup a netconsole to see if anything comes out in the syslog that I
cannot see.

Eric

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOhggiAAoJEH65iIruGRnNtXwIANGCN1XK5vZHErXG/SPJzn1Z
HyJ5IoRPfErNdpWHm+VCuhu/qM8rPs4d1kulSNCn7BcXJyduT/S1NEUTu2pv875s
J465JH9b38LM7t2ohx242Kyn00XCG0CEd65F6lgE0VrPTFy9gleuNKe0yhIn1G+6
zigGo5sYDhTfhlXDiQHPwYjJqkQkPmMlu2hMfyX2agfHVnLuQbdQG5A42LUAVvoq
TlgA1uDBsx4GGKAncHDoOg+2/X05AF0YzLVQGKOGFFW0pTutMDUATh7d9Lo+Cksx
gDmRHiKXhADQSZxXZVCgDk7xi2MNEdKoA6ez4GApEGg8gD4+QXv/UT++Uw3kbZA=
=QiKM
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
