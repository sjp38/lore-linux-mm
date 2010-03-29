Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 508026B01EE
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 14:23:19 -0400 (EDT)
Date: Mon, 29 Mar 2010 20:21:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 33 of 41] transparent hugepage vmstat
Message-ID: <20100329182141.GY5825@random.random>
References: <patchbomb.1269622804@v2.random>
 <a130f772ded64981d015.1269622837@v2.random>
 <20100329111316.7c01e1ff.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100329111316.7c01e1ff.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2010 at 11:13:16AM +0900, Daisuke Nishimura wrote:
> On Fri, 26 Mar 2010 18:00:37 +0100, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Add hugepage stat information to /proc/vmstat and /proc/meminfo.
> > 
> I'm sorry if it has been discussed already, but shouldn't we also count
> LRU_(IN)ACTIVE_LRU properly ? Is it a TODO ?

Maybe we should it's not huge priority at the moment, it still tells
accurately the number of entries in the list, it's not like garbled
information but it doesn't reflect strict memory size anymore. It
reflects the size of the list instead (only with transparent hugepage
support enabled otherwise the exact old behavior is retained). I'm
unsure how big issue is that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
