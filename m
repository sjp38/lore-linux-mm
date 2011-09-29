Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9A4F59000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 05:20:49 -0400 (EDT)
Date: Thu, 29 Sep 2011 11:20:33 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 06/11] mm: memcg: remove optimization of keeping the
 root_mem_cgroup LRU lists empty
Message-ID: <20110929092033.GB6050@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-7-git-send-email-jweiner@redhat.com>
 <20110920150229.GB3571@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920150229.GB3571@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 20, 2011 at 05:02:29PM +0200, Michal Hocko wrote:
> On Mon 12-09-11 12:57:23, Johannes Weiner wrote:
> > root_mem_cgroup, lacking a configurable limit, was never subject to
> > limit reclaim, so the pages charged to it could be kept off its LRU
> > lists.  They would be found on the global per-zone LRU lists upon
> > physical memory pressure and it made sense to avoid uselessly linking
> > them to both lists.
> > 
> > The global per-zone LRU lists are about to go away on memcg-enabled
> > kernels, with all pages being exclusively linked to their respective
> > per-memcg LRU lists.  As a result, pages of the root_mem_cgroup must
> > also be linked to its LRU lists again.
> 
> Nevertheless we still do not charge them so this should be mentioned
> here?

Added for the next revision:

	"This is purely about the LRU list, root_mem_cgroup is still
	not charged."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
