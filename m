Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id B9B386B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 10:49:53 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id r6so1648331wey.24
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 07:49:52 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: compare MIGRATE_ISOLATE selectively
In-Reply-To: <1355981152-2505-1-git-send-email-minchan@kernel.org>
References: <1355981152-2505-1-git-send-email-minchan@kernel.org>
Date: Thu, 20 Dec 2012 16:49:44 +0100
Message-ID: <xa1tfw30hgfb.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 20 2012, Minchan Kim wrote:
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolatio=
n.h
> index a92061e..4ada4ef 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -1,6 +1,25 @@
>  #ifndef __LINUX_PAGEISOLATION_H
>  #define __LINUX_PAGEISOLATION_H
>=20=20
> +#ifdef CONFIG_MEMORY_ISOLATION
> +static inline bool page_isolated_pageblock(struct page *page)
> +{
> +	return get_pageblock_migratetype(page) =3D=3D MIGRATE_ISOLATE;
> +}
> +static inline bool mt_isolated_pageblock(int migratetype)
> +{
> +	return migratetype =3D=3D MIGRATE_ISOLATE;
> +}

Perhaps =E2=80=9Cis_migrate_isolate=E2=80=9D to match already existing =E2=
=80=9Cis_migrate_cma=E2=80=9D?
Especially as the =E2=80=9Cmt_isolated_pageblock=E2=80=9D sound confusing t=
o me, it
implies that it works on pageblocks which it does not.

> +#else
> +static inline bool page_isolated_pageblock(struct page *page)
> +{
> +	return false;
> +}
> +static inline bool mt_isolated_pageblock(int migratetype)
> +{
> +	return false;
> +}
> +#endif
>=20=20
>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  			 bool skip_hwpoisoned_pages);
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
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQ0zOZAAoJECBgQBJQdR/0JaQP+wUiFmn/WVrdrXO37kDHr1uw
unGc45gwZizHjGZdnTEAGiJVOTyeA1nicUZ8SoMEuv1N/L1iPjqa+diWGlqh7S2+
3NoXVlzitMEqy1aWQEl8NZIQbcAEak29WlpVDQZhC7CyyoY3qC/tn3z9OC63AiuG
lKxRRvMnF0GcIqBSnj4XLOkO+tIviooIiGxdbERstim8okxojQs894NDrQkrKzA7
94thgXChhGEsx3BmRGVbYnoT0Z7Hcz8WAM3Jjv+hxQtNW1x+7oo6G2uWNMnwspfG
L3oajPjVYxrMxg3JtGq//ISF0THg6NMJbnhCZnYZrffFe+r45eELKX+mIulojcNp
yRmZojuobVGmKIulWan+F/LjZaVmMHb8n6TH7Rs5jXx4D7XA58SgC8mLCfZg6wrJ
mjeNZWFgmDuF6M+cDovTW0xdfuCmJajPvSxvXtNNa3KFpFOphMq/6YuVfzaJoqfL
slDkQ47slEtSlbFWuPhXdHbsK9xddScOHL8aAmEe6EyrRW2hdDD1pwVsY/ThDRL3
BzFIuejZmcEe6pYUzmMlJ0uGS0TtmT4vkiDdbUieo+Hp53i8Du0Gy35Dd2bY0GUB
L6o61GLFx3Fge5yq9DSU7MwghJdcmNla//y0y3GmmEz2V6LJdHyDgobt8KMF6+Zf
cn7HO40PeY0lUnRpXALq
=7hVI
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
