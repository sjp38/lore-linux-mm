Subject: Re: follow_page()
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <419353D5.2080902@yahoo.com.au>
References: <20041111024015.7c50c13d.akpm@osdl.org>
	 <1100170570.2646.27.camel@laptop.fenrus.org>
	 <20041111030634.1d06a7c1.akpm@osdl.org>
	 <1100171453.2646.29.camel@laptop.fenrus.org>
	 <419353D5.2080902@yahoo.com.au>
Content-Type: text/plain
Message-Id: <1100175387.4387.1.camel@laptop.fenrus.org>
Mime-Version: 1.0
Date: Thu, 11 Nov 2004 13:16:27 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > so in the race case you get the hit of those 4000 cycles... still optimizes the non-race case 
> > (so I'd agree that nothing should depend on this function dirtying it; it's a pre-dirty that's an
> > optimisation)
> > 
> 
> Only it doesn't mark the pte dirty, does it?

sounds like someone subsequently "optimized" it...
predirtying the pte is still worth it imo....
but when we do that we better put a big fat comment there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
