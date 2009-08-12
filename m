Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C5ECF6B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 10:32:15 -0400 (EDT)
Message-ID: <4A82D24D.6020402@redhat.com>
Date: Wed, 12 Aug 2009 10:31:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090806100824.GO23385@random.random> <4A7AD5DF.7090801@redhat.com> <20090807121443.5BE5.A69D9226@jp.fujitsu.com> <20090812074820.GA29631@localhost>
In-Reply-To: <20090812074820.GA29631@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> On Fri, Aug 07, 2009 at 11:17:22AM +0800, KOSAKI Motohiro wrote:
>>> Andrea Arcangeli wrote:
>>>
>>>> Likely we need a cut-off point, if we detect it takes more than X
>>>> seconds to scan the whole active list, we start ignoring young bits,
>>> We could just make this depend on the calculated inactive_ratio,
>>> which depends on the size of the list.
>>>
>>> For small systems, it may make sense to make every accessed bit
>>> count, because the working set will often approach the size of
>>> memory.
>>>
>>> On very large systems, the working set may also approach the
>>> size of memory, but the inactive list only contains a small
>>> percentage of the pages, so there is enough space for everything.
>>>
>>> Say, if the inactive_ratio is 3 or less, make the accessed bit
>>> on the active lists count.
>> Sound reasonable.
> 
> Yes, such kind of global measurements would be much better.
> 
>> How do we confirm the idea correctness?
> 
> In general the active list tends to grow large on under-scanned LRU.
> I guess Rik is pretty familiar with typical inactive_ratio values of
> the large memory systems and may even have some real numbers :)
> 
>> Wu, your X focus switching benchmark is sufficient test?
> 
> It is a major test case for memory tight desktop.  Jeff presents
> another interesting one for KVM, hehe.
> 
> Anyway I collected the active/inactive list sizes, and the numbers
> show that the inactive_ratio is roughly 1 when the LRU is scanned
> actively and may go very high when it is under-scanned.

inactive_ratio is based on the zone (or cgroup) size.

For zones it is a fixed value, which is available in
/proc/zoneinfo

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
