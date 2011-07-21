Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 45C506B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 16:50:49 -0400 (EDT)
Date: Thu, 21 Jul 2011 21:50:42 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: linux-next: Tree for July 18 (mm/truncate.c)
Message-ID: <20110721205042.GC31405@ZenIV.linux.org.uk>
References: <20110718203501.232bd176e83ff65f056366e6@canb.auug.org.au>
 <20110718081816.2106117e.rdunlap@xenotime.net>
 <20110718152117.GA8844@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110718152117.GA8844@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>

On Mon, Jul 18, 2011 at 11:21:18AM -0400, Christoph Hellwig wrote:
> On Mon, Jul 18, 2011 at 08:18:16AM -0700, Randy Dunlap wrote:
> > On Mon, 18 Jul 2011 20:35:01 +1000 Stephen Rothwell wrote:
> > 
> > > Hi all,
> > 
> > mm/truncate.c:612: error: implicit declaration of function 'inode_dio_wait'
> > 
> > mm/truncate.c should be #include-ing <linux/fs.h> for that function's
> > prototype, but that doesn't help when CONFIG_BLOCK is not enabled,
> > which is the case in this build failure.
> 
> Oops.  Two choices here:
> 
>  a) stub it out for non-blocks.
>  b) move it out of directio.c so that it's always provided.
> 
> I'd be fine with either one.  Al, any preferences?

None...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
