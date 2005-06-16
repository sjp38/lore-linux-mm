Message-ID: <42B0DA51.6060101@yahoo.com.au>
Date: Thu, 16 Jun 2005 11:48:01 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.12-rc6-mm1 & 2K lun testing
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com>	 <42B073C1.3010908@yahoo.com.au>	 <1118860223.4301.449.camel@dyn9047017072.beaverton.ibm.com>	 <42B07B44.9040408@yahoo.com.au> <1118868979.4301.458.camel@dyn9047017072.beaverton.ibm.com>
In-Reply-To: <1118868979.4301.458.camel@dyn9047017072.beaverton.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:
> On Wed, 2005-06-15 at 12:02, Nick Piggin wrote:
> 

>>Yeah, take off GFP_HIGH and set GFP_NOWARN (always). I would be
>>interested to see how that goes.
>>
>>Obviously it won't eliminate your failures there (it will probably
>>produce more of them), however it might help the scsi command
>>allocation from overwhelming the system.
> 
> 
> Hmm.. seems to help little. IO rate is not great (compared to 90MB/sec
> with "raw") - but machine is making progress. But again, its pretty
> unresponsive.
> 

Anything measurable that we can use to maybe get the chage
picked up and tested in -mm for a while?

> Thanks,
> Badari
> 
> procs -----------memory---------- ---swap-- -----io---- --system--
> ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy
> id wa
> 131 254  34896  31328   2540 4982740    0    0    29 101877 1086 11220 
> 0 100  0  0
> 149 268  34896  32824   2536 4983712   13    0    42 39505  439  4454  0
> 100  0  0
> 135 254  34896  31112   2536 4984768   11    0    20 36233  373  4078  0
> 100  0  0
> 130 242  34896  32600   2536 4987364    6    0   161 33626  377  3957  0
> 100  0  0
> 153 263  34896  32592   2532 4993560    0    0    14 37124  385  4468  0
> 100  0  0
> 144 236  34896  32668   2548 5013148    6    0   154 220366 2360 27530 
> 0 100  0  0

Though it can be difficult to judge performance based on vmstat
when you get these large spikes. vmstat is measuring requests
into the elevator so you see batching and throttling effects. I
would expect requests completing to be more even... your entire
vmstat listing looks like it is averaging about 60-70MB/s - does
this agree with your measurements?

Finally, do you see anything interesting on the profiles?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
