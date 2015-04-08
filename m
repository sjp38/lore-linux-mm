Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 29DFE6B0071
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 16:55:07 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so100950110wgb.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 13:55:06 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id jb14si20651029wic.37.2015.04.08.13.55.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 13:55:05 -0700 (PDT)
Received: by widdi4 with SMTP id di4so69549114wid.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 13:55:05 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm-cma-add-functions-to-get-region-pages-counters-fix-3
In-Reply-To: <1428522336-9020-1-git-send-email-d.safonov@partner.samsung.com>
References: <20150408140446.GR16501@mwanda> <1428522336-9020-1-git-send-email-d.safonov@partner.samsung.com>
Date: Wed, 08 Apr 2015 22:55:02 +0200
Message-ID: <xa1tbniyfihl.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <d.safonov@partner.samsung.com>, dan.carpenter@oracle.com
Cc: kbuild@01.org, stefan.strogin@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Hocko <mhocko@suse.cz>

On Wed, Apr 08 2015, Dmitry Safonov <d.safonov@partner.samsung.com> wrote:
> Fix for the next compiler warnings:
> mm/cma_debug.c:45 cma_used_get() warn: should 'used << cma->order_per_bit=
' be a 64 bit type?
> mm/cma_debug.c:67 cma_maxchunk_get() warn: should 'maxchunk << cma->order=
_per_bit' be a 64 bit type?
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Stefan Strogin <stefan.strogin@gmail.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Pintu Kumar <pintu.k@samsung.com>
> Cc: Weijie Yang <weijie.yang@samsung.com>
> Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
> Cc: Vyacheslav Tyrtov <v.tyrtov@samsung.com>
> Cc: Aleksei Mateosian <a.mateosian@samsung.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
> ---
>  mm/cma_debug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 835e761..9459842 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -42,7 +42,7 @@ static int cma_used_get(void *data, u64 *val)
>  	/* pages counter is smaller than sizeof(int) */
>  	used =3D bitmap_weight(cma->bitmap, (int)cma->count);
>  	mutex_unlock(&cma->lock);
> -	*val =3D used << cma->order_per_bit;
> +	*val =3D (u64)used << cma->order_per_bit;
>=20=20
>  	return 0;
>  }
> @@ -64,7 +64,7 @@ static int cma_maxchunk_get(void *data, u64 *val)
>  		maxchunk =3D max(end - start, maxchunk);
>  	}
>  	mutex_unlock(&cma->lock);
> -	*val =3D maxchunk << cma->order_per_bit;
> +	*val =3D (u64)maxchunk << cma->order_per_bit;
>=20=20
>  	return 0;
>  }
> --=20
> 2.3.5
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
