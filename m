Date: Wed, 24 May 2006 16:45:24 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Allow migration of mlocked pages
In-Reply-To: <Pine.LNX.4.64.0605240824050.15446@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0605241640010.16435@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605231801200.12600@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605241616170.12355@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605240824050.15446@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 May 2006, Christoph Lameter wrote:
> 
> I ran a test program that mlocked an array of pages and then migrated it
> via sys_move_pages() and then verified what happened. Will run some more 
> stress tests today.
> 
> ldso and glibc create some mlocked pages for each binary. If we do 
> migration with MPOL_MF_MOVE_ALL (common way of migrating pages) then 
> we usually will have to migrate VM_LOCKED pages of ldso and glibc. So 
> almost any testng of page migration will invariably involve migration of 
> VM_LOCKED pages.

Oh, I'm not worried about whether ordinary VM_LOCKED pages will get
migrated properly, I can't see any problem with that.  It's whether
something somewhere is using mlock and somehow relying on the
physical pages to be pinned.  I don't know what form that "somehow"
would take, and I'm not saying there is or can be any such thing:
just worried that we want wide exposure yet few testers migrate.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
