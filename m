Date: Sun, 21 Nov 2004 13:12:50 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: 1/4 batch mark_page_accessed()
Message-Id: <20041121131250.26d2724d.akpm@osdl.org>
In-Reply-To: <16800.47044.75874.56255@gargle.gargle.HOWL>
References: <16800.47044.75874.56255@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Linux-Kernel@vger.kernel.org, AKPM@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> Batch mark_page_accessed() (a la lru_cache_add() and lru_cache_add_active()):
>  page to be marked accessed is placed into per-cpu pagevec
>  (page_accessed_pvec). When pagevec is filled up, all pages are processed in a
>  batch.
> 
>  This is supposed to decrease contention on zone->lru_lock.

Looks sane, althought it does add more atomic ops (the extra
get_page/put_page).  Some benchmarks would be nice to have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
