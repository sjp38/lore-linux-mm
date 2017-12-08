Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8680F6B025F
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 17:37:23 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f9so6751595wra.2
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 14:37:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e26si1755008wmh.74.2017.12.08.14.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 14:37:22 -0800 (PST)
Date: Fri, 8 Dec 2017 14:37:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/3] mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE
Message-Id: <20171208143719.901b742d5238b829edac3b14@linux-foundation.org>
In-Reply-To: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tony Lindgren <tony@atomide.com>, Michal Hocko <mhocko@kernel.org>

On Fri,  1 Dec 2017 16:53:03 +0900 js1304@gmail.com wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> v2
> o previous failure in linux-next turned out that it's not the problem of
> this patchset. It was caused by the wrong assumption by specific
> architecture.
> 
> lkml.kernel.org/r/20171114173719.GA28152@atomide.com
> 
> o add missing cache flush to the patch "ARM: CMA: avoid double mapping
> to the CMA area if CONFIG_HIGHMEM = y"
> 
> 
> This patchset is the follow-up of the discussion about the
> "Introduce ZONE_CMA (v7)" [1]. Please reference it if more information
> is needed.
> 
> In this patchset, the memory of the CMA area is managed by using
> the ZONE_MOVABLE. Since there is another type of the memory in this zone,
> we need to maintain a migratetype for the CMA memory to account
> the number of the CMA memory. So, unlike previous patchset, there is
> less deletion of the code.
> 
> Otherwise, there is no big change.
> 
> Motivation of this patchset is described in the commit description of
> the patch "mm/cma: manage the memory of the CMA area by using
> the ZONE_MOVABLE". Please refer it for more information.
> 
> This patchset is based on linux-next-20170822 plus
> "mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE".

mhocko had issues with that patch which weren't addressed?
http://lkml.kernel.org/r/20170914132452.d5klyizce72rhjaa@dhcp22.suse.cz

> Thanks.
> 
> [1]: lkml.kernel.org/r/1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
