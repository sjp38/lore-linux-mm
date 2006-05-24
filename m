Date: Wed, 24 May 2006 09:09:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Allow migration of mlocked pages
In-Reply-To: <Pine.LNX.4.64.0605241640010.16435@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0605240900210.15446@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605231801200.12600@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605241616170.12355@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605240824050.15446@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605241640010.16435@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 May 2006, Hugh Dickins wrote:

> Oh, I'm not worried about whether ordinary VM_LOCKED pages will get
> migrated properly, I can't see any problem with that.  It's whether
> something somewhere is using mlock and somehow relying on the
> physical pages to be pinned.  I don't know what form that "somehow"
> would take, and I'm not saying there is or can be any such thing:
> just worried that we want wide exposure yet few testers migrate.

All of these driver mappings are installed using remap_pfn_page. These are 
mappings that are not considered by page migration at all because:

1. They are marked VM_PFNMAP and VM_IO. vma_migratable() checks for those.
   vmas so marked will not be scanned for pages to migrate.

2. No page struct exists. check_pte_range and do_move_pages
   will skip these entries. There will never be an attempt
   to migrate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
