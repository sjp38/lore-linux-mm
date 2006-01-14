Date: Sat, 14 Jan 2006 00:51:17 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: use-once-cleanup testing
Message-Id: <20060114005117.0540675e.akpm@osdl.org>
In-Reply-To: <1137228276.20950.10.camel@twins>
References: <20060114000533.GA4111@dmt.cnet>
	<43C883AA.30101@cyberone.com.au>
	<1137228276.20950.10.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peter@programming.kicks-ass.net>
Cc: piggin@cyberone.com.au, marcelo.tosatti@cyclades.com, riel@redhat.com, linux-mm@kvack.org, bob.picco@hp.com, clameter@engr.sgi.com
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <peter@programming.kicks-ass.net> wrote:
>
> Andrew, what would you need on top of that to start being interrested?
>

A demonstration that the code will make sufficient improvement to justify
its inclusion, naturally ;)

Speedups should outweigh the slowdowns, no really bad corner cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
