Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id F387C6B0038
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 09:34:40 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so12326115wgg.16
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 06:34:40 -0700 (PDT)
Received: from mail-we0-x233.google.com (mail-we0-x233.google.com [2a00:1450:400c:c03::233])
        by mx.google.com with ESMTPS id wf7si51526160wjb.74.2014.08.24.06.34.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 24 Aug 2014 06:34:39 -0700 (PDT)
Received: by mail-we0-f179.google.com with SMTP id u57so12138710wes.24
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 06:34:39 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/2] ARM: mm: don't limit default CMA region only to low memory
In-Reply-To: <1408610714-16204-3-git-send-email-m.szyprowski@samsung.com>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com> <1408610714-16204-3-git-send-email-m.szyprowski@samsung.com>
Date: Sun, 24 Aug 2014 15:34:36 +0200
Message-ID: <xa1tvbpiui37.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 21 2014, Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> DMA-mapping supports CMA regions places either in low or high memory, so
> there is no longer needed to limit default CMA regions only to low memory.
> The real limit is still defined by architecture specific DMA limit.
>
> Reported-by: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  arch/arm/mm/init.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index 659c75d808dc..c1b513555786 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -322,7 +322,7 @@ void __init arm_memblock_init(const struct machine_de=
sc *mdesc)
>  	 * reserve memory for DMA contigouos allocations,
>  	 * must come from DMA area inside low memory
>  	 */
> -	dma_contiguous_reserve(min(arm_dma_limit, arm_lowmem_limit));
> +	dma_contiguous_reserve(arm_dma_limit);
>=20=20
>  	arm_memblock_steal_permitted =3D false;
>  	memblock_dump_all();
> --=20
> 1.9.2
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
