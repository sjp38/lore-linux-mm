Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4BF416B0055
	for <linux-mm@kvack.org>; Thu,  7 May 2009 23:40:51 -0400 (EDT)
Date: Thu, 7 May 2009 20:40:54 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090508034054.GB1202@eskimo.com>
References: <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <alpine.DEB.1.10.0905070935530.24528@qirst.com> <1241705702.11251.156.camel@twins> <alpine.DEB.1.10.0905071016410.24528@qirst.com> <1241712000.18617.7.camel@lts-notebook> <alpine.DEB.1.10.0905071231090.10171@qirst.com> <4A03164D.90203@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A03164D.90203@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 01:11:41PM -0400, Rik van Riel wrote:
> Christoph Lameter wrote:
>
>> We need some way to control this. If there would be a way to simply switch
>> off eviction of exec pages (via /proc/sys/vm/never_reclaim_exec_pages or
>> so) I'd use it.
>
> Nobody (except you) is proposing that we completely disable
> the eviction of executable pages.  I believe that your idea
> could easily lead to a denial of service attack, with a user
> creating a very large executable file and mmaping it.
>
> Giving executable pages some priority over other file cache
> pages is nowhere near as dangerous wrt. unexpected side effects
> and should work just as well.

I don't think this sort of DOS is relevant for a single user or trusted user
system.  

I don't know of any distro that applies default ulimits, so desktops are
already susceptible to the far more trivial "call malloc a lot" or "fork bomb"
attacks.  Plus, ulimits don't help, since they only apply per process - you'd
need a default mem cgroup before this mattered, I think.

Thanks,
Elladan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
