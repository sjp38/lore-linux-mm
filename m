Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 335E36B0055
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 10:31:39 -0400 (EDT)
Date: Sun, 12 Jul 2009 10:47:18 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090712144717.GA18163@infradead.org>
References: <20090707150257.GG2714@wotan.suse.de> <20090707150758.GA18075@infradead.org> <20090707154809.GH2714@wotan.suse.de> <20090707163042.GA14947@infradead.org> <20090708063225.GL2714@wotan.suse.de> <20090708104701.GA31419@infradead.org> <20090708123412.GQ2714@wotan.suse.de> <4A54C435.1000503@panasas.com> <20090709075100.GU2714@wotan.suse.de> <4A59A517.1080605@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A59A517.1080605@panasas.com>
Sender: owner-linux-mm@kvack.org
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 12, 2009 at 11:55:51AM +0300, Boaz Harrosh wrote:
> I wish you would split it.
> 
> one - helper to be called by converted file systems
>       (Which just ignores the ATTR_SIZE)
> second - to be set into .setattr which does the simple_setsize + above.
> 
> More clear for FS users like me (and that ugly unmask of ATTR_SIZE)
> 
> or it's just me?

Yeah, that seems be a lot cleaner.  But let's wait until we got
rid of ->truncate for all filesystems to have the bigger picture.

> 
> Thanks
> Boaz
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
