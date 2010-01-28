Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CE1346001DA
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 13:07:56 -0500 (EST)
Date: Thu, 28 Jan 2010 18:07:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 25 of 31] transparent hugepage core
Message-ID: <20100128180742.GG7139@csn.ul.ie>
References: <patchbomb.1264689194@v2.random> <ac9bbf9e2c95840eb237.1264689219@v2.random> <20100128175753.GF7139@csn.ul.ie> <4B61D1E6.6020507@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4B61D1E6.6020507@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 01:05:26PM -0500, Rik van Riel wrote:
> On 01/28/2010 12:57 PM, Mel Gorman wrote:
>> Sorry for the long delay getting to this patch. I ran out of beans the
>> first time around. Unlike Rik, I can't handle 31 patches in one sitting.
>>
>> On Thu, Jan 28, 2010 at 03:33:39PM +0100, Andrea Arcangeli wrote:
>>> From: Andrea Arcangeli<aarcange@redhat.com>
>>>
>>> Lately I've been working to make KVM use hugepages transparently
>>> without the usual restrictions of hugetlbfs. Some of the restrictions
>>> I'd like to see removed:
>>>
>>> 1) hugepages have to be swappable or the guest physical memory remains
>>>     locked in RAM and can't be paged out to swap
>>>
>>
>> It occurs to me that this infrastructure should be reusable to make allow
>> optional swapping of hugetlbfs. I haven't investigated the possibility properly
>> but it should be doable as a mount option with maybe a boot-parameter for
>> shared memory.
>
> I agree that would be nice.  However, as you noticed above this
> patch set is quite large already.  Merging the infrastructure from
> hugetlb and the anonymous hugepages is probably better done in a
> follow up patch series, since the two are pretty different beasts
> at this point.
>

Fully agreed on all counts.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
