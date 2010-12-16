Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6866A6B009B
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 01:08:30 -0500 (EST)
Date: Thu, 16 Dec 2010 17:08:14 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next early user mode crash (Was: Re: Transparent Hugepage
 Support #33)
Message-Id: <20101216170814.6a874692.sfr@canb.auug.org.au>
In-Reply-To: <20101216052958.GA2161@linux.vnet.ibm.com>
References: <20101215051540.GP5638@random.random>
	<20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
	<20101215171809.0e0bc3d5.akpm@linux-foundation.org>
	<20101216130251.12dbe8d8.sfr@canb.auug.org.au>
	<20101216052958.GA2161@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__16_Dec_2010_17_08_14_+1100_PAVxCv9Yt7IyiYtX"
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>
List-ID: <linux-mm.kvack.org>

--Signature=_Thu__16_Dec_2010_17_08_14_+1100_PAVxCv9Yt7IyiYtX
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Paul,

On Wed, 15 Dec 2010 21:29:58 -0800 "Paul E. McKenney" <paulmck@linux.vnet.i=
bm.com> wrote:
>
> RCU problems would normally take longer to run the system out of memory,
> but who knows?
>=20
> I did a push into -rcu in the suspect time frame, so have pulled it.  I am
> sure that kernel.org will push this change to its mirrors at some point.
> Just in case tree-by-tree bisecting is faster than commit-by-commit
> bisecting.

I have bisected it down to the rcu tree, so the three commits that were
added yesterday are the suspects.  I am still bisecting.  If will just
revert those three commits from linux-next today in the hope that Andrew
will end up with a working tree.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__16_Dec_2010_17_08_14_+1100_PAVxCv9Yt7IyiYtX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNCazOAAoJEDMEi1NhKgbsv/0H/iELZ0Z2qcADCAdtlw4H6Qmx
miMgjDO/fZ6db597Uib+vf4m9bTzw916hO6KEvbsT7eBSlpl+EepGm68QnTr1ALw
E3uuOgrwGDejfrl1hHMoS6kAl7nHqgx7tax8XiBwh5P7WD0N0VmFXfFXjxjXu9Mv
Ir30l7qN7fxYNPwY6raKdxEBle8pS9ouCtYbgqB7Q0FO2GX6N3fLt/fxoodDIYnj
vJt6kG1G8BC2iOoO6TU8LvKXPXoypHuFCvfYfQdix9J+krkKVoj8XGEgvHaoSWR8
h2aQ7uf9CCoLrJnvLyySQW9b9+lxAGtuR72Jhs4Ckh8OpqUXU6V6nxqGHXDZng0=
=LsKI
-----END PGP SIGNATURE-----

--Signature=_Thu__16_Dec_2010_17_08_14_+1100_PAVxCv9Yt7IyiYtX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
