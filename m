Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95CBCC169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 12:16:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45263217D6
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 12:16:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DEFZB7m2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45263217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3FAD8E0022; Sun,  3 Feb 2019 07:16:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF0128E001C; Sun,  3 Feb 2019 07:16:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B04F68E0022; Sun,  3 Feb 2019 07:16:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 464C88E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 07:16:13 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id d6so1842492lfk.1
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 04:16:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bsr2lcuUZ78duCduOrjEIhzTac5FkzmhdngvDyze87g=;
        b=doBeFRPjxPJUFRFW9Sv2DxZZtrDRwfVcQAasiaMB0Cp7obgUlfnXQaccv1qGKqOaA4
         zHvdhamqmVq6YWA/eawOMIwlBxVG6rOBUX9igTnkQMYHPvC018l2kaKCt9BPUAsKwLBH
         CKNy3HDE3BLPEZVmaF3+nGdc3byVAC/Y5gNMxuxo4D3hbNsO9qd5Kh8uwrksJsXxk8P+
         UMe6j9EDqg3UhK0WiZG6OrhDGZpjqGr+q994hbKM7erwWDsNBiFmas0j6TNGDEpwxlEK
         OqsJSSzyHqV44ogC0dy2nvuJ0s065j7N6tmVnWs6IamIDI+WhVGrGzwnqIPi/j/DQuKS
         /1Xg==
X-Gm-Message-State: AHQUAuYGwV3CoqTTJE8zZm7UUzXdik5talN3VhVS5+GRPMzm93vd3ZGJ
	7GSHRb7FYXwDVvedzipD/BjAEtBuUkWtmnUqegxVQP9RciNzbEVDBz2CMZiaGuV1T6yqppuRTwe
	LZfZ/cOcSxCwAQNoudZ64It3TMpuugEiEHwpPp88DisMj8Aaj/CBnARo3JCRMV2NkI5dTuZIaJu
	T/r+M8f7X3NEUcLwIJi2ofFgEh76qUAJ4qBWEotBBRbXQXrFJeRVbs9+GxwZySA6x2LN+B2MNPi
	5kYFrqD1fEGU/jKtRZYfHYjqWnl9X60fJpqzuGbXYTRFMRsCprTo8z2mtSzO8bN6GcIrL6rWMk/
	jQwubwscLjmLEQlwSCUNPydgUrf5+NLDpYokYwlwoKN194c7dCkq0chzAJu9i6/1modQUaTDwbI
	i
X-Received: by 2002:a2e:9ad0:: with SMTP id p16-v6mr12180474ljj.102.1549196172588;
        Sun, 03 Feb 2019 04:16:12 -0800 (PST)
X-Received: by 2002:a2e:9ad0:: with SMTP id p16-v6mr12180437ljj.102.1549196171510;
        Sun, 03 Feb 2019 04:16:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549196171; cv=none;
        d=google.com; s=arc-20160816;
        b=06sV0YgDNbY6PprbcXbsMLq9Au6SaBCqxAWbTtA6Y2t5g6Jv/IS72h4wtxtMB0N6dA
         pVPJP5vs6qIA9zzGSDiM+imzcA3CHt4lKVKiErtNDdtOELGYfyyzROMaPE8vvcRfwJYX
         yPHw1zJhqyCvTvHnQA/8Lzqe3OojWpYkFuzWaXQnPAoyDBZTnCRGzz/+dV0mIM72JGzc
         4W+esqk9++rvuHsqtGhsl9vv7+6zLNJWRp0z9Vg2uDqM2486KI1C91diXG4Cmxx0qwxV
         TRGn+Y2O3cgyeE/j++jv9n+vsTRuSlUkH4XUbXItDOkBloa/FEaXM4ZvLOJvFv24D31t
         NA/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bsr2lcuUZ78duCduOrjEIhzTac5FkzmhdngvDyze87g=;
        b=ZjGpgDPV139Utg1aBmhK3lLSJImihMeXoqZ96VuxAkSd6HOlRT/EPyVoy3U6JJ24uK
         qVQGH6D3wIoDgBuvNCAnyQMiGllpCE7+8Fw81IruF4vuLc01q15zHkr0Bcbh9aSiVtMn
         pkJwM8ppVDebC6CwHPr8JQT5Y4hEMGp33h6n/ykXVKJtcQn2HLZUNAvb1SiGporRj+Ir
         +YQkBqV/ploO8NCnKru8yfZ+IRtoSJRbvyDrAWpx6cSd+pF8goyPlQSuCu00wEJfFdIJ
         MD2uEUfjRCruXkZhGA1sWk+aToa73Hah5R49t3kvjehG/r8q1x54rX4/VAu7MUyCrCm3
         7qWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DEFZB7m2;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s141sor3584782lfe.45.2019.02.03.04.16.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Feb 2019 04:16:11 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DEFZB7m2;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bsr2lcuUZ78duCduOrjEIhzTac5FkzmhdngvDyze87g=;
        b=DEFZB7m2x3lEjsSr4Vebj+gVVt7RLH0LzvwCLxLo87w5byYcx/eb6nkp/k5rPLuF39
         mmpb1Mq5bkecyhhJJlhVeKWccLyDB6pbFTcG0XIJojHQ1bHDN6mtm+KoI8VXXSqh4yl8
         ipfUr4T2tWkt0zjGXzc9GQDjaIzV49m5XBPq5fafnpOPUlJkiK438F1eBMpOp9WOD031
         rS4TLTf9kl1YBlwKdOL4uPVoF0bqQVtg2TbM4tLaPL2XM6xJkhQmwMfCYyZNuUDWKGnu
         yXDuK0R70C2y4wvmF0CXFDycc+8qwbZhCbA6fzZGslHQA2fZUVEj6ZEW4WTc5BAZ/kpz
         u8UQ==
X-Google-Smtp-Source: AHgI3IaQ2Z3KDC+FnOhj++jsrTaCbQdTU8++guI2WhAsqUj3GwbfmgS1POV51VcyVAyZUuz4VlciqPBClODpIE97UkE=
X-Received: by 2002:a19:5004:: with SMTP id e4mr3804044lfb.75.1549196171078;
 Sun, 03 Feb 2019 04:16:11 -0800 (PST)
MIME-Version: 1.0
References: <20190131030900.GA2284@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190131030900.GA2284@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 3 Feb 2019 17:46:02 +0530
Message-ID: <CAFqt6zZCmUTf1Pj+i0eYeQJ1x8A5u+26cM0v00TRpiNYDHky8Q@mail.gmail.com>
Subject: Re: [PATCHv2 2/9] arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Russell,

On Thu, Jan 31, 2019 at 8:34 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Does it looks good ?

> ---
>  arch/arm/mm/dma-mapping.c | 22 ++++++----------------
>  1 file changed, 6 insertions(+), 16 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index f1e2922..915f701 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1575,31 +1575,21 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
>                     void *cpu_addr, dma_addr_t dma_addr, size_t size,
>                     unsigned long attrs)
>  {
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned long usize = vma->vm_end - vma->vm_start;
>         struct page **pages = __iommu_get_pages(cpu_addr, attrs);
>         unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -       unsigned long off = vma->vm_pgoff;
> +       int err;
>
>         if (!pages)
>                 return -ENXIO;
>
> -       if (off >= nr_pages || (usize >> PAGE_SHIFT) > nr_pages - off)
> +       if (vma->vm_pgoff >= nr_pages)
>                 return -ENXIO;
>
> -       pages += off;
> -
> -       do {
> -               int ret = vm_insert_page(vma, uaddr, *pages++);
> -               if (ret) {
> -                       pr_err("Remapping memory failed: %d\n", ret);
> -                       return ret;
> -               }
> -               uaddr += PAGE_SIZE;
> -               usize -= PAGE_SIZE;
> -       } while (usize > 0);
> +       err = vm_insert_range(vma, pages, nr_pages);
> +       if (err)
> +               pr_err("Remapping memory failed: %d\n", err);
>
> -       return 0;
> +       return err;
>  }
>  static int arm_iommu_mmap_attrs(struct device *dev,
>                 struct vm_area_struct *vma, void *cpu_addr,
> --
> 1.9.1
>

