Date: Wed, 24 May 2006 16:23:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Allow migration of mlocked pages
In-Reply-To: <Pine.LNX.4.64.0605231801200.12600@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0605241616170.12355@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605231801200.12600@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2006, Christoph Lameter wrote:

> Hugh clarified the role of VM_LOCKED. So we can now implement
> page migration for mlocked pages.
> 
> Allow the migration of mlocked pages. This means that try_to_unmap
> must unmap mlocked pages in the migration case.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: Hugh Dickins <hugh@veritas.com>

But it does need to sit in -mm for a while; though just sitting
there isn't going to get much testing done - any ideas on how
we could expose migration of VM_LOCKED pages to wider testing?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
