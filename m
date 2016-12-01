Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4C16B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 09:11:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so57445408wme.5
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 06:11:28 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t14si12171953wme.122.2016.12.01.06.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 06:11:27 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id a20so34487208wme.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 06:11:27 -0800 (PST)
Date: Thu, 1 Dec 2016 15:11:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
Message-ID: <20161201141125.GB20966@dhcp22.suse.cz>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
 <20161201071507.GC18272@dhcp22.suse.cz>
 <20161201072119.GD18272@dhcp22.suse.cz>
 <9f2aa4e4-d7d5-e24f-112e-a4b43f0a0ccc@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9f2aa4e4-d7d5-e24f-112e-a4b43f0a0ccc@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Robin H. Johnson" <robbat2@gentoo.org>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Joonsoo Kim <js1304@gmail.com>, Marek Szyprowski <m.szyprowski@samsung.com>

Let's also CC Marek

On Thu 01-12-16 08:43:40, Vlastimil Babka wrote:
> On 12/01/2016 08:21 AM, Michal Hocko wrote:
> > Forgot to CC Joonsoo. The email thread starts more or less here
> > http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz
> > 
> > On Thu 01-12-16 08:15:07, Michal Hocko wrote:
> > > On Wed 30-11-16 20:19:03, Robin H. Johnson wrote:
> > > [...]
> > > > alloc_contig_range: [83f2a3, 83f2a4) PFNs busy
> > > 
> > > Huh, do I get it right that the request was for a _single_ page? Why do
> > > we need CMA for that?
> 
> Ugh, good point. I assumed that was just the PFNs that it failed to migrate
> away, but it seems that's indeed the whole requested range. Yeah sounds some
> part of the dma-cma chain could be smarter and attempt CMA only for e.g.
> costly orders.

Is there any reason why the DMA api doesn't try the page allocator first
before falling back to the CMA? I simply have a hard time to see why the
CMA should be used (and fragment) for small requests size.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
