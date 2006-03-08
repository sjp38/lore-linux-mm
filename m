From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Date: Wed, 8 Mar 2006 12:28:05 +1100
References: <200603081013.44678.kernel@kolivas.org> <200603081212.03223.kernel@kolivas.org> <20060307172337.1d97cd80.akpm@osdl.org>
In-Reply-To: <20060307172337.1d97cd80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603081228.05820.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Mar 2006 12:23 pm, Andrew Morton wrote:
> Con Kolivas <kernel@kolivas.org> wrote:
> > > but, but.  If prefetching is prefetching stuff which that game will
> > > soon use then it'll be an aggregate improvement.  If prefetch is
> > > prefetching stuff which that game _won't_ use then prefetch is busted. 
> > > Using yield() to artificially cripple kprefetchd is a rather sad
> > > workaround isn't it?
> >
> > It's not the stuff that it prefetches that's the problem; it's the disk
> > access.
>
> But the prefetch code tries to avoid prefetching when the disk is otherwise
> busy (or it should - we discussed that a bit a while ago).

Anything that does disk access delays prefetch fine. Things that only do heavy 
cpu do not delay prefetch. Anything reading from disk will be noticeable 
during 3d gaming.

> Sorry, I'm not trying to be awkward here - I think that nobbling prefetch
> when there's a lot of CPU activity is just the wrong thing to do and it'll
> harm other workloads.

I can't distinguish between when cpu activity is important (game) and when it 
is not (compile), and assuming worst case scenario and not doing any swap 
prefetching is my intent. I could add cpu accounting to prefetch_suitable() 
instead, but that gets rather messy and yielding achieves the same endpoint.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
