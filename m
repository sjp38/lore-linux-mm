Date: Mon, 8 Nov 2004 16:48:38 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] ignore referenced pages on reclaim when OOM
Message-ID: <20041108184838.GB3236@logos.cnet>
References: <16783.59834.7179.464876@thebsh.namesys.com> <Pine.LNX.4.44.0411081655410.8589-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0411081655410.8589-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nikita Danilov <nikita@clusterfs.com>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 08, 2004 at 04:56:25PM -0500, Rik van Riel wrote:
> On Tue, 9 Nov 2004, Nikita Danilov wrote:
> 
> >  > Speeds up extreme load performance on Rik's tests.
> > 
> > I recently tested quite similar thing, the only dfference being that in
> > my case references bit started being ignored when scanning priority
> > reached 2 rather than 0.
> > 
> > I found that it _degrades_ performance in the loads when there is a lot
> > of file system write-back going from tail of the inactive list (like
> > dirtying huge file through mmap in a loop).
> 
> Well yeah, when you reach priority 2, you've only scanned
> 1/4 of memory.  On the other hand, when you reach priority
> 0, you've already scanned all pages once - beyond that point
> the referenced bit really doesn't buy you much any more.

Nikita, 

Can you please rerun your tests with priority=0 instead of priority=2? 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
