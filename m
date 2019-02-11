Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C4C1C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:02:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA8162075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:02:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Dycem5Iy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA8162075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6640A8E0102; Mon, 11 Feb 2019 12:02:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EB5A8E00F6; Mon, 11 Feb 2019 12:02:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D9F68E0102; Mon, 11 Feb 2019 12:02:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2EF58E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:02:08 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id p9so468195ljb.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:02:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UhMN5gACQr1+W4A8Ag5wPDh62RaNjK/ZgHm434PrC78=;
        b=SkcDQaWfASSpmU6u2RkjqpWwjLn4bSBOJQvguL+sxcxepKt4dlXgcB/QqpswnUQM8l
         CFJI6WtdYtSYybLhRfF0BP6eEjV6viAzWaHQSlaWOjSmjBQrTIwaDKKq+iXLjOFNkX9+
         gwYa5CypIJdX5QbOCMiVDG59GH91NyVjgIzXhggmY5MNff9TX6XbWmS/yP7x/0abqlCG
         eHroRMckZsZY9aX5B64kzYEtH17Y5e/kJbbWCZdInfx0dAPumAVMHALPowI9iceh08Ec
         qFlY4S5lHQz3HPItl7LIiRfGGTUGwIyN6b+DQGA/TTxn/zrDUo25UrcNKfAwcr0eKeYc
         13Xw==
X-Gm-Message-State: AHQUAuYENXjiWpG20+h1VBPYxKGY3HyAA8Ok+jD/WEOb/EvUVtcgcuWW
	Ha8mFNgKAT596syAVOpoy0FeTihFG6pEyUwbJnptshl5cpm4ZgAUsVb0KSuRo/hO98uFGhNcJwd
	1xo078HWrqLpZAaqSvOVArWrhwJSqCcs6JRQucNanQ26ytu/U3pCD/OdaBopFqgCEqNZCP3+O+8
	g6Fow+aT6b4gjcIuzG2N+kFdPtlnisC2OxqupY9oh6jK8Xacd889nN7Y8ANC8tYA9Wk1fObjDFg
	dmQA99+gL6yWXAPJgcvAE63Ubn4FGUNOtENz5qY5CMtiMnybJ2Hhypqnl1rbxLjemb2Jl1bzSDu
	xw/qIOlHwo5uZehR0GtQRJNkqTccd0GkbApVHpba9+UwMU2O12w1p/vze1p0FmSlOPsOlu8kck1
	o
X-Received: by 2002:a2e:3319:: with SMTP id d25-v6mr12722862ljc.187.1549904528096;
        Mon, 11 Feb 2019 09:02:08 -0800 (PST)
X-Received: by 2002:a2e:3319:: with SMTP id d25-v6mr12722808ljc.187.1549904526866;
        Mon, 11 Feb 2019 09:02:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549904526; cv=none;
        d=google.com; s=arc-20160816;
        b=Ws2FOxNzaXCpT8YZU2gcWWq4uAfXFLJBWrKSDah40XqthFacFbCC8v7V1bbK4oldXF
         /0T0g9hE51VC26bdzzLPnOPi8figKCgnTOn/J2i+lOkuGsOIgTlKM9mBUG1hrjVI+uW6
         HfeFt5+W7B4DALOLh+gASbGk5gciYtPb9MoJi/WOWlzpjBsSY+B9ghISCuIGBV5kbal7
         oMsCnKA5OwNMu7LbfXjTy8SPvcb0ZIKFDB/OONCSv6H+L5QZ0rybln6Mu3PoyPMcAzZI
         GJd4bgJQjlsaxWystqT6q79+Wa2r6gDqMlvtk/0trwp0VPJYSzPLgQZB02343WeaCSmx
         POWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UhMN5gACQr1+W4A8Ag5wPDh62RaNjK/ZgHm434PrC78=;
        b=etZcRDOyeyv4DX6LKCe/qz1z61NL2+3iE6C1YdRMn2YjpVTmJ2dwlDZHiYQ4IBK/+k
         uKcU0Uo9NcWLTEXoP+fkQl+jD2z0zJ72lSC29CGnY+3S0A2GZl5qCs2Ds2Je5Pj7ElyV
         3Q3mU7g4sg+JDWsX9PQLHWYEYnrguEOd60rDdcDVZ46+pNKmT8hWXiTHFdDA/mmvGrbV
         RfVT4sQok0o0ilK044MdUhy9XqoifxP5pJYrn6sh5ozeknLFMWJKe6IN4rOIME1/b4kV
         nsdtavwdz6w63evFElV1Q9GZ8uqFZ8Xfwz1KI4pfGun5HLYsn4h3Um8KaxwBRBlQ4MEZ
         1N4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Dycem5Iy;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k189sor2567909lfg.2.2019.02.11.09.02.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 09:02:06 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Dycem5Iy;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UhMN5gACQr1+W4A8Ag5wPDh62RaNjK/ZgHm434PrC78=;
        b=Dycem5Iy15XhBFQsCdrlyR70cVYi8iEHdjbiM68ElBqd2AuRvAsNQVBPszRVGhzOes
         4ghWIEDaZJqjwIvPAoy9X2DP7JqHWi80tnUpOlPWlpZ1uM1s61kbY33b7oQI39GLLDGn
         E61Ey9sXAEhgkUTxWs3YjJn/cr2UtlFvIsMQptsivCA4qcu2lBVw1mBwHXi14ZhLqfZT
         llfzt7bn5yuGTsb/KDKH+rY6A+TOjuCAl9E0Djzyw3HMlvO3y65at592q5FsX1KdRYDL
         KORq40gRwIB8Akjia616vJ//3AM1qSrbGnqfQtj9Zf7Jn60umhLieOoHQwDpAo7mMfoP
         LsLA==
X-Google-Smtp-Source: AHgI3IalfbXEC0ubkiPvBEKZp244GmIb+2indUy8ujEZOIJyFGOHcxcPXDTtIiBWV4qDRv6rjSWWM0OTaxXYOKcGqoU=
X-Received: by 2002:ac2:4318:: with SMTP id l24mr631387lfh.75.1549904525499;
 Mon, 11 Feb 2019 09:02:05 -0800 (PST)
MIME-Version: 1.0
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
 <20190131083842.GE28876@rapoport-lnx> <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
 <20190207164739.GX21860@bombadil.infradead.org> <CAFqt6zawBP5Yyy7nfoKz_6ugw8e4MVopvBaeKvaKoXcS-_oSNg@mail.gmail.com>
In-Reply-To: <CAFqt6zawBP5Yyy7nfoKz_6ugw8e4MVopvBaeKvaKoXcS-_oSNg@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 11 Feb 2019 22:36:15 +0530
Message-ID: <CAFqt6zYGSn1dA8tdiH16Mq0bzkx5DmpUo+2RUZ0nTPm+nvZS7Q@mail.gmail.com>
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

On Fri, Feb 8, 2019 at 10:52 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> On Thu, Feb 7, 2019 at 10:17 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Thu, Feb 07, 2019 at 09:19:47PM +0530, Souptick Joarder wrote:
> > > Just thought to take opinion for documentation before placing it in v3.
> > > Does it looks fine ?
> > >
> > > +/**
> > > + * __vm_insert_range - insert range of kernel pages into user vma
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + * @offset: user's requested vm_pgoff
> > > + *
> > > + * This allow drivers to insert range of kernel pages into a user vma.
> > > + *
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > > +                               unsigned long num, unsigned long offset)
> >
> > For static functions, I prefer to leave off the second '*', ie make it
> > formatted like a docbook comment, but not be processed like a docbook
> > comment.  That avoids cluttering the html with descriptions of internal
> > functions that people can't actually call.
> >
> > > +/**
> > > + * vm_insert_range - insert range of kernel pages starts with non zero offset
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + *
> > > + * Maps an object consisting of `num' `pages', catering for the user's
> >
> > Rather than using `num', you should use @num.
> >
> > > + * requested vm_pgoff
> > > + *
> > > + * If we fail to insert any page into the vma, the function will return
> > > + * immediately leaving any previously inserted pages present.  Callers
> > > + * from the mmap handler may immediately return the error as their caller
> > > + * will destroy the vma, removing any successfully inserted pages. Other
> > > + * callers should make their own arrangements for calling unmap_region().
> > > + *
> > > + * Context: Process context. Called by mmap handlers.
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > > +                               unsigned long num)
> > >
> > >
> > > +/**
> > > + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + *
> > > + * Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to
> >
> > But vm_pgoff isn't a parameter, so it's misleading to format it as such.
> >
> > > + * 0. This function is intended for the drivers that did not consider
> > > + * @vm_pgoff.
> > > + *
> > > + * Context: Process context. Called by mmap handlers.
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > > +                               unsigned long num)
> >
> > I don't think we should call it 'buggy'.  'zero' would make more sense
> > as a suffix.
>
> suffix can be *zero or zero_offset* whichever suits better.
>
> >
> > Given how this interface has evolved, I'm no longer sure than
> > 'vm_insert_range' makes sense as the name for it.  Is it perhaps
> > 'vm_map_object' or 'vm_map_pages'?
> >
>
> I prefer vm_map_pages. Considering it, both the interface name can be changed
> to *vm_insert_range -> vm_map_pages* and *vm_insert_range_buggy ->
> vm_map_pages_{zero/zero_offset}.
>
> As this is only change in interface name and rest of code remain same
> shall I post it in v3 ( with additional change log mentioned about interface
> name changed) ?
>
> or,
>
> It will be a new patch series ( with carry forward all the Reviewed-by
> / Tested-by on
> vm_insert_range/ vm_insert_range_buggy ) ?

Any suggestion on this minor query ?

