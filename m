From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 8/8] Pageflags: Eliminate PG_xxx aliases
Date: Fri, 7 Mar 2008 13:20:16 +1100
References: <20080305223815.574326323@sgi.com> <200803071148.09759.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0803061735030.27604@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803061735030.27604@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803071320.16967.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 07 March 2008 12:38, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Nick Piggin wrote:
> > On Friday 07 March 2008 09:51, Christoph Lameter wrote:
> > > On Thu, 6 Mar 2008, Nick Piggin wrote:
> > > > >  	PG_mappedtodisk,	/* Has blocks allocated on-disk */
> > > > >  	PG_reclaim,		/* To be reclaimed asap */
> > > > > -	/* PG_readahead is only used for file reads; PG_reclaim is only
> > > > > for writes */ -	PG_readahead = PG_reclaim, /* Reminder to do async
> > > > > read-ahead */ PG_buddy,		/* Page is free, on buddy lists */
> > > >
> > > > IMO it's nice to see these alias up front.
> > >
> > > I could add a comment pointing to the aliases for those that are
> > > aliases?
> >
> > Yeah that would be better than nothing. I didn't quite
> > understand why you made this change in the first place
> > though.
>
> It avoids us having to deal with aliases in the future.

It doesn't. You still have to deal with them.


> PG_xx at this 
> point is not unique which can be confusing. See the PG_reclaim in
> mm/page_alloc.c. It also means PG_readahead. If I look for
> handling of PG_readahead then I wont find it.

You can't just pretend not to deal with aliases at that point
in mm/page_alloc.c just becuase you only have one name for the
bit position.

You still have to know that checking for PG_reclaim in bad_page
can only be done if it is *also* a bug for PG_readahead to be
found set at that point too. Because it is an alias.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
