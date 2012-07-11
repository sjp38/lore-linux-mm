Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E6AA96B0073
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 21:02:09 -0400 (EDT)
Received: by yhjj63 with SMTP id j63so721218yhj.9
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:02:09 -0700 (PDT)
Date: Tue, 10 Jul 2012 18:02:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
In-Reply-To: <20120710002510.GB5935@bbox>
Message-ID: <alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com>
References: <1341878153-10757-1-git-send-email-minchan@kernel.org> <20120709170856.ca67655a.akpm@linux-foundation.org> <20120710002510.GB5935@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, 10 Jul 2012, Minchan Kim wrote:

> > So I dunno, this all looks like we have a kernel problem and we're
> > throwing our problem onto hopelessly ill-equipped users of that kernel?
> 
> As you know, this patch isn't for solving regular high-order allocations.
> As I wrote down, The problem is that we removed lumpy reclaim without any
> notification for user who might have used it implicitly.

And so now they're running with CONFIG_DEBUG_VM to try to figure out why 
they have seen a regression, which is required for your patch to have an 
effect?

> If such user disable compaction which is a replacement of lumpy reclaim,
> their system might be broken in real practice while test is passing.
> So, the goal is that let them know it in advance so that I expect they can
> test it stronger than old.
> 

So what are they supposed to do?  Enable CONFIG_COMPACTION as soon as they 
see the warning?  When they have seen the warning a specific number of 
times?  How much is "very few" high-order allocations over what time 
period?  This is what anybody seeing these messages for the first time is 
going to ask.

> Although they see the page allocation failure with compaction, it would
> be very helpful reports. It means we need to make compaction more
> aggressive about reclaiming pages.
> 

If CONFIG_COMPACTION is disabled, then how will making compaction more 
aggressive about reclaiming pages help?

Should we consider enabling CONFIG_COMPACTION in defconfig?  If not, would 
it be possible with a different extfrag_threshold (and more aggressive 
when things like THP are enabled)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
