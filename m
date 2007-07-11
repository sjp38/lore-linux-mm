Message-ID: <4694683B.3060705@yahoo.com.au>
Date: Wed, 11 Jul 2007 15:18:51 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com>	 <20070710181419.6d1b2f7e.akpm@linux-foundation.org> <b21f8390707101954s3ae69db8vc30287277941cb1f@mail.gmail.com>
In-Reply-To: <b21f8390707101954s3ae69db8vc30287277941cb1f@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Matthew Hawkins wrote:
> On 7/11/07, Andrew Morton <akpm@linux-foundation.org> wrote:

> Anyhow with swap prefetch, applications that may have been sitting
> there idle for a while become responsive in the single-digit seconds
> rather than double-digit or worse.  The same goes for a morning wakeup
> (ie after nightly cron jobs throw things out)

OK that's a good data point. It would be really good to be able to
do an analysis on your overnight IO patterns and the corresponding
memory reclaim behaviour and see why things are getting evicted.

Not that swap prefetching isn't a good solution for this situation,
but the fact that things are getting swapped out for you also means
that mapped files and possibly important pagecache and dentries are
being flushed out, which we might be able to avoid.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
