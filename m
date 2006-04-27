Message-ID: <44505FA6.70508@yahoo.com.au>
Date: Thu, 27 Apr 2006 16:07:34 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Lockless page cache test results
References: <4t153d$r2dpi@azsmga001.ch.intel.com>
In-Reply-To: <4t153d$r2dpi@azsmga001.ch.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Jens Axboe' <axboe@suse.de>, linux-kernel@vger.kernel.org, 'Nick Piggin' <npiggin@suse.de>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W wrote:
> Jens Axboe wrote on Wednesday, April 26, 2006 12:46 PM
> 
>>>It's interesting, single threaded performance is down a little. Is
>>>this significant? In some other results you showed me with 3 splices
>>>each running on their own file (ie. no tree_lock contention), lockless
>>>looked slightly faster on the same machine.
>>
>>I can do the same numbers on a 2-way em64t for comparison, that should
>>get us a little better coverage.
> 
> 
> 
> I throw the lockless patch and Jens splice-bench into our benchmark harness,
> here are the numbers I collected, on the following hardware:
> 
> (1) 2P Intel Xeon, 3.4 GHz/HT, 2M L2
> (2) 4P Intel Xeon, 3.0 GHz/HT, 8M L3
> (3) 4P Intel Xeon, 3.0 GHz/DC/HT, 2M L2 (per core)
> 
> Here are the graph:

Thanks a lot Ken.

So pagecache lookup performance goes up about 15-25% in single threaded
tests on your P4s. Phew, I wasn't dreaming it.

It is a pity that ipf hasn't improved similarly (and even slowed down a
bit, if Jens' numbers are significant to that range). Next time I spend
some cycles on lockless pagecache, I'll try to scrounge an ipf and see
if I can't improve it (I don't expect miracles).

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
