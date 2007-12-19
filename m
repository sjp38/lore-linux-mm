Date: Wed, 19 Dec 2007 09:53:07 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
Message-ID: <20071219095307.683978b0@cuia.boston.redhat.com>
In-Reply-To: <1198074247.6484.17.camel@twins>
References: <20071218211539.250334036@redhat.com>
	<20071218211550.186819416@redhat.com>
	<200712191156.48507.nickpiggin@yahoo.com.au>
	<20071219084534.4fee8718@bree.surriel.com>
	<1198074247.6484.17.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Dec 2007 15:24:07 +0100
Peter Zijlstra <peterz@infradead.org> wrote:

> I thought Lee had patches that moved pages with long rmap chains (both
> anon and file) out onto the non-reclaim list, for those a slow
> background scan does make sense.

I suspect we won't be needing that code.  The SEQ replacement for
swap backed pages might reduce the number of pages that need to
be scanned to a reasonable number.

Remember, steady states are not a big problem with the current VM.
It's the sudden burst of scanning that happens when the VM decides
that it should start swapping (and every anonymous page is referenced)
that kills large systems.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
