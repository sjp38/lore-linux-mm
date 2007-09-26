Date: Wed, 26 Sep 2007 20:31:02 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] page->mapping clarification [1/3] base functions
In-Reply-To: <20070922034234.bdb947e4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0709262015030.7064@blonde.wat.veritas.com>
References: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0709201120510.8801@schroedinger.engr.sgi.com>
 <20070921095054.6386bae1.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0709211716220.20783@blonde.wat.veritas.com>
 <20070922034234.bdb947e4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, ricknu-0@student.ltu.se, magnus.damm@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, 22 Sep 2007, KAMEZAWA Hiroyuki wrote:
> On Fri, 21 Sep 2007 18:02:47 +0100 (BST)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > Or should I now leave PG_swapcache as is,
> > given your designs on page->mapping?
> > 
>  will conflict with my idea ?
> ==
> http://marc.info/?l=linux-mm&m=118956492926821&w=2
> ==

I asked because I had thought it would be a serious conflict: obviously
the patches as such would conflict quite a bit, but that's not serious,
one or the other just gets fixed up.

But now I don't see it - we both want to grab a further bit from the
low bits of the page->mapping pointer, you PAGE_MAPPING_INFO and me
PAGE_MAPPING_SWAP; but that's okay, so long as whoever is left using
bit (1<<2) is careful about the 32-bit case and remembers to put
__attribute__((aligned(sizeof(long long))))
on the declarations of struct address_space and struct anon_vma
and your struct page_mapping_info.

Would that waste a little memory?  I think not with SLUB,
but perhaps with SLOB, which packs a little tighter.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
