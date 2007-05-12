Date: Fri, 11 May 2007 22:51:11 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] mm: swap prefetch improvements
Message-Id: <20070511225111.fee05bb9.pj@sgi.com>
In-Reply-To: <200705121516.00070.kernel@kolivas.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<200705121446.04191.kernel@kolivas.org>
	<20070511220314.f7af1d31.pj@sgi.com>
	<200705121516.00070.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, mingo@elte.hu, ck@vds.kolivas.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con wrote:
> Hmm I'm not really sure what it takes to make it cpuset aware;
> ...
> It is numa aware to some degree. It stores the node id and when it starts 
> prefetching it only prefetches to nodes that are suitable for prefetching to 
> ...
> It would be absolutely trivial to add a check for 'number_of_cpusets' <= 1
> in  the prefetch_enabled() function. Would you like that?

Hmmm ... it seems that we shadow boxing here ... trying to pick a solution
to solve a problem when we aren't even sure we have a problem, much less
what the problem is.

That does not usually lead to the right path.

Could you put some more effort into characterizing what problems
can arise if one has prefetch and cpusets active at the same time?

My first wild guess is that the only incompatibility would have been that
prefetch might mess up NUMA placement (get pages on wrong nodes), which
it seems you have tried to address in your current patches.  So it would
not surprise me if there was no problem here.

We may just have to lean on Nick some more, if he is the only one who
understands what the problem is, to try again to explain it to us.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
