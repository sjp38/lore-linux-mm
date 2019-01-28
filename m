Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A079C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 06:31:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51B3F20882
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 06:31:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SrkEZvke"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51B3F20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D165D8E0003; Mon, 28 Jan 2019 01:31:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9FBA8E0001; Mon, 28 Jan 2019 01:31:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B68148E0003; Mon, 28 Jan 2019 01:31:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 403288E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 01:31:56 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v24-v6so4502792ljj.10
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 22:31:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Xo1XRWo+UsOWJB0j8DeP+bJpW8d+zCzkO/oslyAm+ZY=;
        b=lsb67fqTu/jPaqB8ohXHqS92Lo3htoSB/g9eVuL8jSL/ZaABJLNdAlEyPzgN4XaA96
         xvIdXSwM44nqWy/uKbd9JhKyP8+cv5xAkS82jBfTIJYR6HzZQFZavf22q5iKPg3e/WRY
         uq6c9e2eheHCeJDE2Lm5b84SKG705oWb/2BnUFoVu2+7pwVltAhL7gPtGL6cY9wwdka7
         BBnhOMRSaxcVFHiLdNpmsLetUV9dJIM1ocHvrWd60oy2vsKOCQi832hmPBnHpHHFSDNM
         +b8QiYG86PHVyZhEHoDQ62O3f1i/jSeo4hpQG4KaoxKwB8I8uu7EmErUUy+W9m/kSlPJ
         Pgww==
X-Gm-Message-State: AJcUukfeVJ3hoWK/VdzMKkseGbcrP1T3I3ASJPxKrxZB9eTWUvH8J+uH
	E4WbuXWL400N+SsSPUEtN0sytC7zIdHcyCK8L+juI+ZLwaCbtT6TzznVHOk99/+jM5ckcFkNc4c
	10juHX4J5urnPotAm+H6+DqkABsffrTXBA0VQczWmoq3mvbs7wJlDeXSPMEcHgw2XOD4VWyAHvg
	OTRfBzL8r7dzK44igNp5ADcF2DplxBWb9mqi1KlGW9ZpYZ+T1m6Bw/DIHmeskBQWBu+5QYxjy/l
	zXxb7B3yD88Zvq9Oqsp6o+jfkJvr9IIxYBH5pBupuaYno3gCl1abbxNEeRn9YHK1U8c599BIfFH
	fcyid3DO/4xVXSerq8gOTSgLe0by3iVoz69KCyw3zRP1kibUlJ1tLRQ3YrAzs60r0KCMG4SEZwn
	A
X-Received: by 2002:a19:7018:: with SMTP id h24mr15207113lfc.162.1548657115269;
        Sun, 27 Jan 2019 22:31:55 -0800 (PST)
X-Received: by 2002:a19:7018:: with SMTP id h24mr15207076lfc.162.1548657114245;
        Sun, 27 Jan 2019 22:31:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548657114; cv=none;
        d=google.com; s=arc-20160816;
        b=jbRTOJJrD0TTx/7UtPWGTnR+40kK1rFGE7CwTT96hbOKDrDzcdvGB1ZXWtndNHyYyS
         afwuPpIAJfRsKhbvsqUAcNbHjSUpAf4AkPXq0htjkgbwPXr3gIrDL6L9saPskcpz1UZ3
         jrECvelpF5bMHxZV+10uZWDJILj8tyqSeKhLn3XAYiBWZFsyXn/MM12Xz1f9zPHBvdo/
         5zSvOkOqwbEAOjaTu6mQcSN1jFqD62missCAu9kQ9D5AQINDcJKGWUKTJI2Vx2gZNJX0
         HSpJLZRhj8/cz9/QCbipFkRYhAvDFOpVwzpe21tLA3aawVvP7sXAbt4FiYITcD+VmL4w
         261A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Xo1XRWo+UsOWJB0j8DeP+bJpW8d+zCzkO/oslyAm+ZY=;
        b=LZoFRKYcxuIGYIvR3aIShO4Ajbsy4jQGoaaKIaaGEPolP9PCOt/rjc3mUwOA+fDrWP
         mKWvyKAy5gVZZMTe9j5a1vTEBYk320+jUBWV+WDUaYN3/2XWVlAOMndFsV2k9RNS7BQe
         L5bYTo4KM51ESoRFgSjZvep69oxKA0CYbeTDUvFMTs8WbxBibsg0QVI5nbvtnxrTg782
         Zp8Wpjvu2HYf3nVqZm2KJXUOSgE9HIhVQpFFlRD/Xjr33RWZtNisa/RR/jq852EEazIO
         ViRBMLxtveyIip7sBaec3WbzTRXKbwJgJHn0J9j/byhdZUI/fun2LR0vucS1Fztkeus3
         cQQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SrkEZvke;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor7911090ljj.2.2019.01.27.22.31.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 27 Jan 2019 22:31:54 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SrkEZvke;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Xo1XRWo+UsOWJB0j8DeP+bJpW8d+zCzkO/oslyAm+ZY=;
        b=SrkEZvkewK8wCGCd4tU8le3LqMBD4FgqPce3jh4E0ohaqyKSaIfEK/T5MsQOsvOG0O
         VUtaLhraTkB6Od+YDPTqiH42Wp4M/w3QE51Rm7pYkn8HUzajXjGk9IOY8oGo7nUnqp1z
         ySB4RLtrTZByVloU5g9dGD/tLdVrksFbZKMYIkEII/XeruQrgsVAlXp/PXsxUC+TV+tA
         PyQGdNzEBr7b3vmqZu3B0hVsLpi9WoapymNWZXcdUIbMO18OmpqSs5kddu6kb+hRLJvD
         vz4Lui3WBETrIqEuQvkPe/deSUL4doBbTdWHuwAxyD4+tfL+NumMNwKyFzWTQDfenQaM
         mraQ==
X-Google-Smtp-Source: ALg8bN7TnNqZso0t9ffTuek7639g3w1wEhMAxY4Zlyx88OaxeFSK82GVVYlDyXhzq513Dmj5SeO5IHfNEBVREoEcoCw=
X-Received: by 2002:a05:651c:14e:: with SMTP id c14mr16469993ljd.20.1548657113701;
 Sun, 27 Jan 2019 22:31:53 -0800 (PST)
MIME-Version: 1.0
References: <20190111151110.GA2798@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111151110.GA2798@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 28 Jan 2019 12:01:42 +0530
Message-ID:
 <CAFqt6zYhudeTdj02Ex6jaLYoUQ-2YhmwTvJ6+nHRcAJN7NZ99w@mail.gmail.com>
Subject: Re: [PATCH 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
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
Message-ID: <20190128063142.AP0eboN6mDQpKffauO0cibb688Rjb3OZEbKBejdwFH0@z>

On Fri, Jan 11, 2019 at 8:37 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Any comment on this patch ?
> ---
>  drivers/iommu/dma-iommu.c | 12 +-----------
>  1 file changed, 1 insertion(+), 11 deletions(-)
>
> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> index d1b0475..802de67 100644
> --- a/drivers/iommu/dma-iommu.c
> +++ b/drivers/iommu/dma-iommu.c
> @@ -622,17 +622,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
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

