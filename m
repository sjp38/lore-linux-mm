Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6348E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 03:37:51 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e17so9151605wrw.13
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 00:37:51 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id z4si19207480wrt.275.2018.12.28.00.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 00:37:50 -0800 (PST)
Date: Fri, 28 Dec 2018 09:37:49 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/2] put_user_page*(): start converting the call sites
Message-ID: <20181228083749.GC6341@amd>
References: <20181204001720.26138-1-jhubbard@nvidia.com>
 <b31c7b3359344e778fc525013eeece64@AcuMS.aculab.com>
 <cfba998a-8217-bf03-f0d0-c95708aea03d@nvidia.com>
 <e7cac96b06664c46bde3abe72ecab2ee@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="E/DnYTRukya0zdZ1"
Content-Disposition: inline
In-Reply-To: <e7cac96b06664c46bde3abe72ecab2ee@AcuMS.aculab.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: 'John Hubbard' <jhubbard@nvidia.com>, "'john.hubbard@gmail.com'" <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Tom Talpey <tom@talpey.com>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>


--E/DnYTRukya0zdZ1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > This "patch 0000" is not a commit message, as it never shows up in git =
log.
> > Each of the follow-up patches does have details about the changes it ma=
kes.
>=20
> I think you should still describe the change - at least in summary.
>=20
> The patch I looked at didn't really...
> IIRC it still referred to external links.
>=20
> > But maybe you are really asking for more background information, which I
> > should have added in this cover letter. Here's a start:
> >=20
> > https://lore.kernel.org/r/20181110085041.10071-1-jhubbard@nvidia.com
>=20
> Yes, but links go stale....

It should really explain what the end goal is... and not even the
20181110085041.10071-1-jhubbard@nvidia.com explains that.

It seems you are introducing small slowdown to simplify something...?

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--E/DnYTRukya0zdZ1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlwl4N0ACgkQMOfwapXb+vKh7ACeJVdQzFocpewJi2c4F2t+if6H
56UAoL1qhPFQFE851+GkLtCwOWVQx1mC
=9WNe
-----END PGP SIGNATURE-----

--E/DnYTRukya0zdZ1--
