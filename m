Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4EBF16B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:07:50 -0500 (EST)
Date: Tue, 14 Dec 2010 17:06:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 55 of 66] select CONFIG_COMPACTION if
 TRANSPARENT_HUGEPAGE enabled
Message-ID: <20101214160637.GB5638@random.random>
References: <patchbomb.1288798055@v2.random>
 <89a62752012298bb500c.1288798110@v2.random>
 <20101109151756.BC7B.A69D9226@jp.fujitsu.com>
 <20101109211145.GB6809@random.random>
 <20101118162245.GE8135@csn.ul.ie>
 <20101209190407.GJ19131@random.random>
 <20101214094556.GF13914@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101214094556.GF13914@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Tue, Dec 14, 2010 at 09:45:56AM +0000, Mel Gorman wrote:
> On Thu, Dec 09, 2010 at 08:04:07PM +0100, Andrea Arcangeli wrote:
> > On Thu, Nov 18, 2010 at 04:22:45PM +0000, Mel Gorman wrote:
> > > Just to confirm - by hang, you mean grinds to a slow pace as opposed to
> > > coming to a complete stop and having to restart?
> > 
> > Hmm it's like if you're gigabytes in swap and apps hangs for a while
> > and system is not really usable and it swaps for most new memory
> > allocations despite there's plenty of memory free, but it's not a
> > deadlock of course.
> > 
> 
> Ok, but it's likely to be kswapd being very aggressive because it's
> woken up frequently and tries to balance all zones. Once it's not
> deadlocking entirely, there isn't a more fundamental bug hiding in there
> somewhere.

kswapd isn't activated by transhuge allocations because there's
khugepaged for that and it's throttle to try a 2m alloc only once per
minute if there's fragmentation.

So the reason of the trashing is the direct lumpy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
