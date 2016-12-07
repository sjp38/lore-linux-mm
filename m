Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C49F6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 11:45:57 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so86104989wjb.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 08:45:57 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id d82si9166702wmd.67.2016.12.07.08.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 08:45:55 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 8C05098DD0
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 16:45:55 +0000 (UTC)
Date: Wed, 7 Dec 2016 16:45:54 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161207164554.b73qjfxy2w3h3ycr@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
 <alpine.DEB.2.20.1612070849260.8398@east.gentwo.org>
 <20161207155750.yfsizliaoodks5k4@techsingularity.net>
 <alpine.DEB.2.20.1612071037480.11056@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1612071037480.11056@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Dec 07, 2016 at 10:40:47AM -0600, Christoph Lameter wrote:
> On Wed, 7 Dec 2016, Mel Gorman wrote:
> 
> > Which is related to the fundamentals of fragmentation control in
> > general. At some point there will have to be a revisit to get back to
> > the type of reliability that existed in 3.0-era without the massive
> > overhead it incurred. As stated before, I agree it's important but
> > outside the scope of this patch.
> 
> What reliability issues are there? 3.X kernels were better in what
> way? Which overhead are we talking about?
> 

3.0-era kernels had better fragmentation control, higher success rates at
allocation etc. I vaguely recall that it had fewer sources of high-order
allocations but I don't remember specifics and part of that could be the
lack of THP at the time. The overhead was massive due to massive stalls
and excessive reclaim -- hours to complete some high-allocation stress
tests even if the success rate was high.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
