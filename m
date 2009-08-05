Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 550636B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 13:20:49 -0400 (EDT)
Message-ID: <4A79BF55.5090004@redhat.com>
Date: Wed, 05 Aug 2009 13:20:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <20090805155805.GC23385@random.random>
In-Reply-To: <20090805155805.GC23385@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Wed, Aug 05, 2009 at 10:40:58AM +0800, Wu Fengguang wrote:
>>  			 */
>> -			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
>> +			if ((vm_flags & VM_EXEC) || PageAnon(page)) {
>>  				list_add(&page->lru, &l_active);
>>  				continue;
>>  			}
>>
> 
> Please nuke the whole check and do an unconditional list_add;
> continue; there.

That would reinstate the bug that the VM has no pages
available for evicting.  There are very good reasons
that only VM_EXEC file pages get moved to the back of
the active list if they were referenced, and nothing
else.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
