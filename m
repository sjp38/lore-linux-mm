Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B6D7F6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:12:49 -0400 (EDT)
Date: Tue, 18 Aug 2009 15:12:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/3] page-allocator: Split per-cpu list into one-list-per-migrate-type
Message-ID: <20090818131248.GR9962@wotan.suse.de>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <1250594162-17322-2-git-send-email-mel@csn.ul.ie> <20090818114335.GO9962@wotan.suse.de> <20090818131024.GD31469@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090818131024.GD31469@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 02:10:24PM +0100, Mel Gorman wrote:
> On Tue, Aug 18, 2009 at 01:43:35PM +0200, Nick Piggin wrote:
> > On Tue, Aug 18, 2009 at 12:16:00PM +0100, Mel Gorman wrote:
> Tell me about it. The dcache overhead of this is a problem although I
> tried to limit the damage using pahole to see how much padding I had to
> play with and staying within it where possible.
> 
> > But no I think this is a good idea.
> > 
> 
> Thanks. Is that an Ack?

Sure, your numbers seem OK. I don't know if there is much more you
can do without having it merged somewhere...

Acked-by: Nick Piggin <npiggin@suse.de>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
