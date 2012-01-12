Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 246DC6B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 16:07:45 -0500 (EST)
Date: Thu, 12 Jan 2012 22:07:43 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
Message-ID: <20120112210743.GG11715@one.firstfloor.org>
References: <1326380820.2442.186.camel@twins> <20120112182644.GE11715@one.firstfloor.org> <1326399227.2442.209.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326399227.2442.209.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 12, 2012 at 09:13:47PM +0100, Peter Zijlstra wrote:
> On Thu, 2012-01-12 at 19:26 +0100, Andi Kleen wrote:
> > This would break the numactl testsuite.
> > 
> How so? The userspace output will still contain the field, we'll simply
> always print 0.

Then the interleave test in the test suite will fail

> 
> But if you want I can provide a patch for numactl.

Disable the test? That would be bad too.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
