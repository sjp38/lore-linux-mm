Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0626B0234
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 20:53:59 -0400 (EDT)
Date: Tue, 30 Mar 2010 09:40:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 33 of 41] transparent hugepage vmstat
Message-Id: <20100330094029.3151b166.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100329182141.GY5825@random.random>
References: <patchbomb.1269622804@v2.random>
	<a130f772ded64981d015.1269622837@v2.random>
	<20100329111316.7c01e1ff.nishimura@mxp.nes.nec.co.jp>
	<20100329182141.GY5825@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2010 20:21:41 +0200, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Mon, Mar 29, 2010 at 11:13:16AM +0900, Daisuke Nishimura wrote:
> > On Fri, 26 Mar 2010 18:00:37 +0100, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > Add hugepage stat information to /proc/vmstat and /proc/meminfo.
> > > 
> > I'm sorry if it has been discussed already, but shouldn't we also count
> > LRU_(IN)ACTIVE_LRU properly ? Is it a TODO ?
> 
typo of LRU_(IN)ACTIVE_ANON of course ;)

> Maybe we should it's not huge priority at the moment, it still tells
> accurately the number of entries in the list, it's not like garbled
> information but it doesn't reflect strict memory size anymore. It
> reflects the size of the list instead (only with transparent hugepage
> support enabled otherwise the exact old behavior is retained). I'm
> unsure how big issue is that.
Hmm, "the size of the lists" might be enough for vmscan calculation,
(but, sorry, I'm not a vmscan expert).
But "Active/Inactive(anon)" in /proc/meminfo would become inaccurate.
Yes, it might not be a big deal(it doesn't cause panic), but I think we
should let users know about it by a documentation or something.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
