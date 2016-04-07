Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 925906B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 15:39:13 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id f105so48867163qge.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 12:39:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b93si7070037qgf.85.2016.04.07.12.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 12:39:12 -0700 (PDT)
Message-ID: <1460057945.25336.0.camel@redhat.com>
Subject: Re: [PATCH v5 2/2] mm, thp: avoid unnecessary swapin in khugepaged
From: Rik van Riel <riel@redhat.com>
Date: Thu, 07 Apr 2016 15:39:05 -0400
In-Reply-To: <20160407185854.GO2258@uranus.lan>
References: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1460050081-10765-1-git-send-email-ebru.akagunduz@gmail.com>
	 <20160407185854.GO2258@uranus.lan>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-rwFNO/19ZRmfHjpfmVzC"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com


--=-rwFNO/19ZRmfHjpfmVzC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-04-07 at 21:58 +0300, Cyrill Gorcunov wrote:
> On Thu, Apr 07, 2016 at 08:28:01PM +0300, Ebru Akagunduz wrote:
> ...
> >=20
> > +	swap =3D get_mm_counter(mm, MM_SWAPENTS);
> > +	curr_allocstall =3D sum_vm_event(ALLOCSTALL);
> > +	/*
> > +	=C2=A0* When system under pressure, don't swapin readahead.
> > +	=C2=A0* So that avoid unnecessary resource consuming.
> > +	=C2=A0*/
> > +	if (allocstall =3D=3D curr_allocstall && swap !=3D)
> > +		__collapse_huge_page_swapin(mm, vma, address,
> > pmd);
> This !=3D) looks like someone got fun ;)

Looks like someone sent out emails before refreshing the
patch, which is a such an easy mistake to make I must have
done it a dozen times by now :)

--=20
All Rights Reversed.


--=-rwFNO/19ZRmfHjpfmVzC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXBrdZAAoJEM553pKExN6DAOUH/AjBx0+HOkSxdCiKmsE3Le78
NYu6m4vfTZ+OQh0qJ8Usivp+xcw0exNTEOvGvkJRo+8HzR1ZyIldSB/jf2PY1XKI
k0uF4Qrf+4AuUrys1+wGBxIT1k8F+MVvlex4YP9vDHaUxUQst3vcvVygaroYIZjc
nxPddNGKgnJqgPpWQEmRlU64bo7uFdJg4/3ZNZouxu1bxLd5yjUmpgI4EeH6Y8cf
67BlvOObv1MHzM7u81IbBOZDDba9elHatPEAUGpnYU9+iunctCaTYjPoobzmEMOc
qYnT1sW36d5HVB5u/gJk7PYB+2Ap43Hlc0I9MeJJf7n2420BmY4yfqgfKtNfJuo=
=jFUN
-----END PGP SIGNATURE-----

--=-rwFNO/19ZRmfHjpfmVzC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
