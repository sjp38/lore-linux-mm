Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5B486810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:39:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w14so1362149wrc.5
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:39:39 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id u19si5915226wrg.502.2017.08.25.14.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 14:39:38 -0700 (PDT)
Date: Fri, 25 Aug 2017 23:39:36 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170825213936.GA13576@amd>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170823175709.GA22743@xo-6d-61-c0.localdomain>
 <20170825063545.GA25498@dhcp22.suse.cz>
 <20170825072818.GA15494@amd>
 <20170825080442.GF25498@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
In-Reply-To: <20170825080442.GF25498@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2017-08-25 10:04:42, Michal Hocko wrote:
> On Fri 25-08-17 09:28:19, Pavel Machek wrote:
> > On Fri 2017-08-25 08:35:46, Michal Hocko wrote:
> > > On Wed 23-08-17 19:57:09, Pavel Machek wrote:
> [...]
> > > > Dunno. < 1msec probably is temporary, 1 hour probably is not. If it=
 causes
> > > > problems, can you just #define GFP_TEMPORARY GFP_KERNEL ? Treewide =
replace,
> > > > and then starting again goes not look attractive to me.
> > >=20
> > > I do not think we want a highlevel GFP_TEMPORARY without any meaning.
> > > This just supports spreading the flag usage without a clear semantic
> > > and it will lead to even bigger mess. Once we can actually define what
> > > the flag means we can also add its users based on that new semantic.
> >=20
> > It has real meaning.
>=20
> Which is?

"This allocation is temporary. It lasts milliseconds, not hours."

> > You can define more exact meaning, and then adjust the usage. But
> > there's no need to do treewide replacement...
>=20
> I have checked most of them and except for the initially added onces the
> large portion where added without a good reasons or even break an
> intuitive meaning by taking locks.

I don't see it. kmalloc() itself takes locks. Of course everyone takes
locks. I don't think that's intuitive meaning.

> Seriously, if we need a short term semantic it should be clearly defined
> first.

"milliseconds, not hours."

> Is there any specific case why you think this patch is in a wrong
> direction? E.g. a measurable regression?

Not playing that game. You should argue why it is improvement. And I
don't believe you did.

Best regards,

								Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--tKW2IUtsqtDRztdT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmgmRgACgkQMOfwapXb+vJ2UgCglElb/+e1pPxqwMoRZsqLZwXk
pq8An0jftnFQ+KPeYDtmMOH5x0Eb4BnC
=MIek
-----END PGP SIGNATURE-----

--tKW2IUtsqtDRztdT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
