Date: Thu, 6 Mar 2008 19:53:35 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 8/8] Pageflags: Eliminate PG_xxx aliases
In-Reply-To: <200803071320.16967.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0803061951060.476@schroedinger.engr.sgi.com>
References: <20080305223815.574326323@sgi.com> <200803071148.09759.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0803061735030.27604@schroedinger.engr.sgi.com>
 <200803071320.16967.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Nick Piggin wrote:

> > It avoids us having to deal with aliases in the future.
> 
> It doesn't. You still have to deal with them.

Sortof.

You do not have to deal with it on the level of the PG_xxx enum constant. 
Yes you will have to deal with the aliases at the level of the 
functions.

> > PG_xx at this 
> > point is not unique which can be confusing. See the PG_reclaim in
> > mm/page_alloc.c. It also means PG_readahead. If I look for
> > handling of PG_readahead then I wont find it.
> 
> You can't just pretend not to deal with aliases at that point
> in mm/page_alloc.c just becuase you only have one name for the
> bit position.

If you only have one name for the bit position the you can localize the 
aliases and uses of that bit. This means you can go from a bit that you 
see set while debugging to the PG_xxx flag and then look for uses. Which 
will turn up aliases.

> You still have to know that checking for PG_reclaim in bad_page
> can only be done if it is *also* a bug for PG_readahead to be
> found set at that point too. Because it is an alias.

True.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
