Date: Tue, 24 Jun 2008 12:17:44 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc patch 3/4] splice: remove confirm from
 pipe_buf_operations
In-Reply-To: <E1KBDpg-0002bR-3X@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.10.0806241216350.2926@woody.linux-foundation.org>
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu>
 <alpine.LFD.1.10.0806241022120.2926@woody.linux-foundation.org> <E1KBDBg-0002XZ-DG@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0806241129590.2926@woody.linux-foundation.org> <E1KBDpg-0002bR-3X@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 24 Jun 2008, Miklos Szeredi wrote:
> 
> Let's start with page_cache_pipe_buf_confirm().  How should we deal
> with finding an invalidated page (!PageUptodate(page) &&
> !page->mapping)?

I suspect we just have to use it. After all, it was valid when the read 
was done. The fact that it got invalidated later is kind of immaterial.

splice() is an optimized read+write. The read reads it into a temporary 
buffer. The fact that it's a zero-copy buffer and basically just re-uses 
the source doesn't really change that.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
