Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E444C282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:48:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C94EA21908
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:48:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MgrpJ4M1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C94EA21908
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6807E8E0049; Thu,  7 Feb 2019 11:48:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 655E48E0002; Thu,  7 Feb 2019 11:48:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56BB58E0049; Thu,  7 Feb 2019 11:48:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AECF8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:48:20 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 75so314432pfq.8
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:48:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3Crx6L2SCrC/hAezTHTZyMkEY70y9OGZyoS8mOjuiIQ=;
        b=CjiRKHI7IuQD98dBFURTUmmuEJ1DHLBUhwBoF6sMh3U1Q1eP34tJM//SKxtVV2klql
         5YDVUmGEbKzezbaw//yTinLAujDEJtMYGDnpYG1/JsBmA13KtHFyKqACTRFKR8kHA33H
         MVCl6Fh8E/Wb4S62n3FQCqHRvlhnzqErkcHXmbOGufIzY3Dn//qahFriHcjs6O+dmxcD
         8DM/2PU4N4Z1ZVZ3XLCfPM8hPyCQHsQv5zuIn4w3YcbYibL3E8i4VobgBi/DR4IbzprD
         JxApSAl0jYHLVbewEepqid6Y+vJIIMYSFCpWk9ZpHmcdbwk4G3KQr5kMIAbCfdz6Q2PZ
         bejg==
X-Gm-Message-State: AHQUAubLgJkGnLXtJF5KjI7/c2ClbuX6p4VSXsadgLiVXg93QONstLJz
	oCRAGJ8W+MheZzYcdGdqa9Jhu6zytQSoaUps9svFHpGyXfMGYMQ/OhmE6jKd/x6/fMCDNlMPECy
	2/jM6BoUWpGN0zkFd09+Nf1GT+qGJ/NZ/9n5foaVCRccCA4X+JPKreKcgWoRq5qQQNw==
X-Received: by 2002:a63:f74f:: with SMTP id f15mr15605211pgk.190.1549558099710;
        Thu, 07 Feb 2019 08:48:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaGnGnugfnFyU7Xbz12Pj/VZg8HyC9lirgIgFFqkxqJnC1VR8sDzRtulzMHJWQhqsFMVxDY
X-Received: by 2002:a63:f74f:: with SMTP id f15mr15605152pgk.190.1549558098751;
        Thu, 07 Feb 2019 08:48:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549558098; cv=none;
        d=google.com; s=arc-20160816;
        b=aXaJy+AlEfp02SGVYqlcpi0aDoR5RgB1l6Z5URW2Khq8PC+EX72/xZgJ0G3xytSQ4D
         TLglol+MzFkHyfzTgbvCzBy+GbymmXqXuWmvEM+blRwjbRXI410a9H2ADo8bVP6F47YR
         TTnTB3b3F8R1QkHvsyFYToOcM4vMPQNNMLhRe3OeDHc60v5QDwkQYHxppTruHeI4tEIJ
         rTq9FYdeyYO2QBo1mmaLS84yn4Fnpyun2nRzQmVOdq7wYvPajq0AQKzklZu2LU5TG6M2
         Lcquia2TKOI9vnxjfoWV9Qy7BY59xe0Dv07BBH6bZDtB8Oqr5TWDU5oMXoYkY/VbR7Nn
         2WLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3Crx6L2SCrC/hAezTHTZyMkEY70y9OGZyoS8mOjuiIQ=;
        b=dLczXFvhYQWwT3HO7lfD99+WzWCvBHKSuWmAno3YLCGDDpMrTf6B2m9hzd3BgWdp1H
         gg93or3ig5HVcJheaegofOjdGeyFVRVT/IX6FLULtWZo4ezqZcBIIXvlZyDziA/2Vx32
         wg4/d0RKGAJnZ6ANTfEElpxZn545EINGrnzg2jkhBNYp2dgivwSmeZXSMJ22EtAEguZu
         X3spPzFr3DRKWqjR+YV+T25CAJC4WCbH3dEySjITCasDt9NmwGefRyDi7PbAL3FSBaXl
         fQcrS9jQsfq2hGPLn9nS0bmFEJB4ggbffG90xK++wRnsu2g8XQ7DGrq/3QmPqaY2ogOU
         Be0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MgrpJ4M1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v9si9033744pgo.23.2019.02.07.08.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 08:48:18 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MgrpJ4M1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=3Crx6L2SCrC/hAezTHTZyMkEY70y9OGZyoS8mOjuiIQ=; b=MgrpJ4M1SKwbB/Yo3N593SLwA
	QNDOZMk72sEtYMlIQ2rFvlvgbFIhWnRTu0thbBjirZlJknxymzD0HlsaEH8nReOJbVVxfO458DPHx
	18yB2e7GdJ+zJKh8tL57dO6yUGJtkp6ZOctQW4gvRn8N7q103oDWHKd2S3aT32MGVDWPczZ0fLbKk
	802j/CifGuu9dRvUnhxbfXQKEAmG4f1FQ+LjKl0KMb4UJPEZSsIyATZ9pCOxvhP9w6nv9+hI3EPu9
	qv1xZyihrFaiRXH2Beb+ldPwNcCjSCXviraUqBQW8KnDrAxVFueDl/Uy9nOP9VkSNyTz0+UfhBWNV
	mRrXbihYg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grmpv-00037s-JZ; Thu, 07 Feb 2019 16:47:39 +0000
Date: Thu, 7 Feb 2019 08:47:39 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	vbabka@suse.cz, Rik van Riel <riel@surriel.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com,
	Peter Zijlstra <peterz@infradead.org>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com,
	Kees Cook <keescook@chromium.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	stefanr@s5r6.in-berlin.de, hjc@rock-chips.com,
	Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie,
	oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com,
	Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
	Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
Message-ID: <20190207164739.GX21860@bombadil.infradead.org>
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
 <20190131083842.GE28876@rapoport-lnx>
 <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 09:19:47PM +0530, Souptick Joarder wrote:
> Just thought to take opinion for documentation before placing it in v3.
> Does it looks fine ?
> 
> +/**
> + * __vm_insert_range - insert range of kernel pages into user vma
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + * @offset: user's requested vm_pgoff
> + *
> + * This allow drivers to insert range of kernel pages into a user vma.
> + *
> + * Return: 0 on success and error code otherwise.
> + */
> +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num, unsigned long offset)

For static functions, I prefer to leave off the second '*', ie make it
formatted like a docbook comment, but not be processed like a docbook
comment.  That avoids cluttering the html with descriptions of internal
functions that people can't actually call.

> +/**
> + * vm_insert_range - insert range of kernel pages starts with non zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Maps an object consisting of `num' `pages', catering for the user's

Rather than using `num', you should use @num.

> + * requested vm_pgoff
> + *
> + * If we fail to insert any page into the vma, the function will return
> + * immediately leaving any previously inserted pages present.  Callers
> + * from the mmap handler may immediately return the error as their caller
> + * will destroy the vma, removing any successfully inserted pages. Other
> + * callers should make their own arrangements for calling unmap_region().
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> 
> 
> +/**
> + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to

But vm_pgoff isn't a parameter, so it's misleading to format it as such.

> + * 0. This function is intended for the drivers that did not consider
> + * @vm_pgoff.
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)

I don't think we should call it 'buggy'.  'zero' would make more sense
as a suffix.

Given how this interface has evolved, I'm no longer sure than
'vm_insert_range' makes sense as the name for it.  Is it perhaps
'vm_map_object' or 'vm_map_pages'?

