Date: Mon, 16 Jan 2006 08:06:32 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: use-once-cleanup testing
In-Reply-To: <20060114005117.0540675e.akpm@osdl.org>
Message-ID: <Pine.LNX.4.63.0601160806020.10902@cuia.boston.redhat.com>
References: <20060114000533.GA4111@dmt.cnet> <43C883AA.30101@cyberone.com.au>
 <1137228276.20950.10.camel@twins> <20060114005117.0540675e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <peter@programming.kicks-ass.net>, piggin@cyberone.com.au, marcelo.tosatti@cyclades.com, linux-mm@kvack.org, bob.picco@hp.com, clameter@engr.sgi.com
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jan 2006, Andrew Morton wrote:

> Speedups should outweigh the slowdowns, no really bad corner cases.

When it comes to corner cases, clock-pro gets my vote over
any of the alternative algorithms.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
