From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Date: Tue, 8 Sep 2009 22:21:02 -0400
Message-ID: <20090909022102.GA28318__42798.5471710146$1252462890$gmane$org@infradead.org>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org> <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <20090424104137.GA7601@sgi.com> <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu> <1240592448.4946.35.camel@heimdal.trondhjem.org> <20090425051028.GC10088@wotan.suse.de> <20090908153007.GB2513@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF836B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 22:21:11 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <20090908153007.GB2513@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Trond Myklebust <trond.myklebust@fys.uio.no>, Miklos Szeredi <miklos@szeredi.hu>, holt@sgi.com, linux-nfs@vger.ker
List-Id: linux-mm.kvack.org

On Tue, Sep 08, 2009 at 11:30:07AM -0400, Chris Mason wrote:
> Sorry for digging up an old thread, but is there any reason we can't
> just use page_mkwrite here?  I'd love to get rid of the btrfs code to
> detect places that use set_page_dirty without a page_mkwrite.

It's not just btrfs, it's also a complete pain in the a** for XFS and
probably every filesystems using ->page_mkwrite for dirty page tracking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
