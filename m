Date: Wed, 24 May 2006 21:37:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Allow migration of mlocked pages
In-Reply-To: <Pine.LNX.4.64.0605240900210.15446@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0605242126200.25708@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605231801200.12600@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605241616170.12355@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605240824050.15446@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605241640010.16435@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605240900210.15446@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 May 2006, Christoph Lameter wrote:
> On Wed, 24 May 2006, Hugh Dickins wrote:
> 
> > Oh, I'm not worried about whether ordinary VM_LOCKED pages will get
> > migrated properly, I can't see any problem with that.  It's whether
> > something somewhere is using mlock and somehow relying on the
> > physical pages to be pinned.  I don't know what form that "somehow"
> > would take, and I'm not saying there is or can be any such thing:
> > just worried that we want wide exposure yet few testers migrate.
> 
> All of these driver mappings are installed using remap_pfn_page. These are 
> mappings that are not considered by page migration at all because:

Misunderstanding again.  I've no worries about those drivers
you've supplied a patch for, what you've done there is surely okay.

I'm (slightly) worried there's some app out there that's been using
mlock to pin physical pages.  My worry may be senseless: how can
physical pages mean anything to it without a driver in the kernel
to cooperate in the assumption?

If it were a big worry, I wouldn't have sent you in this
"migrate VM_LOCKED" direction at all.  I'm all for it, just
cautioning that we want a period of exposure to varied testing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
