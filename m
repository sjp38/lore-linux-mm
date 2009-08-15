Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F3A296B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 11:18:22 -0400 (EDT)
Date: Sat, 15 Aug 2009 11:18:24 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 1/3] fs: new truncate sequence
Message-ID: <20090815151824.GA16697@infradead.org>
References: <20090706165438.GQ2714@wotan.suse.de> <20090815145131.GA25509@infradead.org> <20090815151412.GB30951@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090815151412.GB30951@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 15, 2009 at 05:14:12PM +0200, Nick Piggin wrote:
> On Sat, Aug 15, 2009 at 10:51:31AM -0400, Christoph Hellwig wrote:
> > Nick, what's the plan with moving forward on this?  We're badly waiting
> > for it on the XFS side.  
> 
> I was hoping Al would take it but no reply... Any other git tree you
> suggest, or -mm?

If we can get it into -mm until Al reappear that would be good.  What
are your plans to convert other filesystems?  I'd like to have at least
all that use O_DIRECT converted ASAP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
