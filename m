Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8380C6B01EF
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 06:27:58 -0400 (EDT)
Date: Mon, 12 Apr 2010 11:27:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412102734.GN25756@csn.ul.ie>
References: <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <20100411104608.GA12828@elte.hu> <4BC1B2CA.8050208@redhat.com> <20100411120800.GC10952@elte.hu> <20100412060931.GP5683@laptop> <20100412070811.GD5656@random.random> <20100412072144.GS5683@laptop> <4BC2D0C9.3060201@redhat.com> <20100412080748.GC18485@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100412080748.GC18485@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 10:07:48AM +0200, Ingo Molnar wrote:
> 
> <SNIP>
> 
> [*] Note, it would be even better if the kernel provided the C library [a'ka 
>     klibc] and if hugetlbs could be utilized via malloc() et al more 

hugectl --heap 

does this. It uses the __morecore hook in glibc to back malloc with
files on hugetlbfs. There is also a programming API with some basic
usage at http://www.csn.ul.ie/~mel/docs/stream-api/

The difference in distributions will hopefully be ironed out by
replacing custom scripts with calls to hugeadm to do the bulk of the
configuration work - e.g. creating mount points and permissions. 

There is no need to be creating a new user-space library in the kernel
repo.

>     transparently by us changing the user-space library in the kernel repo and 
>     deploying it to apps via a new kernel that provides an updated C library. 
>     We dont do that so we are stuck with crappier solutions and slower 
>     propagation of changes.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
