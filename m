Message-ID: <41935AB9.7000101@yahoo.com.au>
Date: Thu, 11 Nov 2004 23:27:37 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: follow_page()
References: <20041111024015.7c50c13d.akpm@osdl.org>	 <1100170570.2646.27.camel@laptop.fenrus.org>	 <20041111030634.1d06a7c1.akpm@osdl.org>	 <1100171453.2646.29.camel@laptop.fenrus.org>	 <419353D5.2080902@yahoo.com.au> <1100175387.4387.1.camel@laptop.fenrus.org>
In-Reply-To: <1100175387.4387.1.camel@laptop.fenrus.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Arjan van de Ven wrote:
>>>so in the race case you get the hit of those 4000 cycles... still optimizes the non-race case 
>>>(so I'd agree that nothing should depend on this function dirtying it; it's a pre-dirty that's an
>>>optimisation)
>>>
>>
>>Only it doesn't mark the pte dirty, does it?
> 
> 
> sounds like someone subsequently "optimized" it...
> predirtying the pte is still worth it imo....
> but when we do that we better put a big fat comment there.
> 

Well, if you write into the page returned via follow_page, that
isn't going to dirty the pte by itself... so it is a bit of a
hit and miss regarding whether the page really will get dirtied
through that pte in the near future (I don't know, maybe that
is generally what happens with normal usage patterns?).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
