Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DE0E26B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 13:43:02 -0400 (EDT)
Message-ID: <4A79C486.1010809@redhat.com>
Date: Wed, 05 Aug 2009 13:42:30 -0400
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

<riel> aa: so you're saying we should _never_ add pages to the active 
list at this point in the code
<aa> right
<riel> aa: and remove the list_add and continue completely
<aa> yes
<riel> aa: your email says the opposite :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
