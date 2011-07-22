Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D21106B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 11:06:32 -0400 (EDT)
Date: Fri, 22 Jul 2011 11:06:22 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH -next] mm/truncate.c: fix build for CONFIG_BLOCK not
 enabled
Message-ID: <20110722150622.GA30317@infradead.org>
References: <20110718203501.232bd176e83ff65f056366e6@canb.auug.org.au>
 <20110718081816.2106117e.rdunlap@xenotime.net>
 <20110718152117.GA8844@infradead.org>
 <20110721135537.dbfea947.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110721135537.dbfea947.rdunlap@xenotime.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>

On Thu, Jul 21, 2011 at 01:55:37PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix build error when CONFIG_BLOCK is not enabled by providing a stub
> inode_dio_wait() function.
> 
> mm/truncate.c:612: error: implicit declaration of function 'inode_dio_wait'
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Looks good to me, thanks a lot Randy!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
