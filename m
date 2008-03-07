From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 8/8] Pageflags: Eliminate PG_xxx aliases
Date: Fri, 7 Mar 2008 15:16:11 +1100
References: <20080305223815.574326323@sgi.com> <200803071320.16967.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0803061951060.476@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803061951060.476@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803071516.12268.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 07 March 2008 14:53, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Nick Piggin wrote:
> > > It avoids us having to deal with aliases in the future.
> >
> > It doesn't. You still have to deal with them.
>
> Sortof.
>
> You do not have to deal with it on the level of the PG_xxx enum constant.

But that's the easy part, and the part that I think is actually
useful because you get to explicitly see the aliases.


> Yes you will have to deal with the aliases at the level of the
> functions.

Which is the hard part.


> > > PG_xx at this
> > > point is not unique which can be confusing. See the PG_reclaim in
> > > mm/page_alloc.c. It also means PG_readahead. If I look for
> > > handling of PG_readahead then I wont find it.
> >
> > You can't just pretend not to deal with aliases at that point
> > in mm/page_alloc.c just becuase you only have one name for the
> > bit position.
>
> If you only have one name for the bit position the you can localize the
> aliases and uses of that bit. This means you can go from a bit that you
> see set while debugging to the PG_xxx flag and then look for uses. Which
> will turn up aliases.

I don't understand how this would be any different from the current
code except with the curent code, you only have to look for aliases
in one place (ie. the PG_ definitions).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
