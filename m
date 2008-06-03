Date: Tue, 3 Jun 2008 14:46:18 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [patch 3/5] x86: lockless get_user_pages_fast
Message-Id: <20080603144618.0a4dcfc8.sfr@canb.auug.org.au>
In-Reply-To: <20080603023419.GC5527@wotan.suse.de>
References: <20080529122050.823438000@nick.local0.net>
	<20080529122602.330656000@nick.local0.net>
	<1212081659.6308.10.camel@norville.austin.ibm.com>
	<20080602101530.GA7206@wotan.suse.de>
	<20080602212833.226146bc.sfr@canb.auug.org.au>
	<20080603023419.GC5527@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__3_Jun_2008_14_46_18_+1000_g1njvM6w4ycl2OqB"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

--Signature=_Tue__3_Jun_2008_14_46_18_+1000_g1njvM6w4ycl2OqB
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Nick,

On Tue, 3 Jun 2008 04:34:20 +0200 Nick Piggin <npiggin@suse.de> wrote:
>
> Thanks for the offer... I was hoping for Andrew to pick it up (which
> he now has).
>=20
> I'm not sure how best to do mm/ related stuff, but I suspect we have
> gone as smoothly as we are in large part due to Andrew's reviewing
> and martialling mm patches so well.

Yeah, that is the correct and best way to go.

> For other developments I'll keep linux-next in mind. I guess it will
> be useful for me eg in the case where I change an arch defined prototype
> that requires a big sweep of the tree.

Yep, linux-next is idea for that because you find out all the places you
step on other people's toes :-)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__3_Jun_2008_14_46_18_+1000_g1njvM6w4ycl2OqB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIRMydTgG2atn1QN8RAvtDAJsHNRYgIzPGkVsAUYUNcZN+Eyh3+ACfeitJ
QSzEQ1WU09+zvIpUu+MtNWA=
=sMhS
-----END PGP SIGNATURE-----

--Signature=_Tue__3_Jun_2008_14_46_18_+1000_g1njvM6w4ycl2OqB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
