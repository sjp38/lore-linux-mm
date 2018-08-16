Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0466B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 07:45:49 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d10-v6so2573664pll.22
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 04:45:49 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id d1-v6si21415146pgv.76.2018.08.16.04.45.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 Aug 2018 04:45:47 -0700 (PDT)
Date: Thu, 16 Aug 2018 21:44:59 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v1 1/5] mm/memory_hotplug: drop intermediate
 __offline_pages
Message-ID: <20180816214459.64a7cec3@canb.auug.org.au>
In-Reply-To: <20180816100628.26428-2-david@redhat.com>
References: <20180816100628.26428-1-david@redhat.com>
	<20180816100628.26428-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/NCvGZErSBmGvgFoB+bM4K8L"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

--Sig_/NCvGZErSBmGvgFoB+bM4K8L
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi David,

On Thu, 16 Aug 2018 12:06:24 +0200 David Hildenbrand <david@redhat.com> wro=
te:
>
> -static int __ref __offline_pages(unsigned long start_pfn,
> -		  unsigned long end_pfn)
> +/* Must be protected by mem_hotplug_begin() or a device_lock */
> +int offline_pages(unsigned long start_pfn, unsigned long nr_pages)

You lose the __ref marking.  Does this introduce warnings since
offline_pages() calls (at least) zone_pcp_update() which is marked
__meminit.

--=20
Cheers,
Stephen Rothwell

--Sig_/NCvGZErSBmGvgFoB+bM4K8L
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlt1Y7sACgkQAVBC80lX
0GwD0Qf+IdwJnk7wIRcDbGn1AP6dqdsp2hpWrSr+qxhJbpz5F1d9SI1xYVt4NEqG
tOoWCPi57NIHRD4sQpJFaGKtzgczPMLXfmQiA54KBOkJGRcepvxIj6a6Kb5tzemu
d1Ix+NBiQ+ZJqfudhpq/AcrcOA0EZjNG4hlSmUGWwuwNe0PM6Hd2b+MDvrwNgNjz
BAEh0pTczP4d8JnB/r7TpzuiZ0cIo8dy0VIAsaVmC6Nc08TZ+xaT98U94ltX6wg0
eOlW2p0QPcskaeo0dsPmPB2dNI2RMkXf3hGL3hv3K8J5IDt6K4PUEFzrlMPHm+2A
+me39SLCp8ZfCqU0TdRUccD23BwZQA==
=wOyX
-----END PGP SIGNATURE-----

--Sig_/NCvGZErSBmGvgFoB+bM4K8L--
