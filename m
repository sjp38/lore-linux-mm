Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 992B66B005A
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 17:29:31 -0500 (EST)
Date: Thu, 12 Jan 2012 23:29:29 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
Message-ID: <20120112222929.GI11715@one.firstfloor.org>
References: <1326380820.2442.186.camel@twins> <20120112182644.GE11715@one.firstfloor.org> <1326399227.2442.209.camel@twins> <20120112210743.GG11715@one.firstfloor.org> <20120112134045.552e2a61.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120112134045.552e2a61.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 12, 2012 at 01:40:45PM -0800, Andrew Morton wrote:
> On Thu, 12 Jan 2012 22:07:43 +0100
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > On Thu, Jan 12, 2012 at 09:13:47PM +0100, Peter Zijlstra wrote:
> > > On Thu, 2012-01-12 at 19:26 +0100, Andi Kleen wrote:
> > > > This would break the numactl testsuite.
> > > > 
> > > How so? The userspace output will still contain the field, we'll simply
> > > always print 0.
> > 
> > Then the interleave test in the test suite will fail
> > 
> > > 
> > > But if you want I can provide a patch for numactl.
> > 
> > Disable the test? That would be bad too.
> > 
> 
> My googling and codesearch attempts didn't reveal any users of
> NUMA_INTERLEAVE_HIT.  But then, it didn't find the usage in the numactl

Obviously you have to search for "interleave_hit", the uppercase variant is 
just an kernel internal define.

> suite either.

test/regress

> 
> It would be good if we could find some way to remove this code (and any
> other code!).  If that causes a bit of pain for users of the test suite
> (presumably a small number of technically able people) then that seems
> acceptable to me - we end up with a better kernel.

The problem is that then there will be nothing left that actually
tests interleaving. The numactl has caught kernel regressions in the past.

I don't think disabling useful regression tests is a good idea.
In contrary the kernel needs far more of them, not less.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
