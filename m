Date: Thu, 17 Jul 2008 10:21:48 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: madvise(2) MADV_SEQUENTIAL behavior
Message-ID: <20080717102148.6bc52e94@cuia.bos.redhat.com>
In-Reply-To: <200807171614.29594.nickpiggin@yahoo.com.au>
References: <1216163022.3443.156.camel@zenigma>
	<487E628A.3050207@redhat.com>
	<1216252910.3443.247.camel@zenigma>
	<200807171614.29594.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Eric Rannaud <eric.rannaud@gmail.com>, Chris Snook <csnook@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jul 2008 16:14:29 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > It might encourage user space applications to start using
> > FADV_SEQUENTIAL or FADV_NOREUSE more often (as it would become
> > worthwhile to do so), and if they do (especially cron jobs), the problem
> > of the slow desktop in the morning would progressively solve itself.
> 
> The slow desktop in the morning should not happen even without such a
> call, because the kernel should not throw out frequently used data (even
> if it is not quite so recent) in favour of streaming data.
> 
> OK, I figure it doesn't do such a good job now, which is sad, 

Do you have any tests in mind that we could use to decide
whether the patch I posted Tuesday would do a decent job
at protecting frequently used data from streaming data?

http://lkml.org/lkml/2008/7/15/465

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
