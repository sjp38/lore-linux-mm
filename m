Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8837D6B006C
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 12:56:22 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id gf13so1362310lab.15
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:56:21 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id aq3si3481978lbc.78.2014.10.23.09.56.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 09:56:21 -0700 (PDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so1238397lab.16
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:56:20 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 4/4] mm: cma: Use %pa to print physical addresses
In-Reply-To: <1414074828-4488-5-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1414074828-4488-5-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Date: Thu, 23 Oct 2014 18:56:15 +0200
Message-ID: <xa1th9yulo7k.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Oct 23 2014, Laurent Pinchart wrote:
> Casting physical addresses to unsigned long and using %lu truncates the
> values on systems where physical addresses are larger than 32 bits. Use
> %pa and get rid of the cast instead.
>
> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.co=
m>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/cma.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index b83597b..741c7ec 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -212,9 +212,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	phys_addr_t highmem_start =3D __pa(high_memory);
>  	int ret =3D 0;
>=20=20
> -	pr_debug("%s(size %lx, base %08lx, limit %08lx alignment %08lx)\n",
> -		__func__, (unsigned long)size, (unsigned long)base,
> -		(unsigned long)limit, (unsigned long)alignment);
> +	pr_debug("%s(size %pa, base %pa, limit %pa alignment %pa)\n",
> +		__func__, &size, &base, &limit, &alignment);
>=20=20
>  	if (cma_area_count =3D=3D ARRAY_SIZE(cma_areas)) {
>  		pr_err("Not enough slots for CMA reserved regions!\n");
> @@ -257,8 +256,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	 */
>  	if (fixed && base < highmem_start && base + size > highmem_start) {
>  		ret =3D -EINVAL;
> -		pr_err("Region at %08lx defined on low/high memory boundary (%08lx)\n",
> -			(unsigned long)base, (unsigned long)highmem_start);
> +		pr_err("Region at %pa defined on low/high memory boundary (%pa)\n",
> +			&base, &highmem_start);
>  		goto err;
>  	}
>=20=20
> @@ -316,8 +315,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	if (ret)
>  		goto err;
>=20=20
> -	pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
> -		(unsigned long)base);
> +	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
> +		&base);
>  	return 0;
>=20=20
>  err:
> --=20
> 2.0.4
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
