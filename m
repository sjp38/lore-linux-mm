Date: Wed, 1 Dec 2004 16:58:27 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH]: 1/4 batch mark_page_accessed()
Message-ID: <20041201185827.GA5459@dmt.cyclades>
References: <16800.47044.75874.56255@gargle.gargle.HOWL> <20041126185833.GA7740@logos.cnet> <41A7CC3D.9030405@yahoo.com.au> <20041130162956.GA3047@dmt.cyclades> <20041130173323.0b3ac83d.akpm@osdl.org> <16813.47036.476553.612418@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16813.47036.476553.612418@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, Linux-Kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

<snip>

>  > >  On the other hand, without batching you mix the locality up in LRU - the LRU becomes 
>  > >  more precise in terms of "LRU aging", but less ordered in terms of sequential 
>  > >  access pattern.
>  > > 
>  > >  The disk IO intensive reaim has very significant gain from the batching, its
>  > >  probably due to the enhanced LRU ordering (what Nikita says).
>  > > 
>  > >  The slowdown is probably due to the additional atomic_inc by page_cache_get(). 
>  > > 
>  > >  Is there no way to avoid such page_cache_get there (and in lru_cache_add also)?
>  > 
>  > Not really.  The page is only in the pagevec at that time - if someone does
>  > a put_page() on it the page will be freed for real, and will then be
>  > spilled onto the LRU.  Messy.
> 
> I don't think that atomic_inc will be particularly
> costly. generic_file_{write,read}() call find_get_page() just before
> calling mark_page_accessed(), so cache-line with page reference counter
> is most likely still exclusive owned by this CPU. 

Assuming that is true - what could cause the slowdown? 

There are only benefits from the makr_page_accessed batching, I can't
see any drawbacks. Do you?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
