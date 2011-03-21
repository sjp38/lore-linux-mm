Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E5FA08D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 09:13:13 -0400 (EDT)
From: Ben Hutchings <ben@decadent.org.uk>
In-Reply-To: <20110321124203.GB5719@random.random>
References: <1300676431.26693.317.camel@localhost>
	 <20110321124203.GB5719@random.random>
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-Xmo4C8URIvcaO9ZySiuW"
Date: Mon, 21 Mar 2011 13:13:03 +0000
Message-ID: <1300713183.26693.343.camel@localhost>
Mime-Version: 1.0
Subject: Re: sysfs interface to transparent hugepages
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>


--=-Xmo4C8URIvcaO9ZySiuW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-03-21 at 13:42 +0100, Andrea Arcangeli wrote:
> On Mon, Mar 21, 2011 at 03:00:31AM +0000, Ben Hutchings wrote:
[...]
> > This, on the other hand, is totally ridiculous:
> >=20
> >        if (test_bit(flag, &transparent_hugepage_flags))
> >                return sprintf(buf, "[yes] no\n");
> >        else
> >                return sprintf(buf, "yes [no]\n");
> >=20
> > Why show the possible values of a boolean?  I can't even find any
> > examples of 'yes' and 'no' rather than '1' and '0'.
>=20
> As said I like that format and I've been consistent in using it.

But not consistent with anything else in sysfs.

> If you write a parser for that format in userland it's probably easier to
> be consistent.

What if I already have some general functions like read_intr_attr(),
read_bool_attr(), etc.  Should I really have to write special functions
for booleans in different parts of sysfs, depending on whether the
author liked 0/1, false/true, disabled/enabled, no/yes, or
'yes [no]'/'[yes] no'?

> Anyway this got into 2.6.38 only. For other kernels
> that shipped THP before 2.6.38 there is no
> /sys/kernel/mm/transparent_hugepage directory at all (it's renamed
> exactly to avoid any risk of sysfs ABI clashes). I doubt anybody wrote
> any parser for /sys/kernel/mm/transparent_hugepage so if this is a big
> deal I suggest you send patches to whatever you prefer.

I can do that, yes.

> Or if you tell
> me exactly how you want it, I can try to implement it and if others
> agree I don't see a problem in altering it. But others may
> disagree. Clearly best would have been if you requested a change
> during 2.6.38-rc, everyone was aware of the format as everyone has
> been twiddling with these sysfs controls. Comments welcome.

Sorry, I'm a distribution maintainer and I can't be everywhere.

> > And really, why add boolean flags for a tristate at all?
>=20
> I don't get the question sorry.

You have tristates {never, madvise, always} for various THM features.
Internally, these are represented as a pair of flags.  They are exposed
through sysfs as tristates, but then they are also exposed as flags.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-Xmo4C8URIvcaO9ZySiuW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATYdO1Oe/yOyVhhEJAQrMOg/9G7zTw1sCLuA5mX+wDcl9DigFQhygEB0q
eUl3nswkMZfbr080f/xi9NTMa8x447XU+UhYYKf+sU/DliUSXG8MvoR5zWn1upSD
09vpQrxnWLGt4I7/k2ZT6zup5l4sQ1fErEcATn/HHtB0Qpv471pPO1ygPJR1AUSg
Z9FRiGCDATbpOspYq8u6DjZWl0UeiahOSgb0DIn9QPCszkE5VoPw7SMUF64xHaOd
Zocst2Sb5VZs0Vr03Dmy9kmT4GHQYlZSGj2UUSdc8Fxdgsthp41kQalPA+aUqkmz
TIbj0CwcpAjG25JRbGjbyBvMD8oU+kKxjTEmFb4LA16/947Zr8esS3H+0Hlg2/Sx
fCxxcanDCkFp4f1xeZOt/ffJwQu+zwldsgctw2SYXzrp1RKX1OxXXEvxOpENPhFS
vV7+yNTo3fiJ4+Yeg202SLKrb7qGsExSXNIAGRQuy8kYXToofX7PfExopNTLSkHf
Jq0EJWUl/2TUJBUTg9dgppvU11bpqCaJLX8v/EvZb8CEEkqBW4exVkRewPWghE+H
XIjXOQL5+SAI8HEbXEtEB+4S+ob5Ab5wwJ6T49PXyckK+IVCL6WDuuinav8grE9z
gvvIAUljEnCskWK6MWAJCntCGWJEW7wO0W4VsNUXPrk3b0FzLoVA6ijTwIGZOCYk
LfmNBoQmlVY=
=l90T
-----END PGP SIGNATURE-----

--=-Xmo4C8URIvcaO9ZySiuW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
