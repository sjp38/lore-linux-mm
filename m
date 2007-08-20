Date: Mon, 20 Aug 2007 11:56:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch](memory hotplug) Hot-add with sparsemem-vmemmap
In-Reply-To: <20070817155908.7D91.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0708201154280.28863@schroedinger.engr.sgi.com>
References: <20070817155908.7D91.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Aug 2007, Yasunori Goto wrote:

> Todo: # Even if this patch is applied, the message "[xxxx-xxxx] potential
>         offnode page_structs" is displayed. To allocate memmap on its node,
>         memmap (and pgdat) must be initialized itself like chicken and
>         egg relationship.

Hmmmm.... You need to create something like the bootmem allocator?

Or relocate the memory map later.

Or just add a small piece of memory first so that only one memmap block is 
placed off line?
 
>       # vmemmap_unpopulate will be necessary for followings.
>          - For cancel hot-add due to error.
>          - For unplug.
> 
> Please comment.

Looks fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
