Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BB1DA6B00D5
	for <linux-mm@kvack.org>; Mon, 25 May 2015 11:54:36 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so76063443wgb.3
        for <linux-mm@kvack.org>; Mon, 25 May 2015 08:54:36 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id ym6si18895620wjc.130.2015.05.25.08.54.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 08:54:35 -0700 (PDT)
Received: by wgme6 with SMTP id e6so7555581wgm.2
        for <linux-mm@kvack.org>; Mon, 25 May 2015 08:54:34 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm:cma - Fix for typos in comments.
In-Reply-To: <1432357847-4434-1-git-send-email-shailendra.capricorn@gmail.com>
References: <1432357847-4434-1-git-send-email-shailendra.capricorn@gmail.com>
Date: Mon, 25 May 2015 17:54:31 +0200
Message-ID: <xa1tr3q4ps94.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shailendra Verma <shailendra.capricorn@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Sat, May 23 2015, Shailendra Verma wrote:
> Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/cma.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index 3a7a67b..6612780 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -182,7 +182,7 @@ int __init cma_init_reserved_mem(phys_addr_t base, ph=
ys_addr_t size,
>  	if (!size || !memblock_is_region_reserved(base, size))
>  		return -EINVAL;
>=20=20
> -	/* ensure minimal alignment requied by mm core */
> +	/* ensure minimal alignment required by mm core */
>  	alignment =3D PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
>=20=20
>  	/* alignment should be aligned with order_per_bit */
> @@ -238,7 +238,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	/*
>  	 * high_memory isn't direct mapped memory so retrieving its physical
>  	 * address isn't appropriate.  But it would be useful to check the
> -	 * physical address of the highmem boundary so it's justfiable to get
> +	 * physical address of the highmem boundary so it's justifiable to get
>  	 * the physical address from it.  On x86 there is a validation check for
>  	 * this case, so the following workaround is needed to avoid it.
>  	 */
> --=20
> 1.7.9.5
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
