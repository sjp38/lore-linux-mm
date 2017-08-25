Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 286F66810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:32:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id j72so1248696wmi.5
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:32:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u7si2865131wrg.183.2017.08.25.14.32.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 14:32:15 -0700 (PDT)
Date: Fri, 25 Aug 2017 14:32:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] mm/cma: manage the memory of the CMA area by using
 the ZONE_MOVABLE
Message-Id: <20170825143213.5c7de68783b78fafb461c845@linux-foundation.org>
In-Reply-To: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 24 Aug 2017 15:36:30 +0900 js1304@gmail.com wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
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
> 

But "mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE" did
not do very well at review - both Michal and Vlastimil are looking for
changes.  So we're not ready for a patch series which depends upon that
one?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
