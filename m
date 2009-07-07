Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 64DFF6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 11:06:43 -0400 (EDT)
Date: Tue, 7 Jul 2009 11:07:58 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090707150758.GA18075@infradead.org>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144823.GE2714@wotan.suse.de> <20090707145820.GA9976@infradead.org> <20090707150257.GG2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707150257.GG2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 05:02:57PM +0200, Nick Piggin wrote:
> That's kind of why I liked it in inode_setattr better.
> 
> But if the filesystem defines its own ->setattr, then it could simply
> not define a ->setsize and do the right thing in setattr. So this
> calling convention seems not too bad.

Or the filesystem could just call into it's own setattr method
internally.  For that we'd switch back to passing the iattr to
->setsize.  For a filesystem that doesn't do anything special for
ATTR_SIZE ->setsize could point to the same function as ->setattr.

For filesystem where's it's really different they could be separate or
share helpers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
