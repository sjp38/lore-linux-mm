Date: Wed, 24 May 2006 08:30:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Allow migration of mlocked pages
In-Reply-To: <Pine.LNX.4.64.0605241616170.12355@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0605240824050.15446@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605231801200.12600@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605241616170.12355@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 May 2006, Hugh Dickins wrote:

> But it does need to sit in -mm for a while; though just sitting
> there isn't going to get much testing done - any ideas on how
> we could expose migration of VM_LOCKED pages to wider testing?

I ran a test program that mlocked an array of pages and then migrated it
via sys_move_pages() and then verified what happened. Will run some more 
stress tests today.

ldso and glibc create some mlocked pages for each binary. If we do 
migration with MPOL_MF_MOVE_ALL (common way of migrating pages) then 
we usually will have to migrate VM_LOCKED pages of ldso and glibc. So 
almost any testng of page migration will invariably involve migration of 
VM_LOCKED pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
