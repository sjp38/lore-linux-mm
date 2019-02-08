Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74ED1C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:22:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DDEA20863
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:22:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ug4sduE1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DDEA20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78298E0078; Fri,  8 Feb 2019 00:22:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B26F58E0002; Fri,  8 Feb 2019 00:22:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A16848E0078; Fri,  8 Feb 2019 00:22:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 307D38E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 00:22:32 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id 18-v6so616828ljn.8
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 21:22:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oQ4Ilbn2E5O3fse3aFqgWsQmQAFvePOUeZWey4DXpkM=;
        b=DlrfpA/nBXSf9HaiM3RtdV3V41kgrBoW8WixwFqWAeJhqYSq38JZn/PipdCoEc2iny
         KdVl+G2Qef/OJXDHzoK5NpVXttKuKNX1rkp/JpfNNaHBJcjgqVxxucoN5v26MGorkgO0
         tFiO2D2kiEzy19zvb9R4bRUFZfNyj0T2UWyOW2xEPPP8esMd4tOxoUKwC84wT/FHwjLS
         EgvrLCR/yizo0xIjn+skrpfUaacqh8soFK1ERltMNbcdzDlBo3AjUNwmXA2k4smH+r5p
         rTHGMDdqn3mEMVKBDOZbnDcsX/f05e2Yabpe0BFu8ApUcvGVruqfzMb3Vd6XWZjO+Kso
         X1jg==
X-Gm-Message-State: AHQUAuYPFUprOV4ru9K1AFje9FR3S7Tag5VUXPY9jUAnoAzwO+ppwqy9
	bB+gjItvTDRayPAulZnz0NWZVCQ5l9cgwL/UIu4jckZl92Z7Z4FgZka4Dnkxt3XWCe483SmjvBN
	dbPDNrs5W6t1HXCP2onDcmVFcO/OT9YtyfHgConmN04P3vvp6+CVnqoqIjN59e0wLA0gKNZCIP7
	OgW104zonEvyPrYblDDXvC00CjDOeKv8Sbnw2eSN5uHTAj+xwsLrc45wQoLetbixPKDw5jgCkFt
	JgwE/bDW9iJILCf08wWij10YkyFx/R7fDUxgqdznwziffKNoxHah43z+nAWKbKLXIeC4yHMzv2M
	oh6z4DGLXpWoJ2sDsPEpv2WtOU6iDPL4JBnwpgQFzlvumMBBmCnU3lPf5N0d4Uq7vl2mGyk8R/7
	Q
X-Received: by 2002:a19:1f54:: with SMTP id f81mr12637835lff.153.1549603351337;
        Thu, 07 Feb 2019 21:22:31 -0800 (PST)
X-Received: by 2002:a19:1f54:: with SMTP id f81mr12637793lff.153.1549603350187;
        Thu, 07 Feb 2019 21:22:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549603350; cv=none;
        d=google.com; s=arc-20160816;
        b=k6S2r7QfGn7GZSfjfVynpnt9cI5jeNp0i9HsvEmg2iR1y/p/8Xu7u1KACkPZG9asc2
         ESPRfazM/91c1O+gMd22/I/lcahx72oCa7G30Ft2cXeG9SNTOLwLKaCq3ZH/R3/3mJNt
         w6hBE3Ne+Zj8aKK+73PUHxgVUoWyIdkdM35O/RIhZaTkJWz2fv3LKdS/0NevJ2uIzXUu
         p6a2VYM60EbR2x5M7pJkSR9hlBC578qkXboxcvqipaiI2SicpVQa3MC0socihtdUbpJj
         20lDL78mQI6SWZieGipDjbLBgUuF7DyFNswTGI0ZVmW/XZMA9XAzpUlFnY87KZ5XokQH
         oAQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oQ4Ilbn2E5O3fse3aFqgWsQmQAFvePOUeZWey4DXpkM=;
        b=iMLJ7JlQwSeFEILKyISnC/Vx48pLiwmvB5riI3YC4ay//Glte3F6GTCRmsqbC5x/5a
         lTfQbIXJEg6WPu2hJxWbdVYNdui5ecqJI3YzjSylmN56XKuPu7cu75yV+niEfld+5T1M
         +rpA2e9Sdq+tZeaY6BT/P/HVePsHLMDRuHC7Vh+iHlbf72hsPmgsyqHTfwNkzYW95Hp0
         RytcEQyrXFlvbvpOePvN5pacEdzJd7KdwlmPPTpDCks2CYXN195pX6GN5REOR24q/Dbd
         KP2xacm49V1i/7kt5V7VnHXb9zTtb3m/4arXgnXOwahcI2Z8uSJO+4WaF9BFB6wZ6wzN
         Wfqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ug4sduE1;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a27sor241670lfl.7.2019.02.07.21.22.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 21:22:30 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ug4sduE1;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oQ4Ilbn2E5O3fse3aFqgWsQmQAFvePOUeZWey4DXpkM=;
        b=ug4sduE1Nnl6Ucdd6kGSolkdKH1uWHus2x+U5KYf2iN2rOsM9HLP3WTOmtwRbzp/vU
         WmI7jBaiRmhbQxbwHIe1HKiSj7rT5Pv4oHUINwtri7G7ilhTP4D78Yq6vvJJUSwIrTRk
         2ZUDMC1PaOffK1wF+qWJhW3jgyxtid/rRRhQV+FwutdaTY+tC2WlM9hOb7ujI5dOg5DP
         EU9fmyUvSJJZv2KkRSduA90NhevjuS8YMcH4NWCpzE+PGCGGZkX1L5MalVS4z+wPl2v1
         T8K0xfLoY4zbiJwnBzc2QcYZ5ejUJufl/jXJiF3yK/Xx/zcNB2iHuxOECHTIDbBUCpMu
         3Lug==
X-Google-Smtp-Source: AHgI3IYz0SkMlWyxEeQhmXaahAF/5quTQnuzAn7bE9wiMnoPq679b6hVT3lDwP3on5fiZwP5X0S2WjPjR8kO/5pnmkU=
X-Received: by 2002:ac2:5496:: with SMTP id t22mr1036162lfk.31.1549603349625;
 Thu, 07 Feb 2019 21:22:29 -0800 (PST)
MIME-Version: 1.0
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
 <20190131083842.GE28876@rapoport-lnx> <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
 <20190207164739.GX21860@bombadil.infradead.org>
In-Reply-To: <20190207164739.GX21860@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 8 Feb 2019 10:52:16 +0530
Message-ID: <CAFqt6zawBP5Yyy7nfoKz_6ugw8e4MVopvBaeKvaKoXcS-_oSNg@mail.gmail.com>
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
To: Matthew Wilcox <willy@infradead.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
	Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, 
	Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, 
	joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, 
	mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, 
	linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, 
	linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, 
	iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 7, 2019 at 10:17 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Feb 07, 2019 at 09:19:47PM +0530, Souptick Joarder wrote:
> > Just thought to take opinion for documentation before placing it in v3.
> > Does it looks fine ?
> >
> > +/**
> > + * __vm_insert_range - insert range of kernel pages into user vma
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + * @offset: user's requested vm_pgoff
> > + *
> > + * This allow drivers to insert range of kernel pages into a user vma.
> > + *
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > +                               unsigned long num, unsigned long offset)
>
> For static functions, I prefer to leave off the second '*', ie make it
> formatted like a docbook comment, but not be processed like a docbook
> comment.  That avoids cluttering the html with descriptions of internal
> functions that people can't actually call.
>
> > +/**
> > + * vm_insert_range - insert range of kernel pages starts with non zero offset
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + *
> > + * Maps an object consisting of `num' `pages', catering for the user's
>
> Rather than using `num', you should use @num.
>
> > + * requested vm_pgoff
> > + *
> > + * If we fail to insert any page into the vma, the function will return
> > + * immediately leaving any previously inserted pages present.  Callers
> > + * from the mmap handler may immediately return the error as their caller
> > + * will destroy the vma, removing any successfully inserted pages. Other
> > + * callers should make their own arrangements for calling unmap_region().
> > + *
> > + * Context: Process context. Called by mmap handlers.
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > +                               unsigned long num)
> >
> >
> > +/**
> > + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + *
> > + * Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to
>
> But vm_pgoff isn't a parameter, so it's misleading to format it as such.
>
> > + * 0. This function is intended for the drivers that did not consider
> > + * @vm_pgoff.
> > + *
> > + * Context: Process context. Called by mmap handlers.
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > +                               unsigned long num)
>
> I don't think we should call it 'buggy'.  'zero' would make more sense
> as a suffix.

suffix can be *zero or zero_offset* whichever suits better.

>
> Given how this interface has evolved, I'm no longer sure than
> 'vm_insert_range' makes sense as the name for it.  Is it perhaps
> 'vm_map_object' or 'vm_map_pages'?
>

I prefer vm_map_pages. Considering it, both the interface name can be changed
to *vm_insert_range -> vm_map_pages* and *vm_insert_range_buggy ->
vm_map_pages_{zero/zero_offset}.

As this is only change in interface name and rest of code remain same
shall I post it in v3 ( with additional change log mentioned about interface
name changed) ?

or,

It will be a new patch series ( with carry forward all the Reviewed-by
/ Tested-by on
vm_insert_range/ vm_insert_range_buggy ) ?

