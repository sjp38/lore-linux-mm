Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A702E6B0100
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:08:07 -0400 (EDT)
Date: Wed, 13 May 2009 15:08:11 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: do we really want to export more pdflush details in sysctls
Message-ID: <20090513130811.GE4140@kernel.dk>
References: <20090513130128.GA10382@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513130128.GA10382@lst.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: Peter W Morreale <pmorreale@novell.com>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, May 13 2009, Christoph Hellwig wrote:
> Hi all,
> 
> commit fafd688e4c0c34da0f3de909881117d374e4c7af titled
> "mm: add /proc controls for pdflush threads" adds two more sysctl
> variables exposing details about pdflush threads.  At the same time
> Jens Axboe is working on the per-bdi writeback patchset which will
> hopefull soon get rid of the pdflush threads in their current form.
> 
> Is it really a good idea to expose more details now or should we revert
> this patch before 2.6.30 is out?

Pained me as well when updating the patchset. I see little value in
these knobs as it is, I'm imagining that the submitter must have had a
use case where it made some difference?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
