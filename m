Date: Mon, 7 Jan 2008 10:23:53 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 07/19] split anon & file LRUs for memcontrol code
Message-ID: <20080107102353.382e6c48@bree.surriel.com>
In-Reply-To: <20080107190455.22412330.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080102224144.885671949@redhat.com>
	<20080102224154.309980291@redhat.com>
	<20080107190455.22412330.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jan 2008 19:04:55 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 02 Jan 2008 17:41:51 -0500
> linux-kernel@vger.kernel.org wrote:
> 
> > Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
> > ===================================================================
> > --- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 15:55:55.000000000 -0500
> > +++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 15:56:00.000000000 -0500
> > @@ -1230,13 +1230,13 @@ static unsigned long shrink_zone(int pri
> >  
> >  	get_scan_ratio(zone, sc, percent);
> >  
> 
> I'm happy if this calclation can be following later.
> ==
> if (scan_global_lru(sc)) {
> 	get_scan_ratio(zone, sc, percent);
> } else {
> 	get_scan_ratio_cgroup(sc->cgroup, sc, percent);
> }
> ==
> To do this, 
> mem_cgroup needs to have recent_rotated_file and recent_rolated_anon ?

One possible problem could be that the cgroup can also have
pages reclaimed in global reclaim, not just in local cgroup
reclaims.

That is, these cgroup's pages can also disappear or get
rotated without the cgroup's recent_rotated_file and 
recent_rotated_anon being affected at all.

Still, having the cgroup do the same thing as the global
zones is probably the best approximation.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
