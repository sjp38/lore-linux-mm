Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2AAAC6B0246
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 19:56:05 -0400 (EDT)
Date: Wed, 7 Jul 2010 16:55:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: what is the point of nr_pages information for the flusher
 thread?
Message-Id: <20100707165554.8b898a40.akpm@linux-foundation.org>
In-Reply-To: <20100707234316.GA21990@infradead.org>
References: <20100707231611.GA24281@infradead.org>
	<20100707163710.a46173b2.akpm@linux-foundation.org>
	<20100707234316.GA21990@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: fengguang.wu@intel.com, mel@csn.ul.ie, npiggin@suse.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jul 2010 19:43:16 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> > There's also free_more_memory() and do_try_to_free_pages().
> 
> Indeed.  So we still have some special cases that want a specific
> number to be written back globally.

It could be that those two callsites can be changed to NotDoThat.  I do
suggest that you dig through the git record and perhaps the email
archives to work out the thinking - that's old code.

Perhaps we could change things to write back down to the dirty limits,
but that might cause subtle breakage in low-memory situations where
dirty memory is uneven between zones, dunno.

Writing back the whole world would surely be a safe substitute, but
might be inefficient.

I doubt if a whole lot of rigourous thinking went into either one...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
