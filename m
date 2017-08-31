Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 49E226B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 05:10:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r75so3133093wmf.11
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:10:27 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id v2si4653323wme.46.2017.08.31.02.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 02:10:26 -0700 (PDT)
Date: Thu, 31 Aug 2017 11:10:25 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170831091024.GB12920@amd>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170823175709.GA22743@xo-6d-61-c0.localdomain>
 <20170825063545.GA25498@dhcp22.suse.cz>
 <20170825072818.GA15494@amd>
 <20170825080442.GF25498@dhcp22.suse.cz>
 <20170825213936.GA13576@amd>
 <20170828123542.GJ17097@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QKdGvSO+nmPlgiQ/"
Content-Disposition: inline
In-Reply-To: <20170828123542.GJ17097@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>


--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > > > You can define more exact meaning, and then adjust the usage. But
> > > > there's no need to do treewide replacement...
> > >=20
> > > I have checked most of them and except for the initially added onces =
the
> > > large portion where added without a good reasons or even break an
> > > intuitive meaning by taking locks.
> >=20
> > I don't see it. kmalloc() itself takes locks. Of course everyone takes
> > locks. I don't think that's intuitive meaning.
>=20
> I was talking about users of the flag. I have seen some to take a lock
> right after they allocated GFP_TEMPORARY object.

Yes, I'd expect people to take locks after allocating temporary
objects. kmalloc itself takes locks. If the allocation is "usually"
freed within miliseconds, that should be enough.

> > > Seriously, if we need a short term semantic it should be clearly defi=
ned
> > > first.
> >=20
> > "milliseconds, not hours."
> >=20
> > > Is there any specific case why you think this patch is in a wrong
> > > direction? E.g. a measurable regression?
> >=20
> > Not playing that game. You should argue why it is improvement. And I
> > don't believe you did.
>=20
> Please read the whole changelog where I was quite verbose about how the
> current flag is abused and how its semantic is weak and encourages a
> wrong usage pattern. Moreover it is not even clear whether it helps
> anything. I haven't seen any actual counter argument from you other than
> "milliseconds not hours" without actually explaining how that would be
> useful for any decisions done in the core MM layer.

Well, I find that argumentation insufficient for global
search&replace.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--QKdGvSO+nmPlgiQ/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmn0oAACgkQMOfwapXb+vI1WgCgrLLQZGydVVIMREzWgbfJcZNW
brgAnR2Zm8zGCxmfGTtSwVWSoIxCmSJZ
=8kBv
-----END PGP SIGNATURE-----

--QKdGvSO+nmPlgiQ/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
