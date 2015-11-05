Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 71D6E82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 03:19:48 -0500 (EST)
Received: by pasz6 with SMTP id z6so83709205pas.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 00:19:48 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id dv5si8393751pbb.226.2015.11.05.00.19.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 00:19:47 -0800 (PST)
Date: Thu, 5 Nov 2015 17:19:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/5] mm, page_owner: print migratetype of a page, not
 pageblock
Message-ID: <20151105081955.GA26034@js1304-P5Q-DELUXE>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
 <1446649261-27122-2-git-send-email-vbabka@suse.cz>
 <20151105080910.GA25938@js1304-P5Q-DELUXE>
 <563B1005.3070203@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563B1005.3070203@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Thu, Nov 05, 2015 at 09:15:01AM +0100, Vlastimil Babka wrote:
> On 11/05/2015 09:09 AM, Joonsoo Kim wrote:
> > On Wed, Nov 04, 2015 at 04:00:57PM +0100, Vlastimil Babka wrote:
> >> The information in /sys/kernel/debug/page_owner includes the migratetype
> >> declared during the page allocation via gfp_flags. This is also checked against
> >> the pageblock's migratetype, and reported as Fallback allocation if these two
> >> differ (although in fact fallback allocation is not the only reason why they
> >> can differ).
> >> 
> >> However, the migratetype actually printed is the one of the pageblock, not of
> >> the page itself, so it's the same for all pages in the pageblock. This is
> >> apparently a bug, noticed when working on other page_owner improvements. Fixed.
> > 
> > We can guess page migratetype through gfp_mask output although it isn't
> > easy task for now. But, there is no way to know pageblock migratetype.
> > I used this to know how memory is fragmented.
> 
> Ah, I see. How bout just we print both migratetypes then and remove the
> "Fallback" part, which can be trivially deduced from them (and as I noted it's
> somewhat misleading anyway)?

I'm okay with your new suggestion.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
