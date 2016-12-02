Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9E86B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 01:36:54 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so1315448wma.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 22:36:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si3855544wju.259.2016.12.01.22.36.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 22:36:52 -0800 (PST)
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
References: <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com> <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
 <20161201071507.GC18272@dhcp22.suse.cz>
 <20161201072119.GD18272@dhcp22.suse.cz>
 <9f2aa4e4-d7d5-e24f-112e-a4b43f0a0ccc@suse.cz>
 <20161201141125.GB20966@dhcp22.suse.cz> <xa1t37i7ocuv.fsf@mina86.com>
 <20161201161117.GD20966@dhcp22.suse.cz> <xa1twpfjmkhc.fsf@mina86.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <445bd49a-e9ff-2db4-b5ab-700f6c72bcdc@suse.cz>
Date: Fri, 2 Dec 2016 07:36:50 +0100
MIME-Version: 1.0
In-Reply-To: <xa1twpfjmkhc.fsf@mina86.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: "Robin H. Johnson" <robbat2@gentoo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Joonsoo Kim <js1304@gmail.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On 12/01/2016 10:02 PM, Michal Nazarewicz wrote:
> On Thu, Dec 01 2016, Michal Hocko wrote:
>> I am not familiar with this code so I cannot really argue but a quick
>> look at rmem_cma_setup doesn't suggest any speicific placing or
>> anything...
>
> early_cma parses a??cmaa?? command line argument which can specify where
> exactly the default CMA area is to be located.  Furthermore, CMA areas
> can be assigned per-device (via the Device Tree IIRC).

OK, but the context of this bug report is a generic cma pool and generic 
dma alloc, which tries cma first and then fallback to 
alloc_pages_node(). If a device really requires specific placing as you 
suggest, then it probably uses a different allocation interface, 
otherwise there would be some flag to disallow the alloc_pages_node() 
fallback?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
