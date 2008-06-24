In-reply-to: <E1KBEA8-0002ey-II@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Tue, 24 Jun 2008 21:26:44 +0200)
Subject: Re: [rfc patch 3/4] splice: remove confirm from
 pipe_buf_operations
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu>
 <alpine.LFD.1.10.0806241022120.2926@woody.linux-foundation.org> <E1KBDBg-0002XZ-DG@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0806241129590.2926@woody.linux-foundation.org> <E1KBDpg-0002bR-3X@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0806241216350.2926@woody.linux-foundation.org> <E1KBE7p-0002eT-CJ@pomaz-ex.szeredi.hu> <E1KBEA8-0002ey-II@pomaz-ex.szeredi.hu>
Message-Id: <E1KBEFY-0002fh-5m@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Jun 2008 21:32:20 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > 
> > > > Let's start with page_cache_pipe_buf_confirm().  How should we deal
> > > > with finding an invalidated page (!PageUptodate(page) &&
> > > > !page->mapping)?
> > > 
> > > I suspect we just have to use it. After all, it was valid when the read 
> > > was done. The fact that it got invalidated later is kind of immaterial.
> > 
> > Right.  But what if it's invalidated *before* becoming uptodate (if
> > you'd read my mail further, I discussed this).
> 
> Please ignore, this can't happen of course due to page locking...

Or it can only happen if there was an I/O error on reading the page.

So it's an issue after all...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
