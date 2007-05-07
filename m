Message-ID: <463F37A8.1020009@tmr.com>
Date: Mon, 07 May 2007 10:28:56 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <463AE1EB.1020909@yahoo.com.au> <20070504085201.GA24666@elte.hu> <200705042210.15953.kernel@kolivas.org>
In-Reply-To: <200705042210.15953.kernel@kolivas.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Friday 04 May 2007 18:52, Ingo Molnar wrote:
>> agreed. Con, IIRC you wrote a testcase for this, right? Could you please
>> send us the results of that testing?
> 
> Yes, sorry it's a crappy test app but works on 32bit. Timed with prefetch 
> disabled and then enabled swap prefetch saves ~5 seconds on average hardware 
> on this one test case. I had many users try this and the results were between 
> 2 and 10 seconds, but always showed a saving on this testcase. This effect 
> easily occurs on printing a big picture, editing a large file, compressing an 
> iso image or whatever in real world workloads. Smaller, but much more 
> frequent effects of this over the course of a day obviously also occur and do 
> add up.
> 
I'll try this when I get the scheduler stuff done, and also dig out the 
"resp1" stuff for "back when." I see the most recent datasets were 
comparing 2.5.43-mm2 responsiveness with 2.4.19-ck7, you know I always 
test your stuff ;-)

Guess it might need a bit of polish for current hardware, I was testing 
on *small* machines, deliberately.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
