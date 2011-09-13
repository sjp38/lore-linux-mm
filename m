Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 104A3900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 01:48:49 -0400 (EDT)
Date: Tue, 13 Sep 2011 07:48:39 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 02/11] mm: vmscan: distinguish global reclaim from global
 LRU scanning
Message-ID: <20110913054839.GD2929@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-3-git-send-email-jweiner@redhat.com>
 <20110912230246.GA20975@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110912230246.GA20975@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 13, 2011 at 02:02:46AM +0300, Kirill A. Shutemov wrote:
> On Mon, Sep 12, 2011 at 12:57:19PM +0200, Johannes Weiner wrote:
> > @@ -1508,6 +1524,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >  	if (scanning_global_lru(sc)) {
> >  		nr_taken = isolate_pages_global(nr_to_scan, &page_list,
> >  			&nr_scanned, sc->order, reclaim_mode, zone, 0, file);
> > +	} else {
> > +		nr_taken = mem_cgroup_isolate_pages(nr_to_scan, &page_list,
> > +			&nr_scanned, sc->order, reclaim_mode, zone,
> > +			sc->mem_cgroup, 0, file);
> > +	}
> 
> Redundant braces.

I usually keep them for multiline branches, no matter how any
statements.

But this is temporary anyway, 10/11 gets rid of this branch, leaving
only

	nr_taken = isolate_pages(...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
