Date: Thu, 12 Jun 2008 15:29:05 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: 2.6.26-rc5-mm2
Message-ID: <20080612152905.6cb294ae@cuia.bos.redhat.com>
In-Reply-To: <200806120958.38545.nickpiggin@yahoo.com.au>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
	<200806101848.22237.nickpiggin@yahoo.com.au>
	<20080611140902.544e59ec@bree.surriel.com>
	<200806120958.38545.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 09:58:38 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > Does loopback over tmpfs use a different allocation path?
> 
> I'm sorry, hmm I didn't look closely enough and forgot that
> write_begin/write_end requires the callee to allocate the page
> as well, and that Hugh had nicely unified most of that.
> 
> So maybe it's not that. It's pretty easy to hit I found with
> ext2 mounted over loopback on a tmpfs file.

Turns out the loopback driver uses splice, which moves
the pages from one place to another.  This is why you
were seeing the problem with loopback, but not with
just a really big file on tmpfs.

I'm trying to make sense of all the splice code now
and will send fix as soon as I know how to fix this
problem in a nice way.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
