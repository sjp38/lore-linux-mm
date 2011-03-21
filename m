Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD078D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 10:25:52 -0400 (EDT)
From: Ben Hutchings <ben@decadent.org.uk>
In-Reply-To: <20110321140812.GD5719@random.random>
References: <1300676431.26693.317.camel@localhost>
	 <20110321124203.GB5719@random.random>
	 <1300713183.26693.343.camel@localhost>
	 <20110321140812.GD5719@random.random>
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-c3uRqJOBC4EAD1sSvLWJ"
Date: Mon, 21 Mar 2011 14:25:42 +0000
Message-ID: <1300717542.26693.352.camel@localhost>
Mime-Version: 1.0
Subject: Re: sysfs interface to transparent hugepages
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>


--=-c3uRqJOBC4EAD1sSvLWJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-03-21 at 15:08 +0100, Andrea Arcangeli wrote:
> On Mon, Mar 21, 2011 at 01:13:03PM +0000, Ben Hutchings wrote:
> > You have tristates {never, madvise, always} for various THM features.
> > Internally, these are represented as a pair of flags.  They are exposed
> > through sysfs as tristates, but then they are also exposed as flags.
>=20
> They must be bitflags for performance and cacheline saving reasons in
> the kernel (1 bitflag not enough in kernel for a userland
> tristate). They're more intuitive as tristate in the same file for the
> user to set (some combination of these flags is forbidden so exposing
> the flags to the user doesn't sound good idea, also considering it's
> an internal representation which may change, keeping the two separated
> is best, especially if you want your current lib not to break).
[...]

I understand all that.  However when I first looked at this I somehow
thought that the tristate values were *also* exposed as flags, but I was
mistaken.  Sorry to bother you with this non-issue.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-c3uRqJOBC4EAD1sSvLWJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATYdf4Oe/yOyVhhEJAQoJpA//WpUvIShbVKXUDUdL7S5ZrAplysIw70Mv
GfrThf1wjBsPpPU8DTsnihRp4agW3m9nt7/UPks4jAMoz13fNioMBlzI+aVXRU4G
7VpJ7W6uVlWYeGGIG5hFy2axhSmdI6A9uPhyR8cJxSgTfXYxhu0nCv0Pest84n1d
IuTmQiYojhhRac/7CZzL2ikarAAN0BWF+xiuHsZyXl9DG6VXVnlshYbeGhYi7h1k
5eJD26rDXxhZMW6A/OqLakxx9A1sECsrCm8Lcb/R8lOD41Xk8vY18VViswURqAH+
BaSSav+ZbJAMfO90QdfbZyAOEl5i/pu7tJ/J8YSKZ/wXhvkkR2izuM1wb/Dt3VDN
g9+VoiU+QmdbmeaWo6yluINp+J/lu1IEB+lK5nr5wvOmkerF4MahTtS92bcs35rY
k06de9osb0lrFhQCKEbw/ll9NmpkCV8SF6kIYU1qF1uxbwvtKnMzAi0vp6oSyA2E
o9S1K/o1KwW3342+VeOk9OgbfAnZiPZcON6/vMdjiZVqpAYZa4Be2NpS37xKzQqS
WoZ3HffW2/LBFCbMnGFnYTwOAf4prmRQ/1SlGoCUpNN0Ee1zS0gllrQTOx1N/3SS
mh0/VtKH3riKovjeoqw0bVh0KoSqTDvCHZ7gLf7xFSVvox8KCOdCwlEPQhBVgTAU
/RPsQ7y8bdo=
=hzN1
-----END PGP SIGNATURE-----

--=-c3uRqJOBC4EAD1sSvLWJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
