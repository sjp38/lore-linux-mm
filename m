From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 8/8] Pageflags: Eliminate PG_xxx aliases
Date: Fri, 7 Mar 2008 11:48:09 +1100
References: <20080305223815.574326323@sgi.com> <200803061340.22990.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0803061450360.16212@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803061450360.16212@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803071148.09759.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 07 March 2008 09:51, Christoph Lameter wrote:
> On Thu, 6 Mar 2008, Nick Piggin wrote:
> > >  	PG_mappedtodisk,	/* Has blocks allocated on-disk */
> > >  	PG_reclaim,		/* To be reclaimed asap */
> > > -	/* PG_readahead is only used for file reads; PG_reclaim is only for
> > > writes */ -	PG_readahead = PG_reclaim, /* Reminder to do async
> > > read-ahead */ PG_buddy,		/* Page is free, on buddy lists */
> >
> > IMO it's nice to see these alias up front.
>
> I could add a comment pointing to the aliases for those that are aliases?

Yeah that would be better than nothing. I didn't quite 
understand why you made this change in the first place
though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
