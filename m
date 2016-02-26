Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id DB7386B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:52:33 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so67387065wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 02:52:33 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id 202si3395425wmy.77.2016.02.26.02.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 02:52:32 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 5ACCB1C2200
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 10:52:32 +0000 (GMT)
Date: Fri, 26 Feb 2016 10:52:30 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160226105230.GA2854@techsingularity.net>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225194524.GA3370@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160225194524.GA3370@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 25, 2016 at 02:45:24PM -0500, Johannes Weiner wrote:
> > THP gives impressive gains in some cases but only if they are quickly
> > available.  We're not going to reach the point where they are completely
> > free so lets take the costs out of the fast paths finally and defer the
> > cost to kswapd, kcompactd and khugepaged where it belongs.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> The cornercases Rik pointed out aside, if the mapping isn't long-lived
> enough that it can wait for khugepaged, what are the odds that the
> defrag work will be offset by the TLB savings? However, for mappings
> where it would pay off, having to do the same defrag work but doing it
> at a later time is actually a net loss. Should we consider keeping
> direct reclaim and compaction as a configurable option as least?
> 

Yes, I think so. I've a prototype now that makes it configurable and am
running some tests. I'll preserve your and Rik's ack in V2 as the patch
will be different but the default behaviour will be very similar.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
