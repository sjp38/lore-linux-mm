Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C06886B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 08:24:20 -0400 (EDT)
Date: Wed, 8 Jul 2009 08:32:44 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 4/4] fs: tmpfs, ext2 use new truncate
Message-ID: <20090708123244.GA22722@infradead.org>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144918.GF2714@wotan.suse.de> <20090707163829.GB14947@infradead.org> <20090708065327.GM2714@wotan.suse.de> <20090708111420.GB20924@duck.suse.cz> <20090708122250.GP2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708122250.GP2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 02:22:50PM +0200, Nick Piggin wrote:
> OK fair enough. But I don't know if all those checks are
> realy appropriate. For example an IS_APPEND inode should
> be able to have its blocks trimmed off if a write fails.

It should.  But I think that's a separate issue of what we're trying to
fix right now.  So let's just do the method reshuffle now and then sort
out the checks later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
