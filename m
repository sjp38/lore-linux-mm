Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C486A9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 05:49:25 -0400 (EDT)
Date: Thu, 29 Sep 2011 11:49:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 06/11] mm: memcg: remove optimization of keeping the
 root_mem_cgroup LRU lists empty
Message-ID: <20110929094918.GA21113@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-7-git-send-email-jweiner@redhat.com>
 <20110920150229.GB3571@tiehlicka.suse.cz>
 <20110929092033.GB6050@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110929092033.GB6050@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 29-09-11 11:20:33, Johannes Weiner wrote:
> On Tue, Sep 20, 2011 at 05:02:29PM +0200, Michal Hocko wrote:
> > On Mon 12-09-11 12:57:23, Johannes Weiner wrote:
> > > root_mem_cgroup, lacking a configurable limit, was never subject to
> > > limit reclaim, so the pages charged to it could be kept off its LRU
> > > lists.  They would be found on the global per-zone LRU lists upon
> > > physical memory pressure and it made sense to avoid uselessly linking
> > > them to both lists.
> > > 
> > > The global per-zone LRU lists are about to go away on memcg-enabled
> > > kernels, with all pages being exclusively linked to their respective
> > > per-memcg LRU lists.  As a result, pages of the root_mem_cgroup must
> > > also be linked to its LRU lists again.
> > 
> > Nevertheless we still do not charge them so this should be mentioned
> > here?
> 
> Added for the next revision:
> 
> 	"This is purely about the LRU list, root_mem_cgroup is still
> 	not charged."

OK, that should be more clear. Thanks!

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
