Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A6BE46B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 11:14:09 -0400 (EDT)
Date: Sat, 15 Aug 2009 17:14:12 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] fs: new truncate sequence
Message-ID: <20090815151412.GB30951@wotan.suse.de>
References: <20090706165438.GQ2714@wotan.suse.de> <20090815145131.GA25509@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090815145131.GA25509@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 15, 2009 at 10:51:31AM -0400, Christoph Hellwig wrote:
> Nick, what's the plan with moving forward on this?  We're badly waiting
> for it on the XFS side.  

I was hoping Al would take it but no reply... Any other git tree you
suggest, or -mm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
