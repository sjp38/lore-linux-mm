Message-ID: <40C50269.4000808@yahoo.com.au>
Date: Tue, 08 Jun 2004 10:03:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: mmap() > phys mem problem
References: <Pine.LNX.4.44.0406070800380.29273-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0406070800380.29273-100000@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ron Maeder <rlm@orionmulti.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Mon, 7 Jun 2004, Nick Piggin wrote:
> 
> 
>>Well, no there isn't enough memory available: order 0 allocations
>>keep failing in the RX path (I assume each time the server retransmits)
>>and the machine is absolutely deadlocked.
> 
> 
> Yes, but did the memory get exhausted by the RX path itself,
> or by something else that's allocating the last system memory?
> 

I see what you mean. No I didn't dig that far although I
assume *most* of it would have been consumed by networking.

> If the memory exhaustion is because of something else, a
> mempool for the RX path might alleviate the situation.
> 
> 
>>>The theoretically perfect fix is to have a little mempool for
>>>every critical socket.  That is, every NFS mount, e/g/nbd block
>>>device, etc...
> 
> 
>>It would be cool if someone were able to come up with a formula
>>to capture that, and allow sockets to be marked as MEMALLOC to
>>enable mempool allocation.
> 
> 
> A per-socket mempool I guess.  At creation of a MEMALLOC
> socket you'd set up the mempool, and the same mempool
> would get destroyed when the socket is closed.
> 
> Then all memory allocations for that socket go via the
> mempool.
> 

That would be ideal, yes. I wonder how much work is involved.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
