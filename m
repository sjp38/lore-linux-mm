Message-ID: <4603504A.1000805@yahoo.com.au>
Date: Fri, 23 Mar 2007 14:58:02 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Subject: [PATCH RESEND 1/1] cpusets/sched_domain reconciliation
References: <20070322231559.GA22656@sgi.com>	<46033311.1000101@yahoo.com.au> <20070322204720.cd3a51c9.pj@sgi.com>
In-Reply-To: <20070322204720.cd3a51c9.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: cpw@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Nick wrote:
> 
>>My suggestion was
>>something like that if cpus_exclusive is set, then no other sets
>>except descendants and ancestors could have overlapping cpus.
> 
> 
> That sure sounds right ... did I say different at some point?
> 

... I can't really remember, probably not. I just remember not
quite understanding what was going on when this last came up ;)

Ah, I think the issue was this: if cpus_exclusive is set in a
child, then you still wanted correct balancing over all CPUs in
the parent set. Thus we can never partition the system, because
you always come back to the root set which covers everything, and
that would be incompatible with any sched domains partitions.

What I *didn't* understand, was why we have any sched-domains
code in cpusets at all, if it is incorrect according to the above
definition (I think you vetoed my subsequent patch to remove it).

All that aside, I think we can probably do without cpus_exclusive
entirely (for sched-domains), and automatically detect a correct
set of partitions. I remember leaving that as an exercise for the
reader ;) but I think I've got some renewed energy, so I might
try tackling it.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
