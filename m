Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C77F560032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 16:11:26 -0400 (EDT)
Date: Thu, 20 May 2010 14:11:22 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [RFC PATCH] fuse: support splice() reading from fuse device
Message-ID: <20100520201122.GL10452@parisc-linux.org>
References: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005201043321.23538@i5.linux-foundation.org> <E1OFAsd-0000Ra-1V@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005201215120.23538@i5.linux-foundation.org> <E1OFC1b-0000Yx-80@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1OFC1b-0000Yx-80@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jens.axboe@oracle.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, May 20, 2010 at 10:07:23PM +0200, Miklos Szeredi wrote:
> > It says nothing at all, in short. You need to have a real source, and a 
> > real destination. Not some empty filesystem and /dev/null destination.
> 
> Sure, I will do that.  It's just a lot harder to measure the effects
> on hardware I have access to, where the CPU speed is just damn too
> large compared to I/O speed.

Try running a CPU burner on all the cores.  Something that's low priority,
so it'll be preempted by FUSE, and doesn't consume much cache.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
