Date: Wed, 1 Dec 2004 17:59:24 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: 1/4 batch mark_page_accessed()
Message-Id: <20041201175924.75cdcb83.akpm@osdl.org>
In-Reply-To: <20041201185827.GA5459@dmt.cyclades>
References: <16800.47044.75874.56255@gargle.gargle.HOWL>
	<20041126185833.GA7740@logos.cnet>
	<41A7CC3D.9030405@yahoo.com.au>
	<20041130162956.GA3047@dmt.cyclades>
	<20041130173323.0b3ac83d.akpm@osdl.org>
	<16813.47036.476553.612418@gargle.gargle.HOWL>
	<20041201185827.GA5459@dmt.cyclades>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: nikita@clusterfs.com, nickpiggin@yahoo.com.au, Linux-Kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> > I don't think that atomic_inc will be particularly
>  > costly. generic_file_{write,read}() call find_get_page() just before
>  > calling mark_page_accessed(), so cache-line with page reference counter
>  > is most likely still exclusive owned by this CPU. 
> 
>  Assuming that is true - what could cause the slowdown? 

It isn't true.  Atomic ops have a considerable overhead, and this is
unrelated to cache misses.   This is especially true of p4's.

Now, that overhead may be justified.  Needs more study.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
