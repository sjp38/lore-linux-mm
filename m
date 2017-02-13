Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF2846B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 06:07:03 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 67so35722973wrb.5
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 03:07:03 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id 5si13393300wrr.176.2017.02.13.03.07.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 03:07:02 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 852A498DEB
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 11:07:02 +0000 (UTC)
Date: Mon, 13 Feb 2017 11:07:02 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 00/10] try to reduce fragmenting fallbacks
Message-ID: <20170213110701.vb4e6zrwhwliwm7k@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:33PM +0100, Vlastimil Babka wrote:
> Hi,
> 
> this is a v2 of [1] from last year, which was a response to Johanes' worries
> about mobility grouping regressions. There are some new patches and the order
> goes from cleanups to "obvious wins" towards "just RFC" (last two patches).
> But it's all theoretical for now, I'm trying to run some tests with the usual
> problem of not having good workloads and metrics :) But I'd like to hear some
> feedback anyway. For now this is based on v4.9.
> 
> I think the only substantial new patch is 08/10, the rest is some cleanups,
> small tweaks and bugfixes.
> 

By and large, I like the series, particularly patches 7 and 8. I cannot
make up my mind about the RFC patches 9 and 10 yet. Conceptually they
seem sound but they are much more far reaching than the rest of the
series.

It would be nice if patches 1-8 could be treated in isolation with data
on the number of extfrag events triggered, time spent in compaction and
the success rate. Patches 9 and 10 are tricy enough that they would need
data per patch where as patches 1-8 should be ok with data gathered for
the whole series.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
