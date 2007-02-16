Date: Fri, 16 Feb 2007 10:24:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Message-Id: <20070216102420.8baf7bb9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070215171355.67c7e8b4.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	<20070215171355.67c7e8b4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007 17:13:55 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 15 Feb 2007 13:05:47 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > If we do not have any swap or we have run out of swap then anonymous pages
> > can no longer be removed from memory. In that case we simply treat them
> > like mlocked pages. For a kernel compiled CONFIG_SWAP off this means
> > that all anonymous pages are marked mlocked when they are allocated.
> 
> It's nice and simple, but I think I'd prefer to wait for the existing mlock
> changes to crash a bit less before we do this.
> 
> Is it true that PageMlocked() pages are never on the LRU?  If so, perhaps
> we could overload the lru.next/prev on these pages to flag an mlocked page.
> 
> #define PageMlocked(page)	(page->lru.next == some_address_which_isnt_used_for_anwything_else)
> 

I think mlocked pages are not reclaimable but movable.
So some structure should link them to a list...


-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
