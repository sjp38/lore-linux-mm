Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CC9C29000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 09:46:09 -0400 (EDT)
Date: Mon, 19 Sep 2011 15:46:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 02/11] mm: vmscan: distinguish global reclaim from global
 LRU scanning
Message-ID: <20110919134606.GF21847@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-3-git-send-email-jweiner@redhat.com>
 <20110919132344.GE21847@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110919132344.GE21847@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 19-09-11 15:23:44, Michal Hocko wrote:
> On Mon 12-09-11 12:57:19, Johannes Weiner wrote:
> > The traditional zone reclaim code is scanning the per-zone LRU lists
> > during direct reclaim and kswapd, and the per-zone per-memory cgroup
> > LRU lists when reclaiming on behalf of a memory cgroup limit.
> > 
> > Subsequent patches will convert the traditional reclaim code to
> > reclaim exclusively from the per-memory cgroup LRU lists.  As a
> > result, using the predicate for which LRU list is scanned will no
> > longer be appropriate to tell global reclaim from limit reclaim.
> > 
> > This patch adds a global_reclaim() predicate to tell direct/kswapd
> > reclaim from memory cgroup limit reclaim and substitutes it in all
> > places where currently scanning_global_lru() is used for that.
> 
> I am wondering about vmscan_swappiness. Shouldn't it use global_reclaim
> instead?

Ahh, it looks like the next patch does that. Wouldn't it make more sense
to have that change here? I see that this makes the patch smaller but...
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
