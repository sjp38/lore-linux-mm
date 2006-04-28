Date: Fri, 28 Apr 2006 15:16:38 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2 (repost)] mm: serialize OOM kill operations
Message-Id: <20060428151638.32ca188e.akpm@osdl.org>
In-Reply-To: <200604281459.27895.dsp@llnl.gov>
References: <200604271308.10080.dsp@llnl.gov>
	<20060427155613.15d565b1.akpm@osdl.org>
	<200604281459.27895.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com, nickpiggin@yahoo.com.au, ak@suse.de, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Dave Peterson <dsp@llnl.gov> wrote:
>
> Yes I am familiar with this sort of problem.  :-)

Andrea has long advocated that the memory allocator shouldn't infinitely
loop for small __GFP_WAIT allocations.  ie: ultimately we should return
NULL back to the caller.

Usually this will cause the correct process to exit.  Sometimes it won't.

Did you try it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
