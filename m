Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7928A6B005C
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 03:13:15 -0400 (EDT)
Date: Wed, 18 Mar 2009 03:13:13 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: fput under mmap_sem
Message-ID: <20090318071313.GA30011@infradead.org>
References: <200903151459.01320.denys@visp.net.lb> <20090315221921.GY26138@disturbed>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090315221921.GY26138@disturbed>
Sender: owner-linux-mm@kvack.org
To: xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 09:19:21AM +1100, Dave Chinner wrote:
> This is a VM problem where it calls fput() with the mmap_sem() held
> in remove_vma(). It makes the incorrect assumption that filesystems
> will never use the same lock in the IO path and the inode release path.
> 
> This can deadlock if you are really unlucky.

I really wonder why other filesystems haven't hit this yet.  Any chance
we can get the fput moved out of mmap_sem to get rid of this class of
problems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
