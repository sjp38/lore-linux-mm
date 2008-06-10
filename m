Date: Tue, 10 Jun 2008 02:15:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.26-rc5-mm2
Message-Id: <20080610021519.52af66f5.akpm@linux-foundation.org>
In-Reply-To: <200806101848.22237.nickpiggin@yahoo.com.au>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
	<200806101728.27486.nickpiggin@yahoo.com.au>
	<20080610013427.aa20a29b.akpm@linux-foundation.org>
	<200806101848.22237.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 18:48:21 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Is the plan to merge all reclaim changes in a big hit, rather than
> slowly trickle in the different independent changes?

It's going to take a lot of work to get such extensive reclaim changes
landed.

We need to convince ourselves that these changes are the right way to
fix <whatever they fix>.  We need to review and test the crap out of
them.  The 64-bit-only thing is a concern.  I wonder about whether
we've "fixed" anon pages but didn't do anything about file-backed
mapped pages.  Plus all the other stuff, plus stuff we haven't thought
of yet.

It's huge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
