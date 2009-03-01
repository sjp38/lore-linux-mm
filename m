Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9A5D26B00A5
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 05:37:55 -0500 (EST)
Date: Sun, 1 Mar 2009 19:37:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
In-Reply-To: <20090227113813.GB21296@wotan.suse.de>
References: <20090226171549.GH32756@csn.ul.ie> <20090227113813.GB21296@wotan.suse.de>
Message-Id: <20090301193624.6FDE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

> On Thu, Feb 26, 2009 at 05:15:49PM +0000, Mel Gorman wrote:
> > On Thu, Feb 26, 2009 at 12:00:22PM -0500, Christoph Lameter wrote:
> > > I tried the general use of a pool of zeroed pages back in 2005. Zeroing
> > > made sense only if the code allocating the page did not immediately touch
> > > the cachelines of the page.
> > 
> > Any feeling as to how often this was the case?
> 
> IMO background zeroing or anything like that is only going to
> become less attractive. Heat and energy considerations are
> relatively increasing, so doing speculative work in the kernel
> is going to become relatively more costly. 

IMHO..

In general, the value of any speculative approach depend on
forecast hitting rate.

e.g. readahead is very effective to sequential read workload, but 
no effective to random access workload.

zerod pages is always used from page_alloc(GFP_ZERO), it's valuable 
although nowadays. but it's impossible.

Then, (IMHO) rest problem is
  - What stastics is better mesurement for the forecast of future zero page
    demanding?
  - How implement it?


I have no idea yet..


> Especially in this
> case where you use nontemporal stores or otherwise reduce the
> efficiency of the CPU caches (and increase activity on bus and
> memory).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
