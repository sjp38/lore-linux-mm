Date: Wed, 10 Nov 2004 18:09:22 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] ignore referenced pages on reclaim when OOM
Message-ID: <20041110200922.GE12867@logos.cnet>
References: <16783.59834.7179.464876@thebsh.namesys.com> <Pine.LNX.4.44.0411081655410.8589-100000@chimarrao.boston.redhat.com> <20041108142837.307029fc.akpm@osdl.org> <20041110184134.GC12867@logos.cnet> <20041110142900.09552f7f.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041110142900.09552f7f.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: riel@redhat.com, nikita@clusterfs.com, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2004 at 02:29:00PM -0800, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> > So z->all_unreclaimable logic and "OOM detection" are conflicting goals.
> 
> Only in a single case: where a zone is all_unreclaimable and some pages
> have recently become reclaimable but we don't know about it yet.

The thing is - if you dont scan the zones "enough" you have no way of 
reliably knowing it is OOM.

But on the other hand, scanning it wastes CPU time - what you call "mad scanning".

They are two extremes, I feel we need a balance between them.

> Certainly it can happen, but it sounds really unlikely to me.  So I suspect
> that if you were to fix that problem by some means, it wouldn't help
> anything.
> 
>But maybe I'm wrong, or maybe the all_unreclaimable logic has rotted. 

I dont think all_unreclaimable logic is rotted - it does what what it is
expected to do. 

At least thats how I see things, maybe I'm wrong and it is indeed rotted.

> Have you tried simply disabling it?

Tried now - if I disable it then balance_pgdat() detects the OOM situation by noticing
its not successful freeing pages (thus setting worked_dma and worked_normal, 
see patch), and kills the memory hog. Side note, the memory hog runs _much_ faster
without all_unreclaimable logic.

I'll continue hacking on this tomorrow.

As always, thanks for the input :D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
