Date: Thu, 8 Nov 2007 10:59:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 07/23] SLUB: Add defrag_ratio field and sysfs support.
In-Reply-To: <20071108150705.GD2591@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711081057290.8954@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011228.102370371@sgi.com>
 <20071108150705.GD2591@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007, Mel Gorman wrote:

> On (06/11/07 17:11), Christoph Lameter didst pronounce:
> > The defrag_ratio is used to set the threshold at which defragmentation
> > should be run on a slabcache.
> > 
> 
> I'm thick, I would like to see a quick note here on what defragmentation
> means. Also, this defrag_ratio seems to have a significantly different
> meaning to the other defrag_ratio which isn't helping my poor head at
> all.

Yes that is why they have different names. The remote_node_defrag ratio 
controls the amount of remote allocs we do to reduce fragmentation.
 
> "The defrag_ratio sets a threshold at which a slab will be vacated of all
> it's objects and the pages freed during memory reclaim."

Sortof. If a slab is beyond the threshold during reclaim then reclaim will 
attempt to free the remaining objects in the slab to reclaim the whole 
slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
