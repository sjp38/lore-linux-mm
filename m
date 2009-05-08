Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2EE036B0055
	for <linux-mm@kvack.org>; Fri,  8 May 2009 13:18:56 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3AD3982C4DD
	for <linux-mm@kvack.org>; Fri,  8 May 2009 13:31:21 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id d-2vZA0QqDld for <linux-mm@kvack.org>;
	Fri,  8 May 2009 13:31:21 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 746C782C5DE
	for <linux-mm@kvack.org>; Fri,  8 May 2009 13:31:12 -0400 (EDT)
Date: Fri, 8 May 2009 13:18:55 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
 citizen
In-Reply-To: <20090508034054.GB1202@eskimo.com>
Message-ID: <alpine.DEB.1.10.0905081312080.15748@qirst.com>
References: <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <alpine.DEB.1.10.0905070935530.24528@qirst.com> <1241705702.11251.156.camel@twins>
 <alpine.DEB.1.10.0905071016410.24528@qirst.com> <1241712000.18617.7.camel@lts-notebook> <alpine.DEB.1.10.0905071231090.10171@qirst.com> <4A03164D.90203@redhat.com> <20090508034054.GB1202@eskimo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Elladan <elladan@eskimo.com>
Cc: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 May 2009, Elladan wrote:

> > Nobody (except you) is proposing that we completely disable
> > the eviction of executable pages.  I believe that your idea
> > could easily lead to a denial of service attack, with a user
> > creating a very large executable file and mmaping it.

The amount of mlockable pages is limited via ulimit. We can already make
the pages unreclaimable through mlock().

> I don't know of any distro that applies default ulimits, so desktops are
> already susceptible to the far more trivial "call malloc a lot" or "fork bomb"
> attacks.  Plus, ulimits don't help, since they only apply per process - you'd
> need a default mem cgroup before this mattered, I think.

The point remains that the proposed patch does not solve the general
problem that we encounter with exec pages of critical components of the
user interface being evicted from memory.

Do we have test data that shows a benefit? The description is minimal. Rik
claimed on IRC that tests have been done. If so then the patch description
should include the tests. Which loads benefit from this patch?

A significant change to the reclaim algorithm also needs to
have a clear description of the effects on reclaim behavior which is also
lacking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
