Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6384D6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:41:11 -0500 (EST)
Date: Tue, 9 Nov 2010 22:40:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 43 of 66] don't leave orhpaned swap cache after ksm
 merging
Message-ID: <20101109214036.GE6809@random.random>
References: <patchbomb.1288798055@v2.random>
 <d5aefe85d1dab1bb7e99.1288798098@v2.random>
 <20101109120747.BC4B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109120747.BC4B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 12:08:25PM +0900, KOSAKI Motohiro wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > When swapcache is replaced by a ksm page don't leave orhpaned swap cache.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Reviewed-by: Rik van Riel <riel@redhat.com>
> 
> This explanation seems to tell this is bugfix. If so, please separate
> this one from THP and will send mainline and -stable soon.

Right. I'm uncertain if this is so bad to require -stable I think, if
it was more urgent I would have submitted already separately but it's
true it's not THP specific.

It's only fatal for cloud computing, where the manager has to decide
to migrate more VM to one node, but it won't if it sees tons of swap
used and it will think there's not enough margin for KSM cows until
the VM is migrated back to another node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
