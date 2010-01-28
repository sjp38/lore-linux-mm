Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E95736B008C
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 10:58:28 -0500 (EST)
Date: Thu, 28 Jan 2010 16:57:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 04 of 31] update futex compound knowledge
Message-ID: <20100128155758.GF1217@random.random>
References: <patchbomb.1264513915@v2.random>
 <948638099c17d3da3d6f.1264513919@v2.random>
 <20100126183706.GI16468@csn.ul.ie>
 <20100127194504.GA13766@random.random>
 <20100128153357.GC7139@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128153357.GC7139@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 03:33:57PM +0000, Mel Gorman wrote:
> On Wed, Jan 27, 2010 at 08:45:04PM +0100, Andrea Arcangeli wrote:
> > On Tue, Jan 26, 2010 at 06:37:07PM +0000, Mel Gorman wrote:
> > > I'm not fully getting from the changelog why the second round through
> > > __get_user_pages_fast() is necessary or why the write parameter is
> > > unconditionally 1.
> > 
> > The write parameter is unconditionally to 1 because the first gup_fast
> > already existing had it unconditionally set to 1, it's not relevant
> > with this change.
> > 
> 
> hmm, really? I was seeing rw == VERIFY_WRITE rather than an
> unconditional. I'll double check the kernel version I'm reading against
> when I read the next review.

No problem ;) and now I get why asked it, in my current version (last
pull) the code is:

again:
	err = get_user_pages_fast(address, 1, 1, &page);

Clearly if the above would have been rw == VERIFY_WRITE I would have
not used 1 in the __ irq disabled callout.

> Do please. That explanation helps a lot.

Glad it helps despite my broken english eheh, already included in #8
submit ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
