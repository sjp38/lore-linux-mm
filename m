Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A65646B0038
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 11:48:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u16so599116pfh.7
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 08:48:07 -0800 (PST)
Received: from muru.com (muru.com. [72.249.23.125])
        by mx.google.com with ESMTP id s90si326961pfk.415.2017.12.05.08.48.06
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 08:48:06 -0800 (PST)
Date: Tue, 5 Dec 2017 08:48:00 -0800
From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH v2 0/3] mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE
Message-ID: <20171205164800.GV28152@atomide.com>
References: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

* js1304@gmail.com <js1304@gmail.com> [171201 07:55]:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> v2
> o previous failure in linux-next turned out that it's not the problem of
> this patchset. It was caused by the wrong assumption by specific
> architecture.
> 
> lkml.kernel.org/r/20171114173719.GA28152@atomide.com

Thanks works me, I've sent a pull request for the related fix for
v4.15-rc cycle. So feel free to add for the whole series:

Tested-by: Tony Lindgren <tony@atomide.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
