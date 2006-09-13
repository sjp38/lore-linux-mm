Date: Wed, 13 Sep 2006 15:30:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: why inode creation with GFP_HIGHUSER?
In-Reply-To: <34a75100609131527x458d7601x5aa885bb56b6bad6@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0609131528510.20316@schroedinger.engr.sgi.com>
References: <34a75100609130734m68729bdaj30258c10edfa7947@mail.gmail.com>
 <34a75100609130754t24b8bde6xcebda4f0684c51cb@mail.gmail.com>
 <Pine.LNX.4.64.0609131030580.17927@schroedinger.engr.sgi.com>
 <34a75100609131527x458d7601x5aa885bb56b6bad6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: girish <girishvg@gmail.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Sep 2006, girish wrote:

> > I am not sure what you intend to do. The kernel already avoids mapping
> > highmem pages into the kernel as much as possible.
> 
> that's the whole confusion. kernel is supposed to *avoid* allocating
> from ZONE_HIGHMEM if there is some memory left in ZONE_DMA and/or

The kernel favors ZONE_HIGHMEM allocations for certain type of 
allocations. Like those marked GF_HIGHUSER. It avoid establishing
mappings of its own. The mappings via the page tables are easier on
the machine and so the application will be fine with HIGHMEM pages.

> ZONE_NORMAL. but as i mentioned the zonelist selection that happens
> based  on GFP_* mask (in this case GFP_HIGHUSER), makes __alloc_pages
> to allocate from a list which has both HIGHMEM and DMA/NORMAL zones
> listed in it. the zonelist looping/fallback is as implemented in
> get_page_from_freelist (). to this function, the zonelist that is
> passed contains both and in the order - HIGHMEM and DMA/NORMAL zones.
> shouldn't it be NORMAl/DMA first and then HIGHMEM in the zonelist?

The fallback sequence is HIGHMEM / NORMAL / DMA for a GFP_HIGHUSER 
allocation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
