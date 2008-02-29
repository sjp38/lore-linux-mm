Date: Fri, 29 Feb 2008 11:37:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/6] Use two zonelist that are filtered by GFP mask
Message-Id: <20080229113714.e9ff22b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1204235638.5301.49.camel@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	<20080227214734.6858.9968.sendpatchset@localhost>
	<20080228133247.6a7b626f.akpm@linux-foundation.org>
	<1204235638.5301.49.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mel@csn.ul.ie, ak@suse.de, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008 16:53:58 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> > omygawd will that thing generate a lot of code!
> > 
> > It has four call sites in mm/oom_kill.c and the overall patchset increases
> > mm/oom_kill.o's text section (x86_64 allmodconfig) from 3268 bytes to 3845.
> > 
> > vmscan.o and page_alloc.o also grew a lot.  otoh total vmlinux bloat from
> > the patchset is only around 700 bytes, so I expect that with a little less
> > insanity we could actually get an aggregate improvement here.
> > 
> > Some of the inlining in mmzone.h is just comical.  Some of it is obvious
> > (first_zones_zonelist) and some of it is less obvious (pfn_present).
> 
> Yeah, Mel said he was really reaching to avoid performance regression in
> this set.   
> 
> > 
> > I applied these for testing but I really don't think we should be merging
> > such easily-fixed regressions into mainline.  Could someone please take a
> > look at de-porking core MM?
> 
> OK, Mel should be back real soon now, and I'll take a look as well.  At
> this point, we just wanted to get some more testing in -mm.
> 
maybe mm/mmzone.c can be candidate to put these into.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
