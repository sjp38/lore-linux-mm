Date: Sat, 5 Nov 2005 22:17:28 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: Does shmem_getpage==>shmem_alloc_page==>alloc_page_vma hold
 mmap_sem?
Message-Id: <20051105221728.3fa25f69.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0511060547120.14675@goblin.wat.veritas.com>
References: <20051105212133.714da0d2.pj@sgi.com>
	<Pine.LNX.4.61.0511060547120.14675@goblin.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: ak@suse.de, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh wrote:
> It's safe but horrid.

Ok - thanks for the explanation.

Now I don't feel so bad about some of my cpuset locking hacks.

(Yes, Andrew, I'm still looking at my latest hack, 
the down_write_trylock() call in cpuset.c refresh_mems.)

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
