Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E19B16B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 09:47:21 -0400 (EDT)
Date: Mon, 13 Jul 2009 10:10:50 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090713141050.GA16926@infradead.org>
References: <20090708063225.GL2714@wotan.suse.de> <20090708104701.GA31419@infradead.org> <20090708123412.GQ2714@wotan.suse.de> <4A54C435.1000503@panasas.com> <20090709075100.GU2714@wotan.suse.de> <4A59A517.1080605@panasas.com> <20090712144717.GA18163@infradead.org> <20090713065917.GO14666@wotan.suse.de> <20090713135324.GB3685@infradead.org> <20090713140515.GB10739@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090713140515.GB10739@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 04:05:15PM +0200, Nick Piggin wrote:
> OK that's kind of what I imagine inode_setattr becomes, but now
> that you make me look at it in that perspective, it is better to
> say inode_setattr returns to a plain helper to copy values into
> the inode once we move the truncate code out of there.
> 
> It would be good to add your simple_setattr and factor it out
> from fnotify_change, then. I guess this is what you plan to do
> after my patchset?

Exactly.  Maybe we can even fold it into your patchset, but I want
to see a few more if not all conversions before going ahead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
