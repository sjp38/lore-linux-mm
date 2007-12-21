Date: Fri, 21 Dec 2007 09:17:53 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
Message-ID: <20071221091753.15a18935@bree.surriel.com>
In-Reply-To: <200712212152.19260.nickpiggin@yahoo.com.au>
References: <20071218211539.250334036@redhat.com>
	<1198080267.5333.22.camel@localhost>
	<20071220155627.6872b0e6@bree.surriel.com>
	<200712212152.19260.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Dec 2007 21:52:19 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> BTW. if you have any workloads that are limited by page reclaim,
> especially unmapped file backed pagecache reclaim, then I have some
> stright-line-speedup patches which you might find interesting (I can
> send them if you'd like to test).

I am definately interested in those.

The current upstream VM seems to be fairly good in steady state,
with the largest problems happening when the system switches states
(eg. from reclaiming page cache to swapping), but any speedups in
the steady state are good too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
