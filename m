Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65879C282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 07:01:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 079C520854
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 07:01:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ju/wbRai"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 079C520854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 931268E0004; Tue, 22 Jan 2019 02:01:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B6F08E0001; Tue, 22 Jan 2019 02:01:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75AD68E0004; Tue, 22 Jan 2019 02:01:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 051F98E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:01:03 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id p65-v6so5746956ljb.16
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 23:01:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gELQudhz58q+DJDV372aKur4b52yXBFHqo3p/1/epX0=;
        b=a+aeIiJ7hDccUHqZ4HbzlPFfon9GircIbLjMGVPBhGrE6qMC5HEMAf4DsmliunsMUI
         3BhHkN29vOdAalzr8pBA36ss/5ePLlei7xrpjalvS/qtpblBByQh7sAp8xNF3zOgJlSz
         v3R4IULEP+lxFAroQbTADXysJMeDDJpC6fXnuRsvpOGdzW9XwtyAFcqpXJrwtkZ9qbo8
         qXKK44noJjB8nWV6901pdE9vI1LmryXkPSRLGiffO7SOnHXhjysmffrnZ47euLa6AwRy
         e2pUm5gtY9XbtR2qRIfiYiTfH/+cy7oPDRclesjpNoBK1mBdJefoNb11VLAkVfYUsouE
         D+Pg==
X-Gm-Message-State: AJcUukf94zW/OpEr5xj3xQNm/61AwYUiEm4vPM3x3rX3s72nUtAszJPN
	LOPnYrWO40rQhHMdACYnEo2t4jjJeHrCdi5Fo4RePxHAiRZxtiojVgWMLcVb5fCh0FeTZTWZLvt
	9PwmFzrEnj4t1elABj0py7muq36VQj22VSXwUWmUadhdJgRoSVh6OAwwZDr+eY5WGXUpwxUTa2c
	VAeU2dzCK/SskOyHl4Zu7bfIj56vT2a3BaKkTM9+ZXw/bDc3AcRW9ApzCviIQwybF+JaAEnX+VB
	pmFeLeRPI1VU0wBYCbvg1C3wOcgUUVQmzw8nMRuSBt4tkebimPiVMwyPyzgJOBs94hNG/FhoW8f
	Ucrc+cDRgMs6VcmkKjV/9em8nT/1zQo70bdN/6gQ9gtMTtKL+s5z6Hn0S5URCaLDmhOpHbcO96b
	N
X-Received: by 2002:a2e:6f11:: with SMTP id k17-v6mr19215489ljc.94.1548140461960;
        Mon, 21 Jan 2019 23:01:01 -0800 (PST)
X-Received: by 2002:a2e:6f11:: with SMTP id k17-v6mr19215407ljc.94.1548140460283;
        Mon, 21 Jan 2019 23:01:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548140460; cv=none;
        d=google.com; s=arc-20160816;
        b=Fy/x5t0r6IAXCtQSfCXPZKK67jT2+kqwKc1CVVGqex98hBdVJ9xRBSYHLxtLPd6Wmt
         loKhpJJxvqVB6bK62BhD3kDR3iYjN7TZVlK8Bz8r4znWnQ2Q/NELKeALBdJnJPodJcO+
         YMObdeJ81o0t64IjwzlRZ53IT1YAIiUqBJCc1xX0GDYZPLABMRDdzZAVdhUPmCJE64Ud
         w++mZYFbmI+luK8ivCz3s87ARS1w0imiHQV+pshhv0hjt39Dsm2J8Atq+rMSuX36fG6J
         xY4mJ2xcoM9W1CjXrvkY67BrZGuln4zkFNFb24EXI17Ouja0Cp2n2OoyC/uesjgdw5zp
         wGDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gELQudhz58q+DJDV372aKur4b52yXBFHqo3p/1/epX0=;
        b=S5WZYz3X7Gn45M3HajBoalT7XFecrZYWzY8IYABCVx5bP6PoXc9lwEiuUJWqMJnpMv
         6yYKdhCKL1RXwU/Ytdr5fq83/d6YMx3YjEi6UQvO4d5AKoSm9OjqWiNFPEsM36K5XGt5
         yW9rAHPU/Dk7NIbr12Qm/rIqh5viD+EhS7zP69C02AoB4qZubP8KBsSHyY8E0yGzX3Jq
         pYzVxWQO4FfsErXeCrjOce6NIhpPMeSj1dEFdOPzxOlNqrlo7LtVn/T2omko900Z+uCY
         19kj3KZX1+KLsuYqifDMvS48hTsYcmwxUmv5ksrnJys61xV6VQZ6EU3gQHcZ25lZmQ97
         ufUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ju/wbRai";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k189sor3813636lfk.58.2019.01.21.23.01.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 23:01:00 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ju/wbRai";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gELQudhz58q+DJDV372aKur4b52yXBFHqo3p/1/epX0=;
        b=ju/wbRaiQK+PGoIe980i73IkWyZOcGgLds1X6yS8+dyW2hPJ8EeY/cV9ZcT22L8d8B
         +nSeIHrfxHIMTQ0bV2q8Hzpa/44AF5RnMNUpz0UbbE+rS0sQiwaPg2yjDJcmQJ0rzUuA
         /+F47UbAsvMdhm5VySdUBQ7qVjsOHKgTIY/89sokdQvZx35D3lDoU5w4NLGiNPi8VyM6
         ePJ6XrppTBsHJ3Tzh5yibTUv8khy7WXIrAI0Rs2IIzr9uu/LUs3oOSdlA190uU6y1KpI
         Tp0jmkzDO1o4Cm3DFtXcZxiclWU96S0Lbgu4Bk0jlh51yl85gNEbbk5IxMve+rn2btyE
         vmaA==
X-Google-Smtp-Source: ALg8bN5gT5OYIsNf6kzYRoKkBJpu3w73otKRaRsQX3tTXfLn+Hvz7kpoUCVQ3KKhPY1rbMQ/DQw1jB+C/ru5U9faLaI=
X-Received: by 2002:a19:6514:: with SMTP id z20mr18984719lfb.31.1548140459614;
 Mon, 21 Jan 2019 23:00:59 -0800 (PST)
MIME-Version: 1.0
References: <20190111150712.GA2696@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111150712.GA2696@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 22 Jan 2019 12:30:47 +0530
Message-ID:
 <CAFqt6zYOpbwc8518f27W8_YOkuprdJJLyJg1fFB==wrFZLdEYQ@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
	Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, 
	Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, 
	joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, 
	mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, 
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, 
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, 
	linux-media@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190122070047.ncxmS2JrDXgOL5FOAGRdw4FQBYL64V1nD1c-_EopJFI@z>

On Fri, Jan 11, 2019 at 8:33 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Previouly drivers have their own way of mapping range of
> kernel pages/memory into user vma and this was done by
> invoking vm_insert_page() within a loop.
>
> As this pattern is common across different drivers, it can
> be generalized by creating new functions and use it across
> the drivers.
>
> vm_insert_range() is the API which could be used to mapped
> kernel memory/pages in drivers which has considered vm_pgoff
>
> vm_insert_range_buggy() is the API which could be used to map
> range of kernel memory/pages in drivers which has not considered
> vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
>
> We _could_ then at a later "fix" these drivers which are using
> vm_insert_range_buggy() to behave according to the normal vm_pgoff
> offsetting simply by removing the _buggy suffix on the function
> name and if that causes regressions, it gives us an easy way to revert.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Suggested-by: Russell King <linux@armlinux.org.uk>
> Suggested-by: Matthew Wilcox <willy@infradead.org>

Any comment on these APIs ?

> ---
>  include/linux/mm.h |  4 +++
>  mm/memory.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/nommu.c         | 14 ++++++++++
>  3 files changed, 99 insertions(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de9..9d1dff6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2514,6 +2514,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
>  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>                         unsigned long pfn, unsigned long size, pgprot_t);
>  int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num);
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num);
>  vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>                         unsigned long pfn);
>  vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> diff --git a/mm/memory.c b/mm/memory.c
> index 4ad2d29..00e66df 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1520,6 +1520,87 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_page);
>
> +/**
> + * __vm_insert_range - insert range of kernel pages into user vma
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + * @offset: user's requested vm_pgoff
> + *
> + * This allows drivers to insert range of kernel pages they've allocated
> + * into a user vma.
> + *
> + * If we fail to insert any page into the vma, the function will return
> + * immediately leaving any previously inserted pages present.  Callers
> + * from the mmap handler may immediately return the error as their caller
> + * will destroy the vma, removing any successfully inserted pages. Other
> + * callers should make their own arrangements for calling unmap_region().
> + *
> + * Context: Process context.
> + * Return: 0 on success and error code otherwise.
> + */
> +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num, unsigned long offset)
> +{
> +       unsigned long count = vma_pages(vma);
> +       unsigned long uaddr = vma->vm_start;
> +       int ret, i;
> +
> +       /* Fail if the user requested offset is beyond the end of the object */
> +       if (offset > num)
> +               return -ENXIO;
> +
> +       /* Fail if the user requested size exceeds available object size */
> +       if (count > num - offset)
> +               return -ENXIO;
> +
> +       for (i = 0; i < count; i++) {
> +               ret = vm_insert_page(vma, uaddr, pages[offset + i]);
> +               if (ret < 0)
> +                       return ret;
> +               uaddr += PAGE_SIZE;
> +       }
> +
> +       return 0;
> +}
> +
> +/**
> + * vm_insert_range - insert range of kernel pages starts with non zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Maps an object consisting of `num' `pages', catering for the user's
> + * requested vm_pgoff
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> +{
> +       return __vm_insert_range(vma, pages, num, vma->vm_pgoff);
> +}
> +EXPORT_SYMBOL(vm_insert_range);
> +
> +/**
> + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Maps a set of pages, always starting at page[0]
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> +{
> +       return __vm_insert_range(vma, pages, num, 0);
> +}
> +EXPORT_SYMBOL(vm_insert_range_buggy);
> +
>  static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>                         pfn_t pfn, pgprot_t prot, bool mkwrite)
>  {
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 749276b..21d101e 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -473,6 +473,20 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_page);
>
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                       unsigned long num)
> +{
> +       return -EINVAL;
> +}
> +EXPORT_SYMBOL(vm_insert_range);
> +
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> +{
> +       return -EINVAL;
> +}
> +EXPORT_SYMBOL(vm_insert_range_buggy);
> +
>  /*
>   *  sys_brk() for the most part doesn't need the global kernel
>   *  lock, except when an application is doing something nasty
> --
> 1.9.1
>

