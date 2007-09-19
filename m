Date: Wed, 19 Sep 2007 09:30:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFC 4/14] Reclaim Scalability: Define page_anon()
 function
Message-Id: <20070919093044.e4b378d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1190127886.5035.10.camel@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	<20070914205425.6536.69946.sendpatchset@localhost>
	<20070918105842.5218db50.kamezawa.hiroyu@jp.fujitsu.com>
	<1190127886.5035.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007 11:04:46 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> > Hi, it seems the name 'page_anon()' is not clear..
> > In my understanding, an anonymous page is a MAP_ANONYMOUS page.
> > Can't we have better name ?
> 
> Hi, Kame-san:
> 
> I'm open to a "better name".  Probably Rik, too -- it's his original
> name.
> 
> How about one of these?
> 
> - page_is_swap_backed() or page_is_backed_by_swap_space()
> - page_needs_swap_space() or page_uses_swap_space()
> - pageNeedSwapSpaceToBeReclaimable() [X11-style :-)]
> 
My point is that the word "anonymous" is traditionally used for user's
work memory. and page_anon() page seems not to be swap-backed always.
(you includes ramfs etc..)

Hmm...how about page_anon_cache() ? 

But finally, please name it as you like. sorry for nitpicks.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
