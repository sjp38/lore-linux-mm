Date: Tue, 18 Sep 2007 11:40:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFC 4/14] Reclaim Scalability: Define page_anon()
 function
Message-Id: <20070918114056.db22d1a1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46EF377D.4030004@redhat.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	<20070914205425.6536.69946.sendpatchset@localhost>
	<20070918105842.5218db50.kamezawa.hiroyu@jp.fujitsu.com>
	<46EF377D.4030004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007 22:27:09 -0400
Rik van Riel <riel@redhat.com> wrote:
> > 
> > Hi, it seems the name 'page_anon()' is not clear..
> > In my understanding, an anonymous page is a MAP_ANONYMOUS page.
> > Can't we have better name ?
> 
> The idea is to distinguish pages that are (or could be) swap backed
> from pages that are filesystem backed.
> 
Yes, I know the concept.

how a bout page_not_persistent() or write precise text about the difference between
page_anon() and PageAnon().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
