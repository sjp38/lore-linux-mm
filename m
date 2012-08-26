Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 76C316B002B
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 10:41:03 -0400 (EDT)
Message-ID: <503A3565.2060004@redhat.com>
Date: Sun, 26 Aug 2012 10:40:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 0/5] make balloon pages movable by compaction
References: <cover.1345869378.git.aquini@redhat.com> <20120826075840.GE19551@redhat.com>
In-Reply-To: <20120826075840.GE19551@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 08/26/2012 03:58 AM, Michael S. Tsirkin wrote:
> On Sat, Aug 25, 2012 at 02:24:55AM -0300, Rafael Aquini wrote:
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
>
> Meta-question: are there any numbers showing gain from this patchset?
>
> The reason I ask, on migration we notify host about each page
> individually.  If this is rare maybe the patchset does not help much.
> If this is common we would be better off building up a list of multiple
> pages and passing them in one go.

The gain is in getting a better THP allocation rate inside the
guest, allowing applications to run faster.

The rarer it is for this code to run, the better - it means we
are getting the benefits without the overhead :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
