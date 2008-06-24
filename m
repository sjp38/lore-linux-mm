Date: Tue, 24 Jun 2008 11:31:33 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc patch 3/4] splice: remove confirm from
 pipe_buf_operations
In-Reply-To: <E1KBDBg-0002XZ-DG@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.10.0806241129590.2926@woody.linux-foundation.org>
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu>
 <alpine.LFD.1.10.0806241022120.2926@woody.linux-foundation.org> <E1KBDBg-0002XZ-DG@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 24 Jun 2008, Miklos Szeredi wrote:
> 
> OK.  But currently we have an implementation that
> 
>  1) doesn't do any of this, unless readahead is disabled

Sure. But removing even the conceptual support? Not a good idea.

> And in addition, splice-in and splice-out can return a short count or
> even zero count if the filesystem invalidates the cached pages during
> the splicing (data became stale for example).  Are these the right
> semantics?  I'm not sure.

What does that really have with splice() and removing the features? Why 
don't you just fix that issue? 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
