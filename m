Date: Thu, 7 Apr 2005 13:52:27 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: per_cpu_pagesets degrades MPI performance
Message-ID: <20050407185226.GA23873@sgi.com>
References: <20050404192827.GA15142@sgi.com> <4251DE87.10002@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4251DE87.10002@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 05, 2005 at 10:40:39AM +1000, Nick Piggin wrote:
> Jack Steiner wrote:
> 
> [snip nice detective work]
> 
> >Has anyone else seen this problem? I am considering adding
> >a config option to allow a site to control the batch size
> >used for per_cpu_pagesets. Are there other ideas that should 
> >be pursued? 
> >
> 
> What about using a non power of 2 for the batch? Like 5.
> If that helps, then we can make a patch to clamp it to a
> good value. At a guess I'd say a power of 2 +/- 1 might be
> the way to go.
> 
> Nick
> 
> -- 
> SUSE Labs, Novell Inc.

Good idea. For the specific benchmark that I was running, batch sizes
of 0 (pcp disabled), 1, 3, 5, 7, 9, 10, 11, 13 & 15 all produced good results. 
Batch sizes of 2, 4 and 8 produced horrible results.

Surprisingly 7 was not quite as good as the other good values but I attribute that
to an anomaly of the reference pattern of the specific benchmark.

Even more suprising (again an anomaly I think) was that a size of 13 ran
10% faster than any of the other sizes. I reproduced this data point several
times - it is real.

Our next step to to run the full benchmark suite. That should happen
within 2 weeks.

Tentatively, I'm planning to post a patch to change the batch size to 
2**n-1 but I'll wait for the results of the full benchmark.

I also want to finish understanding the issue of excessive memory
being trapped in the per_cpu lists.

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
