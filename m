Message-ID: <42A10ED2.7020205@yahoo.com.au>
Date: Sat, 04 Jun 2005 12:15:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <E1DeNiA-0008Ap-00@gondolin.me.apana.org.au>
In-Reply-To: <E1DeNiA-0008Ap-00@gondolin.me.apana.org.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: mbligh@mbligh.org, davem@davemloft.net, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Herbert Xu wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>network code. If the latter, that would suggest at least in theory
>>it could use noncongiguous physical pages.
> 
> 
> With Dave's latest super-TSO patch, TCP over loopback will only be
> doing order-0 allocations in the common case.  UDP and others may
> still do large allocations but that logic is all localised in
> ip_append_data.
> 
> So if we wanted we could easily remove most large allocations over
> the loopback device.

I would be very interested to look into that. I would be
willing to do benchmarks on a range of machines too if
that would be of any use to you.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
