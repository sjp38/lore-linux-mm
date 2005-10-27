Date: Thu, 27 Oct 2005 20:09:33 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: VM_XIP Request for comments
Message-ID: <20051027190933.GC16211@infradead.org>
References: <6934efce0510251542j66c0a738qe3c37fe56aaaaf2d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6934efce0510251542j66c0a738qe3c37fe56aaaaf2d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 25, 2005 at 03:42:25PM -0700, Jared Hulbert wrote:
> What would it take to get this first patch in the kernel?
> 
> The reason for the first patch is in the second patch, which I will
> try to get into the kernel list.  With this mmap()'ed files can be
> used directly from flash when possible and COW's it when necessary..

Can't you use the XIP infrastructure we already have?  Grep for
CONFIG_XIP and CONFIG_EXT2_FS_XIP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
