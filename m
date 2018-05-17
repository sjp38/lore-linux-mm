Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4E5E6B04E8
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:36:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j14-v6so2737178pfn.11
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:36:38 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s75-v6si4198314pgc.484.2018.05.17.06.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 06:36:36 -0700 (PDT)
Date: Thu, 17 May 2018 16:36:29 +0300
From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180517133629.GH23723@intel.com>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180517132109.GU12670@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
> On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
> > From: Ville Syrjala <ville.syrjala@linux.intel.com>
> > 
> > This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> > 
> > Make x86 with HIGHMEM=y and CMA=y boot again.
> 
> Is there any bug report with some more details? It is much more
> preferable to fix the issue rather than to revert the whole thing
> right away.

The machine I have in front of me right now didn't give me anything.
Black screen, and netconsole was silent. No serial port on this
machine unfortunately.

-- 
Ville Syrjala
Intel
