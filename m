Date: Thu, 6 Mar 2008 14:51:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 8/8] Pageflags: Eliminate PG_xxx aliases
In-Reply-To: <200803061340.22990.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0803061450360.16212@schroedinger.engr.sgi.com>
References: <20080305223815.574326323@sgi.com> <20080305223846.780991734@sgi.com>
 <200803061340.22990.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Mar 2008, Nick Piggin wrote:

> >  	PG_mappedtodisk,	/* Has blocks allocated on-disk */
> >  	PG_reclaim,		/* To be reclaimed asap */
> > -	/* PG_readahead is only used for file reads; PG_reclaim is only for
> > writes */ -	PG_readahead = PG_reclaim, /* Reminder to do async read-ahead
> > */ PG_buddy,		/* Page is free, on buddy lists */
> 
> IMO it's nice to see these alias up front.

I could add a comment pointing to the aliases for those that are aliases?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
