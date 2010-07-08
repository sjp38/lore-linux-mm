Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED106006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 13:52:00 -0400 (EDT)
Date: Thu, 8 Jul 2010 13:51:48 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Add trace event for munmap
Message-ID: <20100708175147.GA17525@infradead.org>
References: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
 <1278598955.1900.152.camel@laptop>
 <20100708144407.GA8141@us.ibm.com>
 <20100708173515.GA11652@infradead.org>
 <1278611288.1900.164.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278611288.1900.164.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, Eric B Munson <ebmunson@us.ibm.com>, Eric B Munson <emunson@mgebm.net>, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, anton@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 08, 2010 at 07:48:08PM +0200, Peter Zijlstra wrote:
> On Thu, 2010-07-08 at 13:35 -0400, Christoph Hellwig wrote:
> 
> > What kind of infrastructure is perf using for recording
> > mmap()/mremap()/brk() information?
> 
> A direct hook into mmap_region(), see perf_event_mmap().
> 
> We used to only track VM_EXEC regions, but these days we can also track
> data regions (although it wouldn't track mremap and brk I think).
> 
> We need the VM_EXEC maps to make sense of the instruction pointer
> samples.
> 
> Eric recently added support for !VM_EXEC mmap() in order to interpret
> linear addresses provided by things like the software pagefault events
> and certain powerpc hardware events.

Maybe the user reporting should use trace points everywhere, leaving
the direct hook just for the executable tracking?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
