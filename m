Message-ID: <469470A3.5040606@yahoo.com.au>
Date: Wed, 11 Jul 2007 15:54:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com>	 <20070710181419.6d1b2f7e.akpm@linux-foundation.org>	 <b21f8390707101954s3ae69db8vc30287277941cb1f@mail.gmail.com>	 <4694683B.3060705@yahoo.com.au> <2c0942db0707102247n3b6e5933i9803a2161d6c00b1@mail.gmail.com>
In-Reply-To: <2c0942db0707102247n3b6e5933i9803a2161d6c00b1@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Matthew Hawkins <darthmdh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ray Lee wrote:
> On 7/10/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> Matthew Hawkins wrote:
>> > On 7/11/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>> > Anyhow with swap prefetch, applications that may have been sitting
>> > there idle for a while become responsive in the single-digit seconds
>> > rather than double-digit or worse.  The same goes for a morning wakeup
>> > (ie after nightly cron jobs throw things out)
>>
>> OK that's a good data point. It would be really good to be able to
>> do an analysis on your overnight IO patterns and the corresponding
>> memory reclaim behaviour and see why things are getting evicted.
> 
> 
> Eviction can happen for multiple reasons, as I'm sure you're painfully
> aware. It can happen because of poor balancing choices, or it can

s/balancing/reclaim, yes. And for the nightly cron job case, this is
could quite possibly be the cause. At least updatedb should be fairly
easy to apply use-once heuristics for, so if they're not working then
we should hopefully be able to improve it.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
