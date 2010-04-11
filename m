Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8EA6B01EF
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 06:49:48 -0400 (EDT)
Date: Sun, 11 Apr 2010 12:49:00 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100411104900.GA5632@elte.hu>
References: <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100411104608.GA12828@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> > Desktops will only benefit when they bloat to ~8GB RAM and 1-2GB firefox 
> > RSS, probably not so far in the future.
> 
> 1-2GB firefox RSS is reality for me.
> 
> Btw., there's another workload that could be cache sensitive, 'git grep':
> 
>  aldebaran:~/linux> perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-load-misses --repeat 5 git grep arca >/dev/null
> 
>  Performance counter stats for 'git grep arca' (5 runs):
> 
>      1882712774  cycles                     ( +-   0.074% )
>      1153649442  instructions             #      0.613 IPC     ( +-   0.005% )
>       518815167  dTLB-loads                 ( +-   0.035% )
>         3028951  dTLB-load-misses           ( +-   1.223% )
> 
>     0.597161428  seconds time elapsed   ( +-   0.065% )

Sidenote: you might want to try the cool new threaded git grep from upstream 
Git project:

 git clone git://git.kernel.org/pub/scm/git/git.git
 cd git
 make -j

Beyond being faster, it will also probably show a bigger hugetlb speedup, as 
the effective per core (and per hyperthread) cache set is smaller than for a 
single-threaded git grep.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
