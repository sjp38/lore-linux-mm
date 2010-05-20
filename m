Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B3E0060032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 07:44:23 -0400 (EDT)
In-reply-to: <20100520112821.GP25951@kernel.dk> (message from Jens Axboe on
	Thu, 20 May 2010 13:28:22 +0200)
Subject: Re: [RFC PATCH] fuse: support splice() reading from fuse device
References: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu> <20100520112821.GP25951@kernel.dk>
Message-Id: <E1OF4Ak-00088m-Jm@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 20 May 2010 13:44:18 +0200
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 May 2010, Jens Axboe wrote:
> On Thu, May 20 2010, Miklos Szeredi wrote:
> > This continues zero copy I/O support on the fuse interface.  The first
> > part of the patchset (splice write support on fuse device) was posted
> > here:
> > 
> >   http://lkml.org/lkml/2010/4/28/215
> > 
> > With Jens' pipe growing patch and additional fuse patches it was
> > possible to achieve a 20GBytes/s write throghput on my laptop in a
> > "null" filesystem (no page cache, data goes to /dev/null).
> 
> Do you have some numbers on how that compares to the same test with the
> default 16 page pipe size?

With the default 64k pipe size it's about 4 times slower than with a
pipe size of 1MB.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
