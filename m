Message-ID: <3EEBF2C1.4050101@cyberone.com.au>
Date: Sun, 15 Jun 2003 14:14:57 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.70-mm9
References: <20030613013337.1a6789d9.akpm@digeo.com>	<3EEAD41B.2090709@us.ibm.com>  <20030614010139.2f0f1348.akpm@digeo.com> <1055637690.1396.15.camel@w-ming2.beaverton.ibm.com>
In-Reply-To: <1055637690.1396.15.camel@w-ming2.beaverton.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mingming Cao <cmm@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Mingming Cao wrote:

>On Sat, 2003-06-14 at 01:01, Andrew Morton wrote:
>
>
>>Was elevator=deadline observed to fail in earlier kernels?  If not then it
>>may be an anticipatory scheduler bug.  It certainly had all the appearances
>>of that.
>>
>Yes, with elevator=deadline the many fsx tests failed on 2.5.70-mm5.
> 
>
>>So once you're really sure that elevator=deadline isn't going to fail,
>>could you please test elevator=as?
>>
>>
>Ok, the deadline test was run for 10 hours then I stopped it (for the
>elevator=as test).  
>
>But the test on elevator=as (2.5.70-mm9 kernel) still failed, same
>problem.  Some fsx tests are sleeping on io_schedule().  
>

So by failed, you just mean stuck in io_schedule? Are you sure
they are permanently stuck there? Is any progress being made?
I have tried this test, and often some or most of the processes
wait in io_schedule for a while, but do get woken.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
