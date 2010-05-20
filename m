Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E22760032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 16:07:31 -0400 (EDT)
In-reply-to: <alpine.LFD.2.00.1005201215120.23538@i5.linux-foundation.org>
	(message from Linus Torvalds on Thu, 20 May 2010 12:19:08 -0700 (PDT))
Subject: Re: [RFC PATCH] fuse: support splice() reading from fuse device
References: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005201043321.23538@i5.linux-foundation.org> <E1OFAsd-0000Ra-1V@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005201215120.23538@i5.linux-foundation.org>
Message-Id: <E1OFC1b-0000Yx-80@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 20 May 2010 22:07:23 +0200
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jens.axboe@oracle.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 May 2010, Linus Torvalds wrote:
> But that's a damn big if. Does it ever trigger in practice? I doubt it. In 
> practice, you'll have to fill the pages with something in the first place. 
> In practice, the destination of the data is such that you'll often end up 
> copying anyway - it won't be /dev/null.
> 
> That's why I claim your benchmark is meaningless. It does NOT even say 
> what you claim it says. It does not say 1% CPU on a 200MB/s transfer, 
> exactly the same way my stupid pipe zero-copy didn't mean that people 
> could magically get MB/s throughput with 1% CPU on pipes.

I'm talking about *overhead* not actual CPU usage.  And I know that
caches tend to reduce the effect of multiple copies, but that depends
on a lot of things as well (size of request, delay between copies,
etc.)  Generally I've seen pretty significant reductions in overhead
for eliminating each copy.

I'm not saying it will always be zero copy all the way, I'm saying
that less copies will tend to mean less overhead.  And the same is
true for making requests larger.

> It says nothing at all, in short. You need to have a real source, and a 
> real destination. Not some empty filesystem and /dev/null destination.

Sure, I will do that.  It's just a lot harder to measure the effects
on hardware I have access to, where the CPU speed is just damn too
large compared to I/O speed.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
