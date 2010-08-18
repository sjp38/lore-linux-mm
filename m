Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BE21B6B01F9
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 15:34:56 -0400 (EDT)
Date: Wed, 18 Aug 2010 15:34:40 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
Message-ID: <20100818193440.GZ5854@think>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282158241.8540.85.camel@heimdal.trondhjem.org>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 03:04:01PM -0400, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Allowing kswapd to do GFP_KERNEL memory allocations (or any blocking memory
> allocations) is wrong and can cause deadlocks in try_to_release_page(), as
> the filesystem believes it is safe to allocate new memory and block,
> whereas kswapd is there specifically to clear a low-memory situation...
> 
> Set the gfp_mask to GFP_IOFS instead.

I always thought releasepage was supposed to do almost zero work.  It
could release an instantly freeable page but it wasn't supposed to dive
in and solve world hunger or anything.

I thought the VM would be using writepage for that.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
