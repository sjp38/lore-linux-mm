Date: Sat, 22 Sep 2007 00:06:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page->mapping clarification [1/3] base functions
Message-Id: <20070922000655.6ab383bf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070921134828.45ca967e@twins>
References: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
	<20070921134828.45ca967e@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, ricknu-0@student.ltu.se
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007 13:48:28 +0200
Peter Zijlstra <peterz@infradead.org> wrote:
> > Followings are moved 
> >  * page_mapping()       ... returns swapper_space or address_space a page is on.
> > 			    (from mm.h)
> >  * page_index()         ... returns position of a page in its inode
> > 			    (from mm.h)
> >  * remove_mapping()     ... a safe routine to remove page->mapping from page.
> > 			    (from swap.h)
> 
> I have two other functions that might want integration with this scheme:
> 
>   page_file_mapping()     ... returns backing address space
>   page_file_index()       ... returns the index therein
> 
> They are identical to page_mapping_cache() and page_index() for
> page cache pages, but they also work on swap cache pages.
> 
> That is, for swapcache pages they return:
> 
> page_file_mapping:
>   page_swap_info(page)->swap_file->f_mapping
> 
> page_file_index:
>   swp_offset((swp_offset_t)page_private(page))
> 
> When a filesystem uses these functions instead of page->mapping and
> page->index, it allows passing swap cache pages into the regular
> filesystem read/write paths.
> 
Oh,
> This is useful for things like swap over NFS, where swap is backed by a
> swapfile on a 'regular' filesystem.
> 
Okay, I'll try to add them in the next set.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
