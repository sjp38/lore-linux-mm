Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45391C282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 06:24:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1EDA2133D
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 06:24:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ef1pDDYS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1EDA2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72D678E00C0; Fri, 25 Jan 2019 01:24:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D9E48E00BD; Fri, 25 Jan 2019 01:24:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A6088E00C0; Fri, 25 Jan 2019 01:24:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBC0A8E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 01:24:27 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id 2-v6so2383936ljs.15
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 22:24:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=w9H0PZn0OolgP7kJc7bV76uoKOIASZFoEKdhk7G9bBk=;
        b=sWzOdFpgJnff/x7ceNI8vaT61maLjl9+mduZcf0rJkI1MclpuDrcDBhCZYOmEvKAco
         j707EmMjDkeASz1u9GpgWGWtFfQ71wC+f/AC8kc9g8g4QIUA+TmgNgqIdaznvPfMpJ1N
         2HhpiMGaZweDm45XpYwS83ZfZ+zn+5WmDOUKxzMCUEygB1wnYDmcx+y3NmxKXAHWqnvD
         MTZujpHOwJanvgULn41YySWJpXqNZFxdQEJFUyqW4rld5k2ZI1QDgcJ/oJUAIVXY59vL
         4KHihCuiteHMyQWtEnxgTGKK8vW9FR46Kai2KQKhK+41ZNtBX6ER9qo68cplndXUG1gu
         AECg==
X-Gm-Message-State: AJcUukdYHtaRM11IHDojctHWiQXK13MwxAb3ozgthczUAR0fVHkwektf
	1+tcW1X9rr/LzKrXUF/zKwGD5R67HC89Mwj7Ry0dqPRPHpiTVcN69Xsj7lk0jsnMOAeF9x4y5QB
	YEYG1ijYp0KzwRqRxUVdMpF8K7+Wb++nULZOzPc0WfpLcfaZ9We8aTxg5qVXzRDuyzVc32y1e7Q
	s4ZFUZGfjnkcF1nrnVElgdI9D/iix48n43j1Va/3skK2O6IalHRgdXOR3OHJxn617KCOtLvktkA
	x89mJfrHxi20e7Rz3vof3CzVxLV7iTW6HB6z0QkNb0JedbEdZ868mUkXIEuueNI6ttOIiRhd5f/
	IBr2pMT8UKJiFU+8g85PeYGXubzVZTZLdPbwa+Gt8sGaAPmi4ojWwiUaBBr9Wboo0kbtVrp2u2+
	q
X-Received: by 2002:a2e:9107:: with SMTP id m7-v6mr8082650ljg.23.1548397466963;
        Thu, 24 Jan 2019 22:24:26 -0800 (PST)
X-Received: by 2002:a2e:9107:: with SMTP id m7-v6mr8082607ljg.23.1548397465849;
        Thu, 24 Jan 2019 22:24:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548397465; cv=none;
        d=google.com; s=arc-20160816;
        b=XLehqnEW4h/lfzgkvSKvxoFM11ttCfAlRYovu8G98dk52nhvNzaGwYIDys4jIFKHQl
         OLDNz0AFDyi2JIlk0xHB4aVRyuJMcg6/gFLhkkQCWw34qohUgKIz4tG7qYJLknOBSWgp
         4VhkLXlMKCkuH/JkphZntpg58e+6c0Cx13Q8/LU2fvLstSZIUi9HmYxcvVBEhdFi4o2k
         M3DebzxSUYnEkCMHPSkmOsgBdQ0knBGN4xU2rYYH/RMB4oMzE4XlcKBxxM64I2Ha+hn2
         ALqgHVu8btkodQPv6iJFpftGehymXKGmreV3eRhxgNXFw7/YMYQ4N5uawJyu6lZHjTOy
         IlFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=w9H0PZn0OolgP7kJc7bV76uoKOIASZFoEKdhk7G9bBk=;
        b=OdvpdEPPvhj6fWWcDWH/U84GZPaWtWSAo+6EN/KkTx2D3Gn46XE1IJM801nX5zOPSK
         7F2PLacrbyGts2WQ3Qu10riRxJAluh7Sp/GjTB/lhQt5w23ROGapN1WIDBMNr+nUJGWj
         ay4YpAT4kQqfPob5LDkhvPILAlTC0qCWZFNGmwVqK+muKLyp7e1KbHvXulhTiYTRe/I6
         w3+qx3ERW0OcWdxkuDzoR6L6AIBBgAT3RkkncJkUAyi8FHbnlsix95NZRkk2/NOvuWEA
         +lucZO+ifNZh8MlRd9Df/VeWZo7bE9eAtqY+Hr0sCcKXcbvKoWcZsBSw57LqkA9nwE7Z
         Jq9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ef1pDDYS;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k189sor2643934lfk.58.2019.01.24.22.24.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 22:24:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ef1pDDYS;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=w9H0PZn0OolgP7kJc7bV76uoKOIASZFoEKdhk7G9bBk=;
        b=ef1pDDYSKyrj1erjXfMRwQ4zhAIgmRtb1F9M5tlxxKSVhLW29fgSSAg0cvRjSAt4eq
         ISzDFaYnevqUWJ44Fqp1geuq6YHoKJEiTJFxHeE3UGJ/uRMuP61YgOChbdvFwfRx90z0
         J8mi/RFim70I55KL0tiFI0q657AfRlZfx/ERMWp7ZUlh6DsUY7sKpCN7nImUaWUFmoUB
         aM7mPzJd2AEujN1ivrlfZIwEjFW1vo2BOjqaV6IMV/1rX44n4z7w91vWS6NSaAzwEX54
         X4WDAk+bXaeuyS6aU58BfbGzRmA/d+cChU0BZQEXqGGuqX6Z1y/q8Zg+tlnvgOExryY1
         7yqQ==
X-Google-Smtp-Source: ALg8bN4/c2BufFVRM0EfReatatcnmTcHehlYAGb5rddAFsXXWUnAVKBofZHpJCmih2EhMvrwnV0BKWGHlw6p0Seg/Zw=
X-Received: by 2002:a19:7111:: with SMTP id m17mr7456686lfc.64.1548397465269;
 Thu, 24 Jan 2019 22:24:25 -0800 (PST)
MIME-Version: 1.0
References: <20190111150801.GA2714@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111150801.GA2714@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 25 Jan 2019 11:54:13 +0530
Message-ID:
 <CAFqt6zZx9qxx_Xv=n-PY45OvS7E8ZBq+ZqaeEKfsaCirwaASSg@mail.gmail.com>
Subject: Re: [PATCH 2/9] arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
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
Message-ID: <20190125062413.y0k58KPNeON0qEPnXRF1fnc2ONLQQdRSVl9OsqVRDc0@z>

On Fri, Jan 11, 2019 at 8:33 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Any comment on this patch ?

> ---
>  arch/arm/mm/dma-mapping.c | 22 ++++++----------------
>  1 file changed, 6 insertions(+), 16 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 78de138..5334391 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1582,31 +1582,21 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
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

