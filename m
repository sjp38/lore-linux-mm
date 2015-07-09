Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id AD13E6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 14:46:37 -0400 (EDT)
Received: by qgep37 with SMTP id p37so27222977qge.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 11:46:37 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id g196si7607079qhc.80.2015.07.09.11.46.36
        for <linux-mm@kvack.org>;
        Thu, 09 Jul 2015 11:46:36 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:46:35 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V3 3/5] mm: mlock: Introduce VM_LOCKONFAULT and add mlock
 flags to enable it
Message-ID: <20150709184635.GE4669@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
 <1436288623-13007-4-git-send-email-emunson@akamai.com>
 <20150708132351.61c13db6@lwn.net>
 <20150708203456.GC4669@akamai.com>
 <20150708151750.75e65859@lwn.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d8Lz2Tf5e5STOWUP"
Content-Disposition: inline
In-Reply-To: <20150708151750.75e65859@lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--d8Lz2Tf5e5STOWUP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 08 Jul 2015, Jonathan Corbet wrote:

> On Wed, 8 Jul 2015 16:34:56 -0400
> Eric B Munson <emunson@akamai.com> wrote:
>=20
> > > Quick, possibly dumb question: I've been beating my head against thes=
e for
> > > a little bit, and I can't figure out what's supposed to happen in this
> > > case:
> > >=20
> > > 	mlock2(addr, len, MLOCK_ONFAULT);
> > > 	munlock2(addr, len, MLOCK_LOCKED);
> > >=20
> > > It looks to me like it will clear VM_LOCKED without actually unlockin=
g any
> > > pages.  Is that the intended result? =20
> >=20
> > This is not quite right, what happens when you call munlock2(addr, len,
> > MLOCK_LOCKED); is we call apply_vma_flags(addr, len, VM_LOCKED, false).
>=20
> From your explanation, it looks like what I said *was* right...what I was
> missing was the fact that VM_LOCKED isn't set in the first place.  So that
> call would be a no-op, clearing a flag that's already cleared.

Sorry, I misread the original.  You are correct with the addition that
the call to munlock2(MLOCK_LOCKED) is a noop in this case.

>=20
> One other question...if I call mlock2(MLOCK_ONFAULT) on a range that
> already has resident pages, I believe that those pages will not be locked
> until they are reclaimed and faulted back in again, right?  I suspect that
> could be surprising to users.

That is the case.  I am looking into what it would take to find only the
present pages in a range and lock them, if that is the behavior that is
preferred I can include it in the updated series.

>=20
> Thanks,
>=20
> jon

--d8Lz2Tf5e5STOWUP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVnsGLAAoJELbVsDOpoOa9fD4P+wfJut0yfq/Eut90zuluJASG
y2/MKnGXk/YAwdE9jVyUs/if3S6y9E+nzr9h10jjiAzl7Ek3fbjvGQGtSJee0nxv
xprvjrX8StCUyubIAdvuvBDAQ2uruWlWPt0/WYlTppmm3Ws7sXk6Rc9uyAaYvO8k
cb/3b2hDUz4X3buHx7rbontLHI+PkJyOMC0wwhlgc/TnIyGAOINbxf4jYR9MTOP1
OjpudgitD2855bIJVi9VnOkbG7tvRqJA5azlVkcwlUBqezjSKz5K+NANc4zL5xQ1
uBN9QJXvbiGBzpKXSjmCgtQYRpUq5fN4hZOjq3lo6nill+E+F6eL415ON/5mpRvR
8JeYOUZt/Gua6W0fxLTscnp3E5cpu4oUrzY43J9jJ5HA34s0W8mj/ssey/lDxUo/
LzoeORqwByyNuESJHtHSYJUB24FDQeQJ1cjMLqoZmpyjlFnUoVgzFox+jdtwZ80P
3LMoWN7h6NyQ6GtQDHF1033vsxAHBQ04x96kch9Ztx3BGoWVZoXO1Lsr6X6EHCIV
DmQW1k8HPLsUbkXtOlGR36opxF1fbdBzAyN7V8rWXnNFiyDCl/ImUtEVKQ/VPp9k
T2FjdgDFkTetH6KHVOztE1Ya08wHX4Yy/qxxFH1sPMfVIHFUE7ATTP+00Oc30E32
vBEzC6L/dMQNWWAIbaEJ
=CLFc
-----END PGP SIGNATURE-----

--d8Lz2Tf5e5STOWUP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
