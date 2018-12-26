Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32C6BC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:38:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E66E4218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:38:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EzYAlMUO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E66E4218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6906C8E0005; Wed, 26 Dec 2018 08:38:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 616438E0004; Wed, 26 Dec 2018 08:38:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 493808E0005; Wed, 26 Dec 2018 08:38:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id C89388E0004
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:38:12 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id 18-v6so5256190ljn.8
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:38:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kitNRdDq9qDxhqv/cqY0Zh5BAxoT0axpEmlNVpYcbmE=;
        b=g+FpFLstVfV1oSCGRS69VD/FBXpC1RDVO/VGyWvh6+SD4+ufKpthgM1mK0LUxpqRRH
         gf2NR2Ds0Os9L2mwOBir6/v3pzQAjW70eCy5HRcC3xDUeEdeFXa/tfRnzGWL201J/PiH
         7WquqFVtbRPH/aIXX+n7nnNg//goltUNv/QeZLFGgE5zUz+bKyIT7lj69AHS8SFqv2Wn
         Jwn7GIzZdpZohdCVB0SvAg9Ch7vou9YUAzVqEMjvFZv58LhsCYwUg8FSPMzuDoDwi52h
         7G5Vx42AIjp4fwrvo77KMTe+PNHlY7AO1zoPYvNqONCTHjTmcdfViUNdXqEn4VlgAXOk
         OVYQ==
X-Gm-Message-State: AA+aEWYMv5G0MIIu8RztH6bfHZUxqhLNSkOMgdZrznkVtyw6i2zm2yaK
	Iyg3Z8ftdrYnphs72ISVXpXQ0+g6yfMqMJGflTK+2tCeURZfl1t6BEt5o+03gOpJpkUduoZD0cY
	FmP31eGfVpTrJrcxRRzlhp3/s31YatXPlg/tWshmB83s70B8X1qIgmYVqGK979maBIbxpcX1AP5
	co9E4bucZyQdeOTRP+LdjhBSbfXO+XXGxLF/xpmPtXuuRTWlKYE3Je1ysyPkY9tiVeeMTOl+g8g
	djck6a+3xdAhdqIiKZW13MpBK8pm5ebp5QnyWKUqITgbWeglPYiIKy1RsD+VGjrZ9cMv0Rl7BQE
	QI+CvB6PfABO9gh0efwgCpsAfoSt20VmK+jyoBGgvYpMw8rqLV8ZJlCE7fms/LSG/gb0kT6VTy1
	V
X-Received: by 2002:a19:8fce:: with SMTP id s75mr9608188lfk.151.1545831491806;
        Wed, 26 Dec 2018 05:38:11 -0800 (PST)
X-Received: by 2002:a19:8fce:: with SMTP id s75mr9608167lfk.151.1545831490809;
        Wed, 26 Dec 2018 05:38:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831490; cv=none;
        d=google.com; s=arc-20160816;
        b=i0lJSm9ZAYeQSnCYVkNrOY9ghMaXNH6J6dctmSc8PpLMIuB0g0OU//bJeaAnyFhdw2
         cmK6vwQOqTp3XMsq5gzIoFi0vSWgXDCVYz6toqyKLdNVRIoozeqBGE1JZ6h/xFOBgvf6
         hWCiu7+a2GKCnWp5kvcXSMIEYYs9EEF03iJW+nSDk+1ocGUol6xjvB69J7/16XkQ2DHz
         lKO23cjsj6cIyXi7+XOxOe5OAKjmfYV5zceNPkHSN3guuidj+kt1Czf08ejKt3X+xULR
         o1fDuPnMUIfzTXU/S/xOuVu+Vyxpb2kaj7O3vBqJYjjQ5Li+hklWAnjZXrTfLo5DrQj1
         GdDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kitNRdDq9qDxhqv/cqY0Zh5BAxoT0axpEmlNVpYcbmE=;
        b=W6zsJyqw/SYcdtHVvu7JE/Netxotx1+lbZa9lWYLberezKKWP18JwYq5sBy0SRM72q
         VqKH/TV5o4I8Q6l3tAfsnc/vbM11REh4fgo8stibRmgy/F5ckHXuHVcxv4Svuh1TdgCq
         e39wzmgFOFnDrExkE1ydXMq3v1r5mya+7izX5c4LeO4IeUtqCUaqL3aqR66UnbSLr5hb
         nRnsnKhLmsqTtMRKI6FPslDuQHhSqrxsF9VEPsl71XoD077G5dMO8NBz0YHNMKOi8Opm
         qYndcTLLDrA4aBIWQq3Y0UF0x2PrXnPMvehuJT92PsD8lvVf3huH8+OPQXmTg+jIHKv/
         xEKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EzYAlMUO;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor9508309lfl.63.2018.12.26.05.38.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 05:38:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EzYAlMUO;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kitNRdDq9qDxhqv/cqY0Zh5BAxoT0axpEmlNVpYcbmE=;
        b=EzYAlMUOklMugVTu4yYZGxXNl4hINns0BIBJ5Nyh+SiXyQZO3k1/YmOAXpsklfPAO9
         iDjpstitfhNRBht1mAjbRylNtGX/qD7buZ6ZeNkLPTTkq+7i3RsoxtRKoxTGkPBVjWvU
         ewhbp9fp+SmSCfmGn6nODKNhk6WX3dvwgudwU6EjHkBWxXVyLzXBNAmnZCB6z35uzkPb
         Yuu3uQxriVsO8cyk40d27EsqUa+WVfd4Nl0ZtFjBqXyXizvXzewwA2Kx7e7/1/OvhDt6
         C8HXTXX4cBfndyrt6+ttMQgPjv4dEhaa9oIj2jWENm1ZqGpTtOP7wRhMtO1SGZvml2dn
         imYA==
X-Google-Smtp-Source: AFSGD/XEZnUUKwSUwh3xXDYzi3sA4iQ+mQgXPP42OF+kde+qmR73SafRNdS5zRrl3g5eSHL8MfxiCu4AX/ZyOOBLntQ=
X-Received: by 2002:a19:2906:: with SMTP id p6mr9556966lfp.17.1545831490237;
 Wed, 26 Dec 2018 05:38:10 -0800 (PST)
MIME-Version: 1.0
References: <20181224131841.GA22017@jordon-HP-15-Notebook-PC> <20181224152059.GA26090@n2100.armlinux.org.uk>
In-Reply-To: <20181224152059.GA26090@n2100.armlinux.org.uk>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 26 Dec 2018 19:11:57 +0530
Message-ID:
 <CAFqt6za-vq4GihKbSJjF1_=_xnWvBbpCQDf8iuhF0e8XJY4JVA@mail.gmail.com>
Subject: Re: [PATCH v5 0/9] Use vm_insert_range
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
	Peter Zijlstra <peterz@infradead.org>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, 
	treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, 
	Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, 
	joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, 
	mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>, linux-rockchip@lists.infradead.org, 
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
	xen-devel@lists.xen.org, Linux-MM <linux-mm@kvack.org>, 
	iommu@lists.linux-foundation.org, linux1394-devel@lists.sourceforge.net, 
	linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226134157.crByNvUSh5qkktZaehtdWXg4Wi7WBaCLSCewOnWBjrw@z>

On Mon, Dec 24, 2018 at 8:51 PM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> Having discussed with Matthew offlist, I think we've come to the
> following conclusion - there's a number of drivers that buggily
> ignore vm_pgoff.
>
> So, what I proposed is:
>
> static int __vm_insert_range(struct vm_struct *vma, struct page *pages,
>                              size_t num, unsigned long offset)
> {
>         unsigned long count = vma_pages(vma);
>         unsigned long uaddr = vma->vm_start;
>         int ret;
>
>         /* Fail if the user requested offset is beyond the end of the object */
>         if (offset > num)
>                 return -ENXIO;
>
>         /* Fail if the user requested size exceeds available object size */
>         if (count > num - offset)
>                 return -ENXIO;
>
>         /* Never exceed the number of pages that the user requested */
>         for (i = 0; i < count; i++) {
>                 ret = vm_insert_page(vma, uaddr, pages[offset + i]);
>                 if (ret < 0)
>                         return ret;
>                 uaddr += PAGE_SIZE;
>         }
>
>         return 0;
> }
>
> /*
>  * Maps an object consisting of `num' `pages', catering for the user's
>  * requested vm_pgoff
>  */
> int vm_insert_range(struct vm_struct *vma, struct page *pages, size_t num)
> {
>         return __vm_insert_range(vma, pages, num, vma->vm_pgoff);
> }
>
> /*
>  * Maps a set of pages, always starting at page[0]
>  */
> int vm_insert_range_buggy(struct vm_struct *vma, struct page *pages, size_t num)
> {
>         return __vm_insert_range(vma, pages, num, 0);
> }
>
> With this, drivers such as iommu/dma-iommu.c can be converted thusly:
>
>  int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma+)
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
> }
>
> and drivers such as firewire/core-iso.c:
>
>  int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
>                           struct vm_area_struct *vma)
>  {
> -       unsigned long uaddr;
> -       int i, err;
> -
> -       uaddr = vma->vm_start;
> -       for (i = 0; i < buffer->page_count; i++) {
> -               err = vm_insert_page(vma, uaddr, buffer->pages[i]);
> -               if (err)
> -                       return err;
> -
> -               uaddr += PAGE_SIZE;
> -       }
> -
> -       return 0;
> +       return vm_insert_range_buggy(vma, buffer->pages, buffer->page_count);
> }
>
> and this gives us something to grep for to find these buggy drivers.
>
> Now, this may not look exactly equivalent, but if you look at
> fw_device_op_mmap(), buffer->page_count is basically vma_pages(vma)
> at this point, which means this should be equivalent.
>
> We _could_ then at a later date "fix" these drivers to behave according
> to the normal vm_pgoff offsetting simply by removing the _buggy suffix
> on the function name... and if that causes regressions, it gives us an
> easy way to revert (as long as vm_insert_range_buggy() remains
> available.)
>
> In the case of firewire/core-iso.c, it currently ignores the mmap offset
> entirely, so making the above suggested change would be tantamount to
> causing it to return -ENXIO for any non-zero mmap offset.
>
> IMHO, this approach is way simpler, and easier to get it correct at
> each call site, rather than the current approach which seems to be
> error-prone.

Thanks Russell.
I will drop this patch series and rework on it as suggested.

