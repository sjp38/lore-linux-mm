Date: Wed, 24 Nov 2004 08:40:20 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH]: 1/4 batch mark_page_accessed()
Message-ID: <20041124104020.GA9777@logos.cnet>
References: <16800.47044.75874.56255@gargle.gargle.HOWL> <20041121131250.26d2724d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041121131250.26d2724d.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <nikita@clusterfs.com>, Linux-Kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 21, 2004 at 01:12:50PM -0800, Andrew Morton wrote:
> Nikita Danilov <nikita@clusterfs.com> wrote:
> >
> > Batch mark_page_accessed() (a la lru_cache_add() and lru_cache_add_active()):
> >  page to be marked accessed is placed into per-cpu pagevec
> >  (page_accessed_pvec). When pagevec is filled up, all pages are processed in a
> >  batch.
> > 
> >  This is supposed to decrease contention on zone->lru_lock.
> 
> Looks sane, althought it does add more atomic ops (the extra
> get_page/put_page).  Some benchmarks would be nice to have.

I'll run STP benchmarks as soon as STP is working again. 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
