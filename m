Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8CADA6B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 01:39:25 -0400 (EDT)
Date: Wed, 9 Sep 2009 07:39:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Message-ID: <20090909053926.GA20862@wotan.suse.de>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org> <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <20090424104137.GA7601@sgi.com> <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu> <1240592448.4946.35.camel@heimdal.trondhjem.org> <20090425051028.GC10088@wotan.suse.de> <20090908153007.GB2513@think> <20090909022102.GA28318@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090909022102.GA28318@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Chris Mason <chris.mason@oracle.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Miklos Szeredi <miklos@szeredi.hu>, holt@sgi.com, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 08, 2009 at 10:21:02PM -0400, Christoph Hellwig wrote:
> On Tue, Sep 08, 2009 at 11:30:07AM -0400, Chris Mason wrote:
> > Sorry for digging up an old thread, but is there any reason we can't
> > just use page_mkwrite here?  I'd love to get rid of the btrfs code to
> > detect places that use set_page_dirty without a page_mkwrite.
> 
> It's not just btrfs, it's also a complete pain in the a** for XFS and
> probably every filesystems using ->page_mkwrite for dirty page tracking.

Well I guess I should really get out my put_user_pages patches and
propose doing page locking or something. One problem is just going
through and converting all callers... another problem is that
nobody seemed to care much last time but hopefully there is more
interest now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
