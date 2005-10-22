Date: Fri, 21 Oct 2005 23:16:47 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
Message-ID: <20051022011646.GD27317@logos.cnet>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com> <20051020160638.58b4d08d.akpm@osdl.org> <435883B2.2090400@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <435883B2.2090400@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com
List-ID: <linux-mm.kvack.org>

Hi Kame,

On Fri, Oct 21, 2005 at 02:59:14PM +0900, Hiroyuki KAMEZAWA wrote:
> Andrew Morton wrote:
> >Christoph Lameter <clameter@sgi.com> wrote:
> >
> >>Page migration is also useful for other purposes:
> >>
> >>1. Memory hotplug. Migrating processes off a memory node that is going
> >>   to be disconnected.
> >>
> >>2. Remapping of bad pages. These could be detected through soft ECC errors
> >>   and other mechanisms.
> >
> >
> >It's only useful for these things if it works with close-to-100% 
> >reliability.
> >
> >And there are are all sorts of things which will prevent that - mlock,
> >ongoing direct-io, hugepages, whatever.
> >
> In lhms tree, current status is below: (If I'm wrong, plz fix)
> ==
> For mlock, direct page migration will work fine. try_to_unmap_one()
> in -mhp tree has an argument *force* and ignore VM_LOCKED, it's for this.
> 
> For direct-io, we have to wait for completion.
> The end of I/O is not notified and memory_migrate() is just polling pages.
> 
> For hugepages, we'll need hugepage demand paging and more work, I think.

Hugepage pagefaulting is being worked on by Hugh and Adam Litke.

Another major problem that comes to mind is availability of largepages
on the target zone. Those allocations can be made reliable with the
fragmentation avoidance patches plus memory defragmentation using memory
migration.

So all bits should be around for hugepage migration by now? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
