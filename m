Message-ID: <433DF76C.9010400@tmr.com>
Date: Fri, 30 Sep 2005 22:41:48 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] CART - an advanced page replacement policy
References: <20050929180845.910895444@twins>  <433C4343.20205@tmr.com> <1128093992.14695.22.camel@twins>
In-Reply-To: <1128093992.14695.22.camel@twins>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Paul.McKenney@us.ibm.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

>On Thu, 2005-09-29 at 15:40 -0400, Bill Davidsen wrote:
>  
>
>>Peter Zijlstra wrote:
>>    
>>
>>>Multiple memory zone CART implementation for Linux.
>>>An advanced page replacement policy.
>>>
>>>http://www.almaden.ibm.com/cs/people/dmodha/clockfast.pdf
>>>(IBM does hold patent rights to the base algorithm ARC)
>>>      
>>>
>>Peter, this is a large patch, perhaps you could describe what configs 
>>benefit, 
>>    
>>
>
>All those that use swap. Those that exploit the weak side of LRU more
>than others.
>
>CART is an adaptive algorithm that will act like LFU on one side and LRU
>on the other, capturing both behaviours. Therefore it is also scan
>proof, eg. 'use once' scans should not flush the full cache.
>
>Hence people with LFU friendly applications will see an improvement
>while those who have an LRU friendly application should see no decrease
>in swap performance.
>
>Non of the algorithms handle cyclic access very well, that is what patch
>5 tries to tackle.
>
>  
>
>>how much, 
>>    
>>
>
>In the cyclic case (n+a: a << n) I've seen speedups of over 300%. Other
>cases much less. However I've yet to encounter a case where it gives
>worse performance.
>
>I'm still constructing some corner case tests to give more hard numbers.
>
>  
>
>>and what the right to use status of the patent might 
>>be. 
>>    
>>
>
>AFAIK IBM allows Linux implementation of their patents.
>See: http://news.com.com/IBM+pledges+no+patent+attacks+against+Linux/2100-7344_3-5296787.html
>
>  
>
>>In other words, why would a reader of LKML put in this patch and try it?
>>The description of how it works is clear, but the problem solved isn't.
>>    
>>
>
>I hope to have answered these questions. If any questions still remain,
>please let me know.
>

Thanks, you have cleared up all of the issues which I felt were unclear.

-- 
bill davidsen <davidsen@tmr.com>
  CTO TMR Associates, Inc
  Doing interesting things with small computers since 1979

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
