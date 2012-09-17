Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 832BD6B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 18:45:52 -0400 (EDT)
Message-ID: <5057A80C.3050800@redhat.com>
Date: Mon, 17 Sep 2012 18:45:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 0/5] make balloon pages movable by compaction
References: <cover.1347897793.git.aquini@redhat.com> <20120917151531.e9ac59f2.akpm@linux-foundation.org>
In-Reply-To: <20120917151531.e9ac59f2.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 09/17/2012 06:15 PM, Andrew Morton wrote:
> On Mon, 17 Sep 2012 13:38:15 -0300
> Rafael Aquini <aquini@redhat.com> wrote:
>
>> Memory fragmentation introduced by ballooning might reduce significantly
>> the number of 2MB contiguous memory blocks that can be used within a guest,
>> thus imposing performance penalties associated with the reduced number of
>> transparent huge pages that could be used by the guest workload.
>>
>> This patch-set follows the main idea discussed at 2012 LSFMMS session:
>> "Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/
>> to introduce the required changes to the virtio_balloon driver, as well as
>> the changes to the core compaction & migration bits, in order to make those
>> subsystems aware of ballooned pages and allow memory balloon pages become
>> movable within a guest, thus avoiding the aforementioned fragmentation issue
>>
>> Following are numbers that prove this patch benefits on allowing compaction
>> to be more effective at memory ballooned guests.
>>
>> Results for STRESS-HIGHALLOC benchmark, from Mel Gorman's mmtests suite,
>> running on a 4gB RAM KVM guest which was ballooning 1gB RAM in 256mB chunks,
>> at every minute (inflating/deflating), while test was running:
>
> How can a patchset reach v10 and have zero Reviewed-by's?

Because people kept finding issues and nitpicks in patch 1/5,
which kept people from putting their Reviewed-by's on the other
patches :)

> (The question of "overall desirability" is the big one here.  Do we
> actually want to add this to Linux?  The rest is details which we can
> work out).

I believe we absolutely want this, to increase the likelyhood
of being able to use THP in KVM guests, which is exactly
where THP gives the largest performance benefit.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
