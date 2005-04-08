Message-ID: <4255D343.2090006@yahoo.com.au>
Date: Fri, 08 Apr 2005 10:41:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: per_cpu_pagesets degrades MPI performance
References: <20050404192827.GA15142@sgi.com> <4251DE87.10002@yahoo.com.au> <20050407185226.GA23873@sgi.com>
In-Reply-To: <20050407185226.GA23873@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: akpm@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jack Steiner wrote:

> 
> Good idea. For the specific benchmark that I was running, batch sizes
> of 0 (pcp disabled), 1, 3, 5, 7, 9, 10, 11, 13 & 15 all produced good results. 
> Batch sizes of 2, 4 and 8 produced horrible results.
> 

Phew, I hope we won't have to make this a CONFIG_ option!


> Surprisingly 7 was not quite as good as the other good values but I attribute that
> to an anomaly of the reference pattern of the specific benchmark.
> 
> Even more suprising (again an anomaly I think) was that a size of 13 ran
> 10% faster than any of the other sizes. I reproduced this data point several
> times - it is real.
> 

Hmm. Yeah, sounds you are getting close to some "resonance" behaviour -
were 7 and 13 are close to a multiple or divisor of some application
or cache property.

> Our next step to to run the full benchmark suite. That should happen
> within 2 weeks.
> 
> Tentatively, I'm planning to post a patch to change the batch size to 
> 2**n-1 but I'll wait for the results of the full benchmark.
> 

Cool. I would consider (maybe you are) posting the patch ASAP, so you
can get a wider range of testers, and Andrew can possibly put it in
-mm. Just to get things happening in parallel.

> I also want to finish understanding the issue of excessive memory
> being trapped in the per_cpu lists.
> 

Nutty problem, that, on a 256 node, 512 CPU system :(

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
