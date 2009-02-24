Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 639D36B00B3
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 09:08:46 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 11/20] Inline get_page_from_freelist() in the fast-path
Date: Wed, 25 Feb 2009 01:08:10 +1100
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <200902240232.39140.nickpiggin@yahoo.com.au> <20090224133253.GB26239@csn.ul.ie>
In-Reply-To: <20090224133253.GB26239@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902250108.11664.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 25 February 2009 00:32:53 Mel Gorman wrote:
> On Tue, Feb 24, 2009 at 02:32:37AM +1100, Nick Piggin wrote:
> > On Monday 23 February 2009 10:17:20 Mel Gorman wrote:
> > > In the best-case scenario, use an inlined version of
> > > get_page_from_freelist(). This increases the size of the text but
> > > avoids time spent pushing arguments onto the stack.
> >
> > I'm quite fond of inlining ;) But it can increase register pressure as
> > well as icache footprint as well. x86-64 isn't spilling a lot more
> > registers to stack after these changes, is it?
>
> I didn't actually check that closely so I don't know for sure. Is there a
> handier way of figuring it out than eyeballing the assembly? In the end

I guess the 5 second check is to look at how much stack the function
uses. OTOH I think gcc does do a reasonable job at register allocation.


> I dropped the inline of this function anyway. It means the patches
> reduce rather than increase text size which is a bit more clear-cut.

Cool, clear cut patches for round 1 should help to get things moving.


> > In which case you will get extra icache footprint. What speedup does
> > it give in the cache-hot microbenchmark case?
>
> I wasn't measuring with a microbenchmark at the time of writing so I don't
> know. I was going entirely by profile counts running kernbench and the
> time spent running the benchmark.

OK. Well seeing as you have dropped this for the moment, let's not
dwell on it ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
