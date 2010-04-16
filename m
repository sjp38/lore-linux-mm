Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E57F46B01E3
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 10:11:11 -0400 (EDT)
Subject: Re: vmalloc performance
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1271350270.2013.29.camel@barrios-desktop>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <m2g28c262361004140813j5d70a80fy1882d01436d136a6@mail.gmail.com>
	 <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
Content-Type: text/plain
Date: Fri, 16 Apr 2010 15:10:56 +0100
Message-Id: <1271427056.7196.163.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 2010-04-16 at 01:51 +0900, Minchan Kim wrote:
[snip]
> Thanks for the explanation. It seems to be real issue. 
> 
> I tested to see effect with flush during rb tree search.
> 
> Before I applied your patch, the time is 50300661 us. 
> After your patch, 11569357 us. 
> After my debug patch, 6104875 us.
> 
> I tested it as changing threshold value.
> 
> threshold	time
> 1000		13892809
> 500		9062110
> 200		6714172
> 100		6104875
> 50		6758316
> 
My results show:

threshold        time
100000           139309948
1000             13555878
500              10069801
200              7813667
100              18523172
50               18546256

> And perf shows smp_call_function is very low percentage.
> 
> In my cases, 100 is best. 
> 
Looks like 200 for me.

I think you meant to use the non _minmax version of proc_dointvec too?
Although it doesn't make any difference for this basic test.

The original reporter also has 8 cpu cores I've discovered. In his case
divided by 4 cpus where as mine are divided by 2 cpus, but I think that
makes no real difference in this case.

I'll try and get some further test results ready shortly. Many thanks
for all your efforts in tracking this down,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
