Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 430C26B0078
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 14:26:50 -0400 (EDT)
Message-ID: <501039F6.7010702@redhat.com>
Date: Wed, 25 Jul 2012 14:24:54 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] remove __GFP_NO_KSWAPD
References: <20120724111222.2c5e6b30@annuminas.surriel.com> <20120724233422.GB14411@bbox>
In-Reply-To: <20120724233422.GB14411@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On 07/24/2012 07:34 PM, Minchan Kim wrote:
> Hi Rik,
>
> On Tue, Jul 24, 2012 at 11:12:22AM -0400, Rik van Riel wrote:
>> When transparent huge pages were introduced, memory compaction and
>> swap storms were an issue, and the kernel had to be careful to not
>> make THP allocations cause pageout or compaction.
>>
>> Now that we have working compaction deferral, kswapd is smart enough
>> to invoke compaction and the quadratic behaviour around isolate_free_pages
>> has been fixed, it should be safe to remove __GFP_NO_KSWAPD.
>
> Could you point out specific patches you mentiond which makes kswapd/compaction
> smart? It will make description very clear.

That could be a list of 50+ patches, merged over the
last two or so years.

In other words, such a large amount of data that it
is unlikely to clarify the discussion...

>> Signed-off-by: Rik van Riel <riel@redhat.com>
>
> I support it because I had a concern about that flags which is likely to be
> used by other subsystems without careful thinking when the flag was introduced.
> It's proved by mtd_kmalloc_up_to which was merged with sneaking without catching
> from mm guys's eyes. When I read comment of that function, it seems to be proper
> usage but I don't like it because it requries users of mm to know mm internal
> like kswapd. So it should be avoided if possible.
>
> Plus, it means you need to fix it with show_gfp_flags. :)

Ohh, a place I forgot to grep!

I'll send in an incremental patch right now.

>> ---
>> This has been running fine on my system for a while, but my system
>> only has 12GB and moderate memory pressure. I propose we keep this
>> in -mm and -next for a while, and merge it for 3.7 if nobody complains.
>
> Yes. it should be very careful.
> I guess Mel and Andrea would have opinions and benchmark.

It's not as much benchmarks that I am worried about,
but somebody running something unexpected on their
system.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
