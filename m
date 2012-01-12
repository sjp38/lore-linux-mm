Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 498516B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 16:40:47 -0500 (EST)
Date: Thu, 12 Jan 2012 13:40:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
Message-Id: <20120112134045.552e2a61.akpm@linux-foundation.org>
In-Reply-To: <20120112210743.GG11715@one.firstfloor.org>
References: <1326380820.2442.186.camel@twins>
	<20120112182644.GE11715@one.firstfloor.org>
	<1326399227.2442.209.camel@twins>
	<20120112210743.GG11715@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 12 Jan 2012 22:07:43 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> On Thu, Jan 12, 2012 at 09:13:47PM +0100, Peter Zijlstra wrote:
> > On Thu, 2012-01-12 at 19:26 +0100, Andi Kleen wrote:
> > > This would break the numactl testsuite.
> > > 
> > How so? The userspace output will still contain the field, we'll simply
> > always print 0.
> 
> Then the interleave test in the test suite will fail
> 
> > 
> > But if you want I can provide a patch for numactl.
> 
> Disable the test? That would be bad too.
> 

My googling and codesearch attempts didn't reveal any users of
NUMA_INTERLEAVE_HIT.  But then, it didn't find the usage in the numactl
suite either.

It would be good if we could find some way to remove this code (and any
other code!).  If that causes a bit of pain for users of the test suite
(presumably a small number of technically able people) then that seems
acceptable to me - we end up with a better kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
