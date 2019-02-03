Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09CA8C169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 12:12:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6977217D6
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 12:12:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nFfWeqvC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6977217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 566428E0021; Sun,  3 Feb 2019 07:12:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EF6A8E001C; Sun,  3 Feb 2019 07:12:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38FDC8E0021; Sun,  3 Feb 2019 07:12:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF1AE8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 07:12:19 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id t22-v6so2532167lji.14
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 04:12:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=10Q4A8cRCVZ62JEp8/wkwk+13xjXhUiGKYrwNjDciL8=;
        b=bdH5zVG5Fg91RcXFTy6GF1GrLug5WXCbqfh2NioGQCNYVb7asRSBbMB1mkMJan900b
         W5ACStE9+Cw5UroQQROQul+aBi9sWH4rK1a0/nmNIB+6GGpzk9oQtLtp8S7mp8tDOrPG
         3Q6AeERgjqFMC8O19yB1DrEzjahU6p0UtR1hx8DCq6PCtE56U2WB+i/DYGTrAV5c+iSj
         tIX2tIrruW6PqmYERZh4VCer5ZvZ9QvaE/2XTlzmea0xjGncRJpgtoah6phwscEMLkmz
         JCPPdQ+/Pfck/L1IqGz7Mkd6Zu9ZPB1HoC6rSDVRZtv8oqm4rp4x6yUCGV+oaOx/j9nf
         +hNg==
X-Gm-Message-State: AJcUukeyPfLYb96Nqq9/SMZ+IjQS6rAKKf1k1ck7jLoQchoShIKIdW9y
	euqssGfwaQ22X/iwaYucckNED/0oBNUPUtsKqH1lOdEZBwRLhSow5knXsBEOlf3GDAsnNbL2A2W
	wgwnLcZvxllyJkuQ2nchWkUvLWUHtV15NW9uBqZPphkdBgeMccW5ZvkUYoICYPjC17fBypho3t5
	334XXZ3XKOYnC1BGqW0OxAJaUlQnXSy5WVEOJNh1MY2gTCAAJx6MiaUONkgJnBjxwSsKFb2wGB/
	ui+jypBkMtoJoiw966pRq1IUJPoq6tBw0uc3UsmLSXDUgixnDvwD4UbGxIRIRGa85pDtdIFdZg6
	N/663f1NiTEokFbmjK6LufRcDTTjhx5bZQ8DtqxY8OlOqjymMTMb80vJ7XCmAkA7WKaXDCx+TNe
	7
X-Received: by 2002:a2e:7e04:: with SMTP id z4-v6mr38430571ljc.97.1549195939114;
        Sun, 03 Feb 2019 04:12:19 -0800 (PST)
X-Received: by 2002:a2e:7e04:: with SMTP id z4-v6mr38430541ljc.97.1549195938133;
        Sun, 03 Feb 2019 04:12:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549195938; cv=none;
        d=google.com; s=arc-20160816;
        b=R9iuly4aaSNy1qudkXPn2hM+sLqd1hr/MUHn1Ux/kQAvrqciwqTT0qHVhpdZCPVN5G
         C/AT+GUN/xj8CFycyGw48B+szNiMGWzMoSQilUpdesejWl3Om25bmhAdHYuk91+DOq4J
         jaTw7IUtZ32c5HXOVxvBJ7Mo6vh4qa6kkQupywZUHh1JF/BRYF63EufsWo8vkpGAzFaG
         2HggX10I8WemvpAJAaOLfXCQGtvuC9G0FmhGSkE8eLvyFfvEthgZrFc6Sr5tNvDLJd7/
         JsMOAb+vKRP7mw8XZ41UqZLOshAd2wI0UJN9hAGOOEDULgsEVQNW09+/Z/A9tmZubiln
         0fDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=10Q4A8cRCVZ62JEp8/wkwk+13xjXhUiGKYrwNjDciL8=;
        b=XMgasF9/6WvT/RzXHzyzxjpI4xI9SPK3Rynlw/m5omyEvfpyj+vFETe7rE0n/auzOp
         rDiBkoxd8+o31oq9qrm3II13lhlEaCAYRV3pontkjqe83CXRI1ARve8wv4HFArw7aJ1z
         PHurQ3zOGEhOYUKnok7fU0Joq+gDEeHBlf0gViRFrmWl8Yke6hFiqgDzLqDH5goD9x4o
         NXYWEhs+0RHrXbItzdRFQItxx89awdPjbV0U6fzkjcph0m8CoFq6GEUJ0XbXQ5znSLD1
         muZPa1jd7fP1lXid4n0FOTmKnx/pDAGzijFI75UBy+Sej7EswjTWkd+VyvugBb4U5JXs
         WELg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nFfWeqvC;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor7734292ljg.0.2019.02.03.04.12.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Feb 2019 04:12:18 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nFfWeqvC;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=10Q4A8cRCVZ62JEp8/wkwk+13xjXhUiGKYrwNjDciL8=;
        b=nFfWeqvCAFPf7SyAF02GxnT6T0aeeFZK6SDzSFPnAFHXCMXkqhXP7WaR//u0/QIFBo
         /krDPpuTpTU25c9htE+FY6UCucyRl3ngWDnoPEEmSNY+EMfNZi1gCS4HCK47bBIZPjLv
         H8IGi9gskuDoZz5cDX8mxEJeyeekYVEBnCIkRlyOrU67eqkuRY49O7Cc+JBbj+Bt9IDY
         v2MIw2+a2Bquf7hsXOZRor6Uzyaut/+b7elxyDnGP3FG6DeUPTmhuAq4eaXbeyiVR90j
         EHy1JWUSAH/6YHsTI0u4a9jeu/oM2RgBidKqsATvR2UgYsR+RR0Z9iQdSVoclpV3U0p1
         P0AQ==
X-Google-Smtp-Source: ALg8bN7afLT02AkCWiIGrjJWd2raxmzBBviphe+sD/WPR2mbwBp3XwWNgngc6PGN+CjVjnQIWU1Bpfwx9bsgBTYtJlE=
X-Received: by 2002:a2e:9849:: with SMTP id e9-v6mr36673565ljj.9.1549195937638;
 Sun, 03 Feb 2019 04:12:17 -0800 (PST)
MIME-Version: 1.0
References: <20190131031222.GA2356@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190131031222.GA2356@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 3 Feb 2019 17:42:09 +0530
Message-ID: <CAFqt6zbw4wbjMYjRs_Sy6BegzqOSq_YK27rhjHw_dr_jR8neAw@mail.gmail.com>
Subject: Re: [PATCHv2 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, joro@8bytes.org, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Joerg,

On Thu, Jan 31, 2019 at 8:38 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Can you please help to review this patch ?

> ---
>  drivers/iommu/dma-iommu.c | 12 +-----------
>  1 file changed, 1 insertion(+), 11 deletions(-)
>
> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> index d19f3d6..bdf14b87 100644
> --- a/drivers/iommu/dma-iommu.c
> +++ b/drivers/iommu/dma-iommu.c
> @@ -620,17 +620,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
>
>  int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
>  {
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -       int ret = -ENXIO;
> -
> -       for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
> -               ret = vm_insert_page(vma, uaddr, pages[i]);
> -               if (ret)
> -                       break;
> -               uaddr += PAGE_SIZE;
> -       }
> -       return ret;
> +       return vm_insert_range(vma, pages, PAGE_ALIGN(size) >> PAGE_SHIFT);
>  }
>
>  static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
> --
> 1.9.1
>

