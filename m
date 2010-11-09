Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E3BED6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:31:43 -0500 (EST)
Date: Tue, 9 Nov 2010 22:30:49 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01 of 66] disable lumpy when compaction is enabled
Message-ID: <20101109213049.GC6809@random.random>
References: <patchbomb.1288798055@v2.random>
 <ca2fea6527833aad8adc.1288798056@v2.random>
 <20101109121318.BC51.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109121318.BC51.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 12:18:49PM +0900, KOSAKI Motohiro wrote:
> I'm talking very personal thing now. I'm usually testing both feature.
> Then, runtime switching makes my happy :-)
> However I don't know what are you and Mel talking and agree about this.
> So, If many developer prefer this approach, I don't oppose anymore.

Mel seem to still prefer I allow lumpy for hugetlbfs with a
__GFP_LUMPY specified only for hugetlbfs. But he measured compaction
is more reliable than lumpy at creating hugepages so he seems to be ok
with this too.

> But, I bet almost all distro choose CONFIG_COMPACTION=y. then, lumpy code
> will become nearly dead code. So, I like just kill than dead code. however
> it is also only my preference. ;)

Killing dead code is my preference too indeed. But then it's fine with
me to delete it only later. In short this is least intrusive
modification I could make to the VM that wouldn't than hang the system
when THP is selected because all pte young bits are ignored for >50%
of page reclaim invocations like lumpy requires.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
