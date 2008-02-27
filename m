Date: Wed, 27 Feb 2008 14:04:15 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
In-Reply-To: <20080227140042.66abb805.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080227133850.4249.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080227140042.66abb805.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080227140221.424C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi

> > I don't think so.
> > all modern many cpu machine stand on NUMA.
> > it mean following,
> >  - if cpu increases, then zone increases, too.
> > 
> > if default value increase by #cpus, lock contension dramatically increase
> > on large numa.
> > 
> > Have I overlooked anything?
> > 
> How about adding something like..
> == 
> CONFIG_SIMULTANEOUS_PAGE_RECLAIMERS 
> int
> default 3
> depends on DEBUG
> help
>   This value determines the number of threads which can do page reclaim
>   in a zone simultaneously. If this is too big, performance under heavy memory
>   pressure will decrease.
>   If unsure, use default.
> ==
> 
> Then, you can get performance reports from people interested in this
> feature in test cycle.

hm, intersting.
but sysctl parameter is more better, i think.

OK, I'll add it at next post.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
