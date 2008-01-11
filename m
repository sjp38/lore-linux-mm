Date: Fri, 11 Jan 2008 10:37:30 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080111103730.2153590a@bree.surriel.com>
In-Reply-To: <20080111122225.FD59.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<20080111122225.FD59.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jan 2008 12:59:31 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi Rik
> 
> > -static inline long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
> > -					struct zone *zone, int priority)
> > +static inline long mem_cgroup_calc_reclaim(struct mem_cgroup *mem,
> > +					struct zone *zone, int priority,
> > +					int active, int file)
> >  {
> >  	return 0;
> >  }
> 
> it can't compile if memcgroup turn off.

Doh!  Good point.

Thank you for pointing out this error.  I applied your fix to my tree,
it will be in the next version.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
