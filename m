Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B2DAC60032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 16:22:15 -0400 (EDT)
In-reply-to: <20100520201122.GL10452@parisc-linux.org> (message from Matthew
	Wilcox on Thu, 20 May 2010 14:11:22 -0600)
Subject: Re: [RFC PATCH] fuse: support splice() reading from fuse device
References: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005201043321.23538@i5.linux-foundation.org> <E1OFAsd-0000Ra-1V@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005201215120.23538@i5.linux-foundation.org> <E1OFC1b-0000Yx-80@pomaz-ex.szeredi.hu> <20100520201122.GL10452@parisc-linux.org>
Message-Id: <E1OFCFp-0000dB-Es@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 20 May 2010 22:22:05 +0200
Sender: owner-linux-mm@kvack.org
To: Matthew Wilcox <matthew@wil.cx>
Cc: miklos@szeredi.hu, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jens.axboe@oracle.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 May 2010, Matthew Wilcox wrote:
> On Thu, May 20, 2010 at 10:07:23PM +0200, Miklos Szeredi wrote:
> > > It says nothing at all, in short. You need to have a real source, and a 
> > > real destination. Not some empty filesystem and /dev/null destination.
> > 
> > Sure, I will do that.  It's just a lot harder to measure the effects
> > on hardware I have access to, where the CPU speed is just damn too
> > large compared to I/O speed.
> 
> Try running a CPU burner on all the cores.  Something that's low priority,
> so it'll be preempted by FUSE, and doesn't consume much cache.

Umm, that doesn't really make the CPU any slower, it just makes it
consume more power.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
