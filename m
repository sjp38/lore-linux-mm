Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 84A586B005C
	for <linux-mm@kvack.org>; Sat,  9 May 2009 06:19:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n49AKBl1012917
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 9 May 2009 19:20:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 470ED45DE51
	for <linux-mm@kvack.org>; Sat,  9 May 2009 19:20:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2382145DE69
	for <linux-mm@kvack.org>; Sat,  9 May 2009 19:20:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3C881DB803A
	for <linux-mm@kvack.org>; Sat,  9 May 2009 19:20:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C91E1DB803E
	for <linux-mm@kvack.org>; Sat,  9 May 2009 19:20:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class citizen
In-Reply-To: <alpine.DEB.1.10.0905081312080.15748@qirst.com>
References: <20090508034054.GB1202@eskimo.com> <alpine.DEB.1.10.0905081312080.15748@qirst.com>
Message-Id: <20090509191818.3AD8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat,  9 May 2009 19:20:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Elladan <elladan@eskimo.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 7 May 2009, Elladan wrote:
> 
> > > Nobody (except you) is proposing that we completely disable
> > > the eviction of executable pages.  I believe that your idea
> > > could easily lead to a denial of service attack, with a user
> > > creating a very large executable file and mmaping it.
> 
> The amount of mlockable pages is limited via ulimit. We can already make
> the pages unreclaimable through mlock().
> 
> > I don't know of any distro that applies default ulimits, so desktops are
> > already susceptible to the far more trivial "call malloc a lot" or "fork bomb"
> > attacks.  Plus, ulimits don't help, since they only apply per process - you'd
> > need a default mem cgroup before this mattered, I think.
> 
> The point remains that the proposed patch does not solve the general
> problem that we encounter with exec pages of critical components of the
> user interface being evicted from memory.
> 
> Do we have test data that shows a benefit? The description is minimal. Rik
> claimed on IRC that tests have been done. If so then the patch description
> should include the tests. Which loads benefit from this patch?
> 
> A significant change to the reclaim algorithm also needs to
> have a clear description of the effects on reclaim behavior which is also
> lacking.

btw,

This is very good news to me.
Recently I've taked sevaral time for reproducing this issue. but
I have no luck. I'm interesting its test-case.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
