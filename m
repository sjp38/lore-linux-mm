Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9A136B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 14:40:29 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so8625235wma.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 11:40:29 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id d7si35309449wjf.81.2016.12.09.11.40.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 11:40:28 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 3A5921C2CFF
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 19:40:28 +0000 (GMT)
Date: Fri, 9 Dec 2016 19:40:27 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm, page_alloc: don't convert pfn to idx when merging
Message-ID: <20161209194027.4ltdedctw2fshuwe@techsingularity.net>
References: <20161209093754.3515-1-vbabka@suse.cz>
 <20161209172658.uebsgt5ju6gtz2bu@techsingularity.net>
 <e6f7ee3c-75ae-63a8-cde0-1d00e65cb973@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e6f7ee3c-75ae-63a8-cde0-1d00e65cb973@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Dec 09, 2016 at 07:32:22PM +0100, Vlastimil Babka wrote:
> > As a slight aside, I recently spotted that one of the largest overhead
> > in the bulk free path was in the page_is_buddy() checks so pretty much
> > anything that helps that is welcome.
> 
> Interesting, the function shouldn't be doing really much on x86 without
> debug config options? We might try further optimize the zone equivalence
> checks, perhaps?

I don't have the data any more but IIRC, it was cache miss intensive and
I assumed at the time that it was checking cache cold struct pages
during merges.

At the time I was looking at splitting the per-cpu lists into irq and
non-irq so wasn't focused on the page_is_buddy part of the profile. It
just stuck in my mind as being surprisingly high.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
