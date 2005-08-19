Date: Thu, 18 Aug 2005 20:51:59 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] use mm_counter macros for nr_pte since its also under
 ptl
In-Reply-To: <20050818201719.25443ae1.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0508182051010.10236@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508181818100.2740@schroedinger.engr.sgi.com>
 <20050818201719.25443ae1.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, torvalds@osdl.org, piggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Aug 2005, Andrew Morton wrote:

> Christoph Lameter <clameter@engr.sgi.com> wrote:
> >
> > Actually this is a bug already present in Linus' tree (but still my 
> >  fault). nr_pte's needs to be managed through the mm counter macros like
> >  other counters protected by the page table fault. 
> 
> Does that mean that Linus's tree can presently go BUG?
> 
No because the mm_counter macros do nothing special at this point. Just an 
uncleanness if the page fault patches are not applied.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
