Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79E646B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 11:01:22 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z61so17515554wrc.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:01:22 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id u88si7478507wma.25.2017.02.23.08.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 08:01:20 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id B1B5F1C2211
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 16:01:19 +0000 (GMT)
Date: Thu, 23 Feb 2017 16:01:19 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 00/10] try to reduce fragmenting fallbacks
Message-ID: <20170223160119.crigcfmfzphxirh6@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170213110701.vb4e6zrwhwliwm7k@techsingularity.net>
 <19bcb38a-5dde-24d5-cf1d-50683d5ef4d9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <19bcb38a-5dde-24d5-cf1d-50683d5ef4d9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Feb 20, 2017 at 01:30:33PM +0100, Vlastimil Babka wrote:
> On 02/13/2017 12:07 PM, Mel Gorman wrote:
> > On Fri, Feb 10, 2017 at 06:23:33PM +0100, Vlastimil Babka wrote:
> > 
> > By and large, I like the series, particularly patches 7 and 8. I cannot
> > make up my mind about the RFC patches 9 and 10 yet. Conceptually they
> > seem sound but they are much more far reaching than the rest of the
> > series.
> > 
> > It would be nice if patches 1-8 could be treated in isolation with data
> > on the number of extfrag events triggered, time spent in compaction and
> > the success rate. Patches 9 and 10 are tricy enough that they would need
> > data per patch where as patches 1-8 should be ok with data gathered for
> > the whole series.
>  
> Ok let's try again with a fresh subthread after fixing automation and
> postprocessing...
> 
> <SNIP>
> 
> To sum up, patches 1-8 look OK to me. Patch 9 looks also very promising, but
> there's danger of increased allocation latencies due to the forced compaction.
> Patch 10 has either implementation bugs or there's some unforeseen consequence
> of its design.
> 

I don't have anything useful to add other than the figures for patches
1-8 look good and the fact that fragmenting events that misplace unmovable
allocations is welcome.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
