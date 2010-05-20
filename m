Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B296460032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 07:28:27 -0400 (EDT)
Date: Thu, 20 May 2010 13:28:22 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [RFC PATCH] fuse: support splice() reading from fuse device
Message-ID: <20100520112821.GP25951@kernel.dk>
References: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, May 20 2010, Miklos Szeredi wrote:
> This continues zero copy I/O support on the fuse interface.  The first
> part of the patchset (splice write support on fuse device) was posted
> here:
> 
>   http://lkml.org/lkml/2010/4/28/215
> 
> With Jens' pipe growing patch and additional fuse patches it was
> possible to achieve a 20GBytes/s write throghput on my laptop in a
> "null" filesystem (no page cache, data goes to /dev/null).

Do you have some numbers on how that compares to the same test with the
default 16 page pipe size?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
