Subject: Re: use-once-cleanup testing
From: Peter Zijlstra <peter@programming.kicks-ass.net>
In-Reply-To: <43C883AA.30101@cyberone.com.au>
References: <20060114000533.GA4111@dmt.cnet>
	 <43C883AA.30101@cyberone.com.au>
Content-Type: text/plain
Date: Sat, 14 Jan 2006 09:44:36 +0100
Message-Id: <1137228276.20950.10.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, akpm@osdl.org, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2006-01-14 at 15:52 +1100, Nick Piggin wrote:

> Unfortunately I don't think Andrew wants a bar of any of it. Nor would
> a crazy rewrite-pagereclaim tree really get any sort of testing at all,
> realistically :(
> 

Both HP and SGI have shown interrest in getting these patches in shape
and testing them, so I do think there is quite some interrest in them.

I admit that there is still a lot of work to do, like getting the CART
policies into the new tree and NUMAfying the CLOCK-Pro and CART
policies. And ofcourse rigourous testing.

Andrew, what would you need on top of that to start being interrested?

Kind regards,

PeterZ

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
