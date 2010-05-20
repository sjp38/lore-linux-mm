Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2EAA160032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 15:22:08 -0400 (EDT)
Date: Thu, 20 May 2010 12:19:08 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH] fuse: support splice() reading from fuse device
In-Reply-To: <E1OFAsd-0000Ra-1V@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.2.00.1005201215120.23538@i5.linux-foundation.org>
References: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005201043321.23538@i5.linux-foundation.org> <E1OFAsd-0000Ra-1V@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jens.axboe@oracle.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>



On Thu, 20 May 2010, Miklos Szeredi wrote:
> 
> So it's not the 20GB/s throughput that's interesting but the reduced
> CPU overhead, especially on slower processors.  Apart from cache
> effects 20GB/s throughput with a null filesystem means 1% CPU at
> 200MB/s transfer speed with _any_ filesystem.

No it doesn't. Really.

It means 1% CPU at 200MB _IF_ you trigger the zero copy and nothing else!

But that's a damn big if. Does it ever trigger in practice? I doubt it. In 
practice, you'll have to fill the pages with something in the first place. 
In practice, the destination of the data is such that you'll often end up 
copying anyway - it won't be /dev/null.

That's why I claim your benchmark is meaningless. It does NOT even say 
what you claim it says. It does not say 1% CPU on a 200MB/s transfer, 
exactly the same way my stupid pipe zero-copy didn't mean that people 
could magically get MB/s throughput with 1% CPU on pipes.

It says nothing at all, in short. You need to have a real source, and a 
real destination. Not some empty filesystem and /dev/null destination.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
