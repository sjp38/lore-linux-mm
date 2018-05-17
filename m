Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F31D56B04E4
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:15:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k16-v6so3056429wrh.6
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:15:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j45-v6si2048521ede.374.2018.05.17.06.15.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 May 2018 06:15:26 -0700 (PDT)
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8a672075-e188-0e72-6e48-dbec4583ef92@suse.cz>
Date: Thu, 17 May 2018 15:15:22 +0200
MIME-Version: 1.0
In-Reply-To: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ville Syrjala <ville.syrjala@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/17/2018 02:59 PM, Ville Syrjala wrote:
> From: Ville SyrjA?lA? <ville.syrjala@linux.intel.com>
> 
> This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> 
> Make x86 with HIGHMEM=y and CMA=y boot again.

Um, any more details? This looks rather rash IMHO. Or was there some
previous discussion I haven't seen? We are at rc5 so it can still be
fixed rather than reverted?

> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Tony Lindgren <tony@atomide.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Laura Abbott <lauraa@codeaurora.org>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Ville SyrjA?lA? <ville.syrjala@linux.intel.com>
