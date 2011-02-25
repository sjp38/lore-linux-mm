Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5191D8D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 07:14:23 -0500 (EST)
Date: Fri, 25 Feb 2011 12:13:53 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110225121352.GA8010@csn.ul.ie>
References: <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110203025808.GJ5843@random.random> <20110214022524.GA18198@sli10-conroe.sh.intel.com> <20110222142559.GD15652@csn.ul.ie> <1298438954.19589.7.camel@sli10-conroe> <20110223144509.GG31195@random.random> <1298534927.19589.41.camel@sli10-conroe> <20110224140413.GA5633@random.random> <1298595109.19589.46.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1298595109.19589.46.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>

On Fri, Feb 25, 2011 at 08:51:49AM +0800, Shaohua Li wrote:
> On Thu, 2011-02-24 at 22:04 +0800, Andrea Arcangeli wrote:
> > On Thu, Feb 24, 2011 at 04:08:47PM +0800, Shaohua Li wrote:
> > > with madvise, the min_free_kbytes is still high (same as the 'always'
> > > case). The result is still we have about 50M memory is reserved. you can
> > > try at your machine with boot option 'mem=2G' and check the zoneinfo
> > > output.
> > 
> > yes I know. The objective of that test was exactly to know if the
> > problem is higher memory footprint because of THP or only the
> > anti-frag/min_free_kbytes which would still be present with the
> > "madvise" setting (anti-frag is only shutdown by the "never"
> > setting). If you still have the out of memory with madvise, then you
> > can keep THP enabled "always" and then "echo 16384 >
> > /proc/sys/vm/min_free_kbytes", it should work fine then even with THP
> > always mode then, no need to disable THP (simply you won't have a good
> > guarantee that anti-frag is functional so the hugepage usage will be
> > reduced over time compared to the default min_free_kbytes that enables
> > anti-frag fully).
>
> I can disable THP or set the min_free_kbytes manually in our test, but
> just wonder if it's possible we can avoid the memory waste even with THP
> enabled, because this will make more people enable it by default.

With a lower value of min_free_kbytes, THP would give diminishing returns
over time as hugepage allocation success rates start degrading over time. It
might not happen for several days or weeks making it a tricky problem to
diagnose. So yes, the memory waste with THP enabled can be fixed but it
would only be suitable for short-term benchmarks.

> If you
> don't consider this is a problem, we can disable THP.
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
