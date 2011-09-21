Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 231D79000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:15:35 -0400 (EDT)
Date: Wed, 21 Sep 2011 17:15:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 09/11] mm: collect LRU list heads into struct lruvec
Message-ID: <20110921151529.GH8501@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-10-git-send-email-jweiner@redhat.com>
 <20110921134323.GE8501@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110921134323.GE8501@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-09-11 15:43:23, Michal Hocko wrote:
> On Mon 12-09-11 12:57:26, Johannes Weiner wrote:
[...]
> > @@ -659,10 +658,10 @@ void lru_add_page_tail(struct zone* zone,
> >  		}
> >  		update_page_reclaim_stat(zone, page_tail, file, active);
> >  		if (likely(PageLRU(page)))
> > -			head = page->lru.prev;
> > +			__add_page_to_lru_list(zone, page_tail, lru,
> > +					       page->lru.prev);
> 
> { } around multiline __add_page_to_lru_list?

Ahh, code removed in the next patch. Sorry for noise.

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
