Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 017536B0078
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:54:32 -0400 (EDT)
Received: by eeke49 with SMTP id e49so2343390eek.14
        for <linux-mm@kvack.org>; Mon, 03 Sep 2012 08:54:31 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 0/4] cma: fix watermark checking
In-Reply-To: <1346686384-1866-1-git-send-email-b.zolnierkie@samsung.com>
References: <1346686384-1866-1-git-send-email-b.zolnierkie@samsung.com>
Date: Mon, 03 Sep 2012 17:54:23 +0200
Message-ID: <xa1tligrumog.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, minchan@kernel.org, mgorman@suse.de, kyungmin.park@samsung.com

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> writes:
> Free pages belonging to Contiguous Memory Allocator (CMA) areas cannot be
> used by unmovable allocations and this fact should be accounted for while
> doing zone watermark checking.  Additionaly while CMA pages are isolated
> they shouldn't be included in the total number of free pages (as they
> cannot be allocated while they are isolated).  The following patch series
> should fix both issues.  It is based on top of recent Minchan's CMA series
> (https://lkml.org/lkml/2012/8/14/81 "[RFC 0/2] Reduce alloc_contig_range
> latency").
>
> v2:
> - no need to call get_pageblock_migratetype() in free_one_page() in patch=
 #1
>   (thanks to review from Michal Nazarewicz)
> - fix issues pointed in http://www.spinics.net/lists/linux-mm/msg41017.ht=
ml
>   in patch #2 (ditto)
> - remove no longer needed is_cma_pageblock() from patch #2

I'm not an expert on watermarks but the code of the whole patchset looks
good to me.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQRNKvAAoJECBgQBJQdR/07QYQAIeKhfARpD9alaCxPJY9UPH3
vV+tqlFqa/XZOKquQI24wWgQFdbuDxfSD+9ybxT2/jOFikrPotPYq6iAgIlpm0Yq
VXElTgVeBo4dUf/CaaSclw/9lNT1bOMzoJ1FY/TbcEDeuMmIROZe5TR6ers851EC
V3JDt0ouNCu9bHWarH4tRKC3VzJhmL75IHBQlPp58x/qaQ9NutWkJ2Q57h9d45+x
IOrYEK9qlmUMzOvGQ/KErDjEzfCfDEANuG3khNgR6TBBAj34VcelcO6sWaWyaEkQ
V7tL4PtkWl0NDecszMYDhd4ecsGyOpBBnA8JA0wxIOY96HOby0foGjoRzXaajTLz
/uXs1FQMMkw6IE3kUAODa/sL2eITMGtwRx9TUxp9x5qK/bU+ICA4aK6BqVdtVMKa
bqmXLZ2BiJqQD1pHKj5M3sVKc+Pyfy99ORGpJTpxkuJ/TBY2gRjbQn8Q3USWhwvu
Xq/+PcCbfZAVwlMZAdQK93wCQcHEvdeBc11DjlDGyRprNqi+CW6myGdgbTKQjw9t
/NLYypHxdII5MOsI2eiSM3jXnMEKssvxFMw+87EfBoC6rqoq/aNKhk2/cjGYb5JH
GEXEYvVKWsnwiQ9KCOZJONNw7YJnrq8R3hvjptuhb5NKhhiFHw9EmsZ+ERR0II7S
KXZoDflhMKvIsKaufCBp
=n1gj
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
