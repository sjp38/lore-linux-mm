Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECEC6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:51:31 -0400 (EDT)
Date: Tue, 20 Jul 2010 10:50:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16321] New: os unresponsive during buffered
 I/O
Message-Id: <20100720105052.e077be1c.akpm@linux-foundation.org>
In-Reply-To: <20100720150855.GA17832@infradead.org>
References: <bug-16321-10286@https.bugzilla.kernel.org/>
	<20100702160501.45861821.akpm@linux-foundation.org>
	<20100719211036.3cfa1727.akpm@linux-foundation.org>
	<20100720150855.GA17832@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jul 2010 11:08:55 -0400 Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Jul 19, 2010 at 09:10:36PM -0700, Andrew Morton wrote:
> > The reporter has updated the report, says "This bug is consistently
> > reproducible.".  But no signs of interest from kernel developers yet.
> 
> If only the reported can reproduce it that doesn't really help anyone.

Garbage.  We have a reporter who is prepared to work with us.  Has
anyone tried talking him through using the relevant tracepoints? 
Sending patches to add new ones if needed?

> And neither does hiding bugreports in bugzilla help when this could be
> discussed much more usefully on the list.

The guy's email address is right there.  And there are over forty more
people at https://bugzilla.kernel.org/show_bug.cgi?id=7372 seeing
similar (or other!) problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
