Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EEA946B009D
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 10:58:47 -0500 (EST)
Date: Thu, 28 Jan 2010 16:57:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 14 of 31] add pmd mangling generic functions
Message-ID: <20100128155732.GE1217@random.random>
References: <patchbomb.1264513915@v2.random>
 <d0424f095bd097ecd715.1264513929@v2.random>
 <20100126194455.GS16468@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126194455.GS16468@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 07:44:55PM +0000, Mel Gorman wrote:
> On Tue, Jan 26, 2010 at 02:52:09PM +0100, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Some are needed to build but not actually used on archs not supporting
> > transparent hugepages. Others like pmdp_clear_flush are used by x86 too.
> > 
> 
> If they are not used, why are they needed to build?

Oh well I went extra mile in my last patchset. can re-review the new
version? Maybe it builds on all archs too ;)

But I kept the pmd unused methods implemented as long as long as the
pte counterpart existed. But I ensured the pmd methods defines to
BUG() if TRANSPARENT_HUGEPAGE is null, to be 100% sure nobody uses
them unless it is allowed to. It is needed to build because things
like pmd_write are used in memory.c, but they have to be optimized
away at compile time, so no actual BUG() bytecode should never hit
kernel .text and especially BUG() will make sure it won't hit runtime
in case it does...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
