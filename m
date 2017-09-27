Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 804906B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 00:06:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so20876408pff.6
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 21:06:22 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b69si6635580pfb.297.2017.09.26.21.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 21:06:21 -0700 (PDT)
Date: Wed, 27 Sep 2017 11:59:53 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH] mm: update comments for struct page.mapping
Message-ID: <20170927035953.GA13117@intel.com>
References: <1506410057-22316-1-git-send-email-changbin.du@intel.com>
 <20170926163027.12836f5006745fcf6e59ad24@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ReaqsoxgOBHFXBhH"
Content-Disposition: inline
In-Reply-To: <20170926163027.12836f5006745fcf6e59ad24@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: changbin.du@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 26, 2017 at 04:30:27PM -0700, Andrew Morton wrote:
> On Tue, 26 Sep 2017 15:14:17 +0800 changbin.du@intel.com wrote:
>=20
> > From: Changbin Du <changbin.du@intel.com>
> >=20
> > The struct page.mapping can NULL or points to one object of type
> > address_space, anon_vma or KSM private structure.
> >=20
> > ...
> >
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -47,8 +47,8 @@ struct page {
> >  						 * inode address_space, or NULL.
> >  						 * If page mapped as anonymous
> >  						 * memory, low bit is set, and
> > -						 * it points to anon_vma object:
> > -						 * see PAGE_MAPPING_ANON below.
> > +						 * it points to anon_vma object
> > +						 * or KSM private structure.
> >  						 */
> >  		void *s_mem;			/* slab first object */
> >  		atomic_t compound_mapcount;	/* first tail page */
>=20
> Why did you remove the (useful) reference to PAGE_MAPPING_ANON?

There are two flags now, let me add them back. thanks.

--=20
Thanks,
Changbin Du

--ReaqsoxgOBHFXBhH
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZyyI5AAoJEAanuZwLnPNUTCoIALp0SHey1lvHWnyMM6cwz490
Sq2XmtA3/FGoM3He2LC7TxYfoiwwlqn14qylyVc9rtFxqEHtXVXPGpuE7cK0L+oW
Lp++ymDYjZOI5ewPuh+j93BkQxyoz4qOeo/LzIbnRUBJ1aeFv6axVHQV0uK0zFZZ
IeEDP2JkjICLDAswgYIcyJ9a75ISSD0mE+viC9CBVL4yWnC7Rs4QCN8GTeMl15Oa
3Qn4hWkQycErvOdB77IJZkh9UMy4ZbmJQSSBjiKQ0gWbmNYJGJTf4e5FHDGzxkWz
fAxyHakN0fipQPswss3vTUTs29Y04M+tziF4wElnXcZz+ef1vw0SsY9RNASelqE=
=jgbl
-----END PGP SIGNATURE-----

--ReaqsoxgOBHFXBhH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
