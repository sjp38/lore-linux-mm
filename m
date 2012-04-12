Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 917C36B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 01:42:38 -0400 (EDT)
Date: Thu, 12 Apr 2012 06:42:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: compaction: try harder to isolate free pages
Message-ID: <20120412054233.GJ3789@suse.de>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
 <1333643534-1591-2-git-send-email-b.zolnierkie@samsung.com>
 <20120410103833.GE3789@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120410103833.GE3789@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>

On Tue, Apr 10, 2012 at 11:38:33AM +0100, Mel Gorman wrote:
> I think the bug you are accidentally fixing is related to how high_pfn
> is updated inside that loop. The intent is that when free pages are
> isolated that the next scan started from the same place as page
> migration may have released those pages again. As it gets updated every
> time a page is isolated the scanner is moving faster than it should.
> 
> Try this;
> 

That patch is obviously wrong so you're still looking for some other
side-effect of your patch that explains why it appears to behave better.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
