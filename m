Subject: Re: [PATCH/RFC 4/14] Reclaim Scalability: Define page_anon()
	function
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070919093044.e4b378d0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205425.6536.69946.sendpatchset@localhost>
	 <20070918105842.5218db50.kamezawa.hiroyu@jp.fujitsu.com>
	 <1190127886.5035.10.camel@localhost>
	 <20070919093044.e4b378d0.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 19 Sep 2007 12:58:39 -0400
Message-Id: <1190221119.5301.42.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-19 at 09:30 +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 18 Sep 2007 11:04:46 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > > Hi, it seems the name 'page_anon()' is not clear..
> > > In my understanding, an anonymous page is a MAP_ANONYMOUS page.
> > > Can't we have better name ?
> > 
> > Hi, Kame-san:
> > 
> > I'm open to a "better name".  Probably Rik, too -- it's his original
> > name.
> > 
> > How about one of these?
> > 
> > - page_is_swap_backed() or page_is_backed_by_swap_space()
> > - page_needs_swap_space() or page_uses_swap_space()
> > - pageNeedSwapSpaceToBeReclaimable() [X11-style :-)]
> > 
> My point is that the word "anonymous" is traditionally used for user's
> work memory. and page_anon() page seems not to be swap-backed always.
> (you includes ramfs etc..)

I did understand your point.  Sorry if my response was confusing.

Next respin will remove ramfs.  That will be treated as a
non-reclaimable address space.

> 
> Hmm...how about page_anon_cache() ? 

That would work.

> 
> But finally, please name it as you like. sorry for nitpicks.

No problem.  I agree that the name doesn't precisely match the
meaning.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
