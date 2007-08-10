Message-ID: <46BBE6D9.1080904@tmr.com>
Date: Fri, 10 Aug 2007 00:17:29 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>	<1186575947.3106.23.camel@castor.rsk.org> <p734pjarv20.fsf@bingen.suse.de>
In-Reply-To: <p734pjarv20.fsf@bingen.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: richard kennedy <richard@rsk.demon.co.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> richard kennedy <richard@rsk.demon.co.uk> writes:
>> This is on a standard desktop machine so there are lots of other
>> processes running on it, and although there is a degree of variability
>> in the numbers,they are very repeatable and your patch always out
>> performs the stock mm2.
>> looks good to me
> 
> iirc the goal of this is less to get better performance, but to avoid long user visible
> latencies.  Of course if it's faster it's great too, but that's only secondary.
> 
What a trade-off, if you want to get rid of long latency you have to 
live with better throughput. I can live with that. ;-)

Your point well taken, not the intent of the patch, but it may indicate 
where a performance bottleneck happens as well.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
