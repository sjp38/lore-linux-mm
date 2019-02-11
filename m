Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4CCDC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:31:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 767F62186A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:31:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r8LNa58f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 767F62186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DFE38E0148; Mon, 11 Feb 2019 14:31:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28EC78E0134; Mon, 11 Feb 2019 14:31:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A5408E0148; Mon, 11 Feb 2019 14:31:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id E44468E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:31:26 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id m128so27956itd.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:31:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8faLjypp9oBqvvmAUk/zBcM9e4IAAl0A1mCRvgstVWk=;
        b=gudtb8lVYCUS+pTNZIkdy4eZBz9+6kJ4dAGX7N5cj+SPAjBaoCF33nv5s0GfxeAzwy
         3E7n1dS8fk9htxECA3jBsC9Bei5ZUZbzvHauR9aeiuRg2I21se/PDekT2XF6QutVTc51
         Y18vB4I5MtN3IHSg5v0Art5duw/0EFL5v2dEGzAAaulqpblpMiXiTkHO0edPocOXtU6o
         hTmYipQcw3xzmMj29L0iZK/cJ75KlZh+V5jsj+qkYDuozuAF8w/zvUCU7sWgmwOmJiA2
         al/YCzUOI8DdMNkxjhcoyhfvsDWnD8p0YTwuznlD2lpcz7Zr11ozug3m1G2tI52OEoL7
         njFw==
X-Gm-Message-State: AHQUAuZ5giLzQ9Chh8+xK9/w83F26/FegEO6MrBgCKgAOpoopkldCOYZ
	9nJ9wgbqFpytQee2NSBBEv6a9RqklBdMUgaL7rtbwNtUGUExlMwCC597w8O6z6zK8Zx1Q8t+5ks
	wNAkisanqfuJnPpT2vZhOedVs/iYqQnLYgRbBKzOli1/ZiFpjbQszKkMJT2J5L8bcP8UIcMtfJF
	kOyFzK30q6TFy4R5QQ1DeF45AzU1eMh1GDrVGKJd0Z7fSYxEq4sDwT4IPw56MCETzcJ01I3uXHx
	e3KjyuNddiuAaL9uZB0hSvFCKSrSiTEmg6XuxcJDKM9xK39OzSChif8JITnVWD2O2EXTh8OZbjr
	zGW7sn8VmAu1aiWKizma2NhxE5zFnnsqXDUJNvK+N1EInohIAoexAM3a2RS77JQeHIYjZRmb1sL
	8
X-Received: by 2002:a24:194b:: with SMTP id b72mr627225itb.44.1549913486643;
        Mon, 11 Feb 2019 11:31:26 -0800 (PST)
X-Received: by 2002:a24:194b:: with SMTP id b72mr627196itb.44.1549913485838;
        Mon, 11 Feb 2019 11:31:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549913485; cv=none;
        d=google.com; s=arc-20160816;
        b=fETjjGzhzZ2bfUtqSwZKh7S2Zw92Zc7S2P1EJtdHpR+7iLejAzwhM/Ji2Rf5ZAD6YS
         Y8FbyOcNpgOzTNR2YSP/Ogj0yRc4SAyHuWIFtaBX2T4X1mOcoGlP5h/YPB4v86gUAeYl
         BN3eq/nnBZJYoJdJI6Puna0bsz93bRjs8XiB1uITTfF8/IYUAqluHxJ5q24UKreDCMt5
         A7CloqVhMCBIVMSeOkK+zvMSqhwphGbZCksNd2qKbqlZgZu8F3o5fZnKovsrpcAaqcAi
         k8UkBIIYxCFbLAsrHiN0SRlCxyMoIozD1KzR0pSmvmdEAdmArO+H2CDT92yegCkG/GvL
         Bk/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8faLjypp9oBqvvmAUk/zBcM9e4IAAl0A1mCRvgstVWk=;
        b=LN6DA8UFAf+lxhi0SPik6XBEVKfaRLI4AYCr1MgjZ7OuATRCWVAWZfawM5bCBevaY8
         JOu2NScf0ATZEc+9Es4XD8eoBsoOZeyn5T5EbiiCaP2VShbLhAIgpAS4bG5vAn4gtFJO
         GJ1EqLafGXRdOCbEAFS+VFHa+GSkPRBC3686m+qVeMC56dxTzgkQ/3VuDKbceSDhOyIU
         u415zvjLRv1Yg9Doi99D0Xa1jSExk0hhDRZ1NRQvhZj9lN9a6cK5V9e3GDCHbGrFVmi/
         FBLh3qJPJr0+Drw/ZGRT5bQz+SJ11+1dNJDFeLjrWkPogl3kHqwPIZpDWaH9BSXhhYbm
         cr8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r8LNa58f;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x16sor23971881jao.9.2019.02.11.11.31.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 11:31:25 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r8LNa58f;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8faLjypp9oBqvvmAUk/zBcM9e4IAAl0A1mCRvgstVWk=;
        b=r8LNa58feN1ABfdDIplriW3jrBSM5pVzLIOPNlYyZgjnILMm6J+HideLRw04s5a7dq
         g2b1awQ8SzwHub3bHyeUaOVCa0K6xY1S3B4GQJU409S1fbj8xSkpyrbK7qzSaA28xW0n
         t3uV8qyizxDBgdZapizjs1/h6Y/nROe2qn0c6tmtV9lc82MX05nA3oerhKG9WrnXLb+n
         4lU1P0gjsMJZmssxGoBocl+jbq7ADmUk+nx2CcYWOtFg19uNnl/gMAGqWD1MwDXSSpm3
         bpAMkBUjJSf4oE8mphJnAXXvUenRB+CSut3rp0c8Pbm1nLvtA1NVo6r4rxJ1b4Bl6KeC
         L0lg==
X-Google-Smtp-Source: AHgI3IalfCrC5KhHPFaIunNDXZsRyO0/wYAJ1hZUoSYqvyF8sZsLYjsp5odUjo0EyHXbwGjTt9OPlG1At59c+9S5NvE=
X-Received: by 2002:a02:9f86:: with SMTP id a6mr5572263jam.87.1549913485345;
 Mon, 11 Feb 2019 11:31:25 -0800 (PST)
MIME-Version: 1.0
References: <154990116432.24530.10541030990995303432.stgit@firesoul> <154990121192.24530.11128024662816211563.stgit@firesoul>
In-Reply-To: <154990121192.24530.11128024662816211563.stgit@firesoul>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 11 Feb 2019 11:31:13 -0800
Message-ID: <CAKgT0Ucw_HGaice7cjM7e_nYuvjU_TKVd54Yc_fHen1pZRkUJw@mail.gmail.com>
Subject: Re: [net-next PATCH 2/2] net: page_pool: don't use page->private to
 store dma_addr_t
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>, 
	Ilias Apalodimas <ilias.apalodimas@linaro.org>, Matthew Wilcox <willy@infradead.org>, 
	Saeed Mahameed <saeedm@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mel Gorman <mgorman@techsingularity.net>, "David S. Miller" <davem@davemloft.net>, 
	Tariq Toukan <tariqt@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 8:07 AM Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
>
> As pointed out by David Miller the current page_pool implementation
> stores dma_addr_t in page->private.
> This won't work on 32-bit platforms with 64-bit DMA addresses since the
> page->private is an unsigned long and the dma_addr_t a u64.
>
> A previous patch is adding dma_addr_t on struct page to accommodate this.
> This patch adapts the page_pool related functions to use the newly added
> struct for storing and retrieving DMA addresses from network drivers.
>
> Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  net/core/page_pool.c |   13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/page_pool.c b/net/core/page_pool.c
> index 43a932cb609b..897a69a1477e 100644
> --- a/net/core/page_pool.c
> +++ b/net/core/page_pool.c
> @@ -136,7 +136,9 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
>         if (!(pool->p.flags & PP_FLAG_DMA_MAP))
>                 goto skip_dma_map;
>
> -       /* Setup DMA mapping: use page->private for DMA-addr
> +       /* Setup DMA mapping: use 'struct page' area for storing DMA-addr
> +        * since dma_addr_t can be either 32 or 64 bits and does not always fit
> +        * into page private data (i.e 32bit cpu with 64bit DMA caps)
>          * This mapping is kept for lifetime of page, until leaving pool.
>          */
>         dma = dma_map_page(pool->p.dev, page, 0,
> @@ -146,7 +148,7 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
>                 put_page(page);
>                 return NULL;
>         }
> -       set_page_private(page, dma); /* page->private = dma; */
> +       page->dma_addr = dma;
>
>  skip_dma_map:
>         /* When page just alloc'ed is should/must have refcnt 1. */
> @@ -175,13 +177,16 @@ EXPORT_SYMBOL(page_pool_alloc_pages);
>  static void __page_pool_clean_page(struct page_pool *pool,
>                                    struct page *page)
>  {
> +       dma_addr_t dma;
> +
>         if (!(pool->p.flags & PP_FLAG_DMA_MAP))
>                 return;
>
> +       dma = page->dma_addr;
>         /* DMA unmap */
> -       dma_unmap_page(pool->p.dev, page_private(page),
> +       dma_unmap_page(pool->p.dev, dma,
>                        PAGE_SIZE << pool->p.order, pool->p.dma_dir);
> -       set_page_private(page, 0);
> +       page->dma_addr = 0;
>  }
>
>  /* Return a page to the page allocator, cleaning up our state */

This comment is unrelated to this patch specifically, but applies more
generally to the page_pool use of dma_unmap_page.

So just looking at this I am pretty sure the use of just
dma_unmap_page isn't correct here. You should probably be using
dma_unmap_page_attrs and specifically be passing the attribute
DMA_ATTR_SKIP_CPU_SYNC so that you can tear down the mapping without
invalidating the contents of the page.

This is something that will work for most cases but if you run into a
case where this is used with SWIOTLB in bounce buffer mode you would
end up potentially corrupting data on the unmap call.

