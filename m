From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: swap prefetch improvements
Date: Sat, 12 May 2007 17:28:34 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705121516.00070.kernel@kolivas.org> <20070511225111.fee05bb9.pj@sgi.com>
In-Reply-To: <20070511225111.fee05bb9.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705121728.34987.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, mingo@elte.hu, ck@vds.kolivas.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 12 May 2007 15:51, Paul Jackson wrote:
> Con wrote:
> > Hmm I'm not really sure what it takes to make it cpuset aware;
> > ...
> > It is numa aware to some degree. It stores the node id and when it starts
> > prefetching it only prefetches to nodes that are suitable for prefetching
> > to ...
> > It would be absolutely trivial to add a check for 'number_of_cpusets' <=
> > 1 in  the prefetch_enabled() function. Would you like that?
>
> Hmmm ... it seems that we shadow boxing here ... trying to pick a solution
> to solve a problem when we aren't even sure we have a problem, much less
> what the problem is.
>
> That does not usually lead to the right path.
>
> Could you put some more effort into characterizing what problems
> can arise if one has prefetch and cpusets active at the same time?
>
> My first wild guess is that the only incompatibility would have been that
> prefetch might mess up NUMA placement (get pages on wrong nodes), which
> it seems you have tried to address in your current patches.  So it would
> not surprise me if there was no problem here.

Ummm this is what I've been saying for over a year now but noone has been 
listening.

> We may just have to lean on Nick some more, if he is the only one who
> understands what the problem is, to try again to explain it to us.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
