Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA1C6006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 13:35:35 -0400 (EDT)
Date: Thu, 8 Jul 2010 13:35:15 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Add trace event for munmap
Message-ID: <20100708173515.GA11652@infradead.org>
References: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
 <1278598955.1900.152.camel@laptop>
 <20100708144407.GA8141@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100708144407.GA8141@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Eric B Munson <emunson@mgebm.net>, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, anton@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 08, 2010 at 03:44:07PM +0100, Eric B Munson wrote:
> On Thu, 08 Jul 2010, Peter Zijlstra wrote:
> 
> > On Thu, 2010-07-08 at 15:05 +0100, Eric B Munson wrote:
> > > This patch adds a trace event for munmap which will record the starting
> > > address of the unmapped area and the length of the umapped area.  This
> > > event will be used for modeling memory usage.
> > 
> > Does it make sense to couple this with a mmap()/mremap()/brk()
> > tracepoint?
> > 
> 
> We were using the mmap information collected by perf, but I think
> those might also be useful so I will send a followup patch to add
> them.

What kind of infrastructure is perf using for recording
mmap()/mremap()/brk() information?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
