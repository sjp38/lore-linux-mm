Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 343D06B0033
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 04:25:00 -0400 (EDT)
Date: Tue, 16 Jul 2013 18:00:26 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH] mm/hugetlb: per-vma instantiation mutexes
Message-ID: <20130716080026.GA8925@voom.fritz.box>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
 <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
 <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
 <20130715072432.GA28053@voom.fritz.box>
 <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
 <1373933551.4622.12.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Content-Disposition: inline
In-Reply-To: <1373933551.4622.12.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 15, 2013 at 05:12:31PM -0700, Davidlohr Bueso wrote:
> On Mon, 2013-07-15 at 16:08 -0700, Andrew Morton wrote:
> > On Mon, 15 Jul 2013 17:24:32 +1000 David Gibson <david@gibson.dropbear.=
id.au> wrote:
> >=20
> > > I have previously proposed a correct method of improving scalability,
> > > although it doesn't eliminate the lock.  That's to use a set of hashed
> > > mutexes.
> >=20
> > Yep - hashing the mutexes is an obvious and nicely localized way of
> > improving this.  It's a tweak, not a design change.
> >=20
> > The changelog should describe the choice of the hash key with great
> > precision, please.  It's important and is the first thing which
> > reviewers and readers will zoom in on.

Yeah, that is important.

I no longer have much interest in the result of this patch, so I'll
leave it to others to do the forward port and cleanup.

But I will point out the gotcha here is that the hash key needs to be
based on (address_space & file offset) for MAP_SHARED, but (mm &
address) for MAP_PRIVATE.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iEYEARECAAYFAlHk/ZoACgkQaILKxv3ab8ZXcgCcDZjdB4LY0XfQKHhc02bgJ9kH
JQ4AniHdXZ9WUY/R0Jb4gLiJmdFzAAX+
=Unly
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
