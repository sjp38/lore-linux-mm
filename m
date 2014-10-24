Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id A7ECC6B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 12:37:29 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id w7so2824415lbi.22
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:37:28 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id a4si7767503lbm.77.2014.10.24.09.37.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 09:37:28 -0700 (PDT)
Received: by mail-lb0-f180.google.com with SMTP id n15so2829498lbi.39
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:37:27 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm, cma: make parameters order consistent in func declaration and definition
In-Reply-To: <000201cfef6f$c5422b10$4fc68130$%yang@samsung.com>
References: <000201cfef6f$c5422b10$4fc68130$%yang@samsung.com>
Date: Fri, 24 Oct 2014 18:37:23 +0200
Message-ID: <xa1td29h2zlo.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: m.szyprowski@samsung.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

On Fri, Oct 24 2014, Weijie Yang <weijie.yang@samsung.com> wrote:
> In the current code, the base and size parameters order is not consistent
> in functions declaration and definition. If someone calls these functions
> according to the declaration parameters order in cma.h, he will run into
> some bug and it's hard to find the reason.
>
> This patch makes the parameters order consistent in functions declaration
> and definition.
>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  include/linux/cma.h |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 0430ed0..a93438b 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -18,12 +18,12 @@ struct cma;
>  extern phys_addr_t cma_get_base(struct cma *cma);
>  extern unsigned long cma_get_size(struct cma *cma);
>=20=20
> -extern int __init cma_declare_contiguous(phys_addr_t size,
> -			phys_addr_t base, phys_addr_t limit,
> +extern int __init cma_declare_contiguous(phys_addr_t base,
> +			phys_addr_t size, phys_addr_t limit,
>  			phys_addr_t alignment, unsigned int order_per_bit,
>  			bool fixed, struct cma **res_cma);
> -extern int cma_init_reserved_mem(phys_addr_t size,
> -					phys_addr_t base, int order_per_bit,
> +extern int cma_init_reserved_mem(phys_addr_t base,
> +					phys_addr_t size, int order_per_bit,
>  					struct cma **res_cma);
>  extern struct page *cma_alloc(struct cma *cma, int count, unsigned int a=
lign);
>  extern bool cma_release(struct cma *cma, struct page *pages, int count);
> --=20
> 1.7.0.4
>
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
