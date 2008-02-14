Date: Thu, 14 Feb 2008 17:42:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit
 under memory pressure
Message-Id: <20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47B3F073.1070804@linux.vnet.ibm.com>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
	<20080213151242.7529.79924.sendpatchset@localhost.localdomain>
	<20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com>
	<47B3F073.1070804@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008 13:10:35 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > And I think it's big workload to relclaim all excessed pages at once.
> > 
> > How about just reclaiming small # of pages ? like
> > ==
> > if (nr_bytes_over_sl <= 0)
> > 	goto next;
> > nr_pages = SWAP_CLUSTER_MAX;
> 
> I thought about this, but wanted to push back all groups over their soft limit
> back to their soft limit quickly. I'll experiment with your suggestion and see
> how the system behaves when we push back pages slowly. Thanks for the suggestion.

My point is an unlucky process may have to reclaim tons of pages even if
what he wants is just 1 page. It's not good, IMO.

Probably backgound-reclaim patch will be able to help this soft-limit situation,
if a daemon can know it should reclaim or not.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
