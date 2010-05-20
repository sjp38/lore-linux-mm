Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D1EF860032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 14:54:20 -0400 (EDT)
In-reply-to: <alpine.LFD.2.00.1005201043321.23538@i5.linux-foundation.org>
	(message from Linus Torvalds on Thu, 20 May 2010 10:49:46 -0700 (PDT))
Subject: Re: [RFC PATCH] fuse: support splice() reading from fuse device
References: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005201043321.23538@i5.linux-foundation.org>
Message-Id: <E1OFAsd-0000Ra-1V@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 20 May 2010 20:54:03 +0200
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jens.axboe@oracle.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 May 2010, Linus Torvalds wrote:
> Are there actual real loads that get improved? I don't care if it means 
> that the improvement goes from three orders of magnitude to just a couple 
> of percent. The "couple of percent on actual loads" is a lot more 
> important than "many orders of magnitude on a made-up benchmark".

The reason I've been looking at zero copy for fuse is that embedded
people have been complaining about fuse's large CPU overhead for I/O.
So large in fact that it was having a performance impact even for
relatively slow devices.  And most of that overhead comes from copying
data around.

So it's not the 20GB/s throughput that's interesting but the reduced
CPU overhead, especially on slower processors.  Apart from cache
effects 20GB/s throughput with a null filesystem means 1% CPU at
200MB/s transfer speed with _any_ filesystem.  Without bigger requests
that translates to 4% overhead and without zero copy about 15%.
That's on a core2/1.8GHz, with an embedded CPU the overhead reduction
would be even more significant.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
