Message-ID: <405120FD.1030807@cyberone.com.au>
Date: Fri, 12 Mar 2004 13:31:25 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: blk_congestion_wait racy?
References: <OFF79FE9F7.73A1504E-ONC1256E54.006825BF-C1256E54.0068C4F9@de.ibm.com>
In-Reply-To: <OFF79FE9F7.73A1504E-ONC1256E54.006825BF-C1256E54.0068C4F9@de.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Martin Schwidefsky wrote:

>
>
>
>>Yes, sorry, all the world's an x86 :( Could you please send me whatever
>>diffs were needed to get it all going?
>>
>
>I am just preparing that mail :-)
>
>
>>I thought you were running a 256MB machine?  Two seconds for 400 megs of
>>swapout?  What's up?
>>
>
>Roughly 400 MB of swapout. And two seconds isn't that bad ;-)
>
>
>>An ouch-per-second sounds reasonable.  It could simply be that the CPUs
>>were off running other tasks - those timeout are less than scheduling
>>quanta.
>>
>
>I don't understand why an ouch-per-second is reasonable. The mempig is
>the only process that runs on the machine and the blk_congestion_wait
>uses HZ/10 as timeout value. I'd expect about 100 ouches for the 10
>seconds the test runs.
>
>The 4x performance difference remains not understood.
>
>

It would still be blk_congestion_wait slowing things down, wouldn't
it? Performance was good when you took that out, wasn't it?

And it would not unusual for you to be waiting needlessly without
seeing the ouch.

I think I will try doing a non-racy blk_congestion_wait after Jens'
unplugging patch gets put into -mm. That should solve your problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
