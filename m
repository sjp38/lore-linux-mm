Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C4606B009B
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 02:00:58 -0500 (EST)
Date: Thu, 16 Dec 2010 18:00:47 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next early user mode crash (Was: Re: Transparent Hugepage
 Support #33)
Message-Id: <20101216180047.4bb69b80.sfr@canb.auug.org.au>
In-Reply-To: <20101216170814.6a874692.sfr@canb.auug.org.au>
References: <20101215051540.GP5638@random.random>
	<20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
	<20101215171809.0e0bc3d5.akpm@linux-foundation.org>
	<20101216130251.12dbe8d8.sfr@canb.auug.org.au>
	<20101216052958.GA2161@linux.vnet.ibm.com>
	<20101216170814.6a874692.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__16_Dec_2010_18_00_47_+1100_WtcUS6F9aAnBQgU3"
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>
List-ID: <linux-mm.kvack.org>

--Signature=_Thu__16_Dec_2010_18_00_47_+1100_WtcUS6F9aAnBQgU3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Paul,

On Thu, 16 Dec 2010 17:08:14 +1100 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Wed, 15 Dec 2010 21:29:58 -0800 "Paul E. McKenney" <paulmck@linux.vnet=
.ibm.com> wrote:
> >
> > RCU problems would normally take longer to run the system out of memory,
> > but who knows?
> >=20
> > I did a push into -rcu in the suspect time frame, so have pulled it.  I=
 am
> > sure that kernel.org will push this change to its mirrors at some point.
> > Just in case tree-by-tree bisecting is faster than commit-by-commit
> > bisecting.
>=20
> I have bisected it down to the rcu tree, so the three commits that were
> added yesterday are the suspects.  I am still bisecting.  If will just
> revert those three commits from linux-next today in the hope that Andrew
> will end up with a working tree.

Bisect finished:

4e40200dab0e673b019979b5b8f5e5d1b25885c2 is first bad commit
commit 4e40200dab0e673b019979b5b8f5e5d1b25885c2
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Fri Dec 10 15:02:47 2010 -0800

    rcu: fine-tune grace-period begin/end checks
   =20
    Use the CPU's bit in rnp->qsmask to determine whether or not the CPU
    should try to report a quiescent state.  Handle overflow in the check
    for rdp->gpnum having fallen behind.
   =20
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

So far 4 of my 6 boot tests that failed yesterday have succeeded today
(with those last three rcu commits reverted) - the others are still
building.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__16_Dec_2010_18_00_47_+1100_WtcUS6F9aAnBQgU3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNCbkfAAoJEDMEi1NhKgbsb8sIAI4Q7/giSPc1uoT/MlbwkN/6
ffHpEXpGNeDQAZQtW5OqgwH9EpgnjWnScvBQvmfczMvSmVCqwYOe1Ei7kA2UWrZM
vfVb1Op+GdyuA3v4RPK54vPOlLv0+uK7cYgxsOzmANc6TK61VczaIRd4QDRgg2N+
yzpkIhhGeeGnnNynabPIMVt2GDuKhQX0DuFn8206s9jDO6+KVkt+gfNHNiEzdz0A
HrU2eK7SEC7gLWDTkm45cfAN2cVuLqQa26eq3IoQqm9MIC61Yer7aStxSlkGBCsG
L6tPuSUcCMNFPPAvcSusvXZScWmrSVwH1W9znfz8yLYbEq+hO2Z+zqIdmSFdcSs=
=ex13
-----END PGP SIGNATURE-----

--Signature=_Thu__16_Dec_2010_18_00_47_+1100_WtcUS6F9aAnBQgU3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
