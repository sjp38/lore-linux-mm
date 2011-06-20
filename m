Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5D0CB9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:25:12 -0400 (EDT)
Message-ID: <4DFF8271.20301@redhat.com>
Date: Tue, 21 Jun 2011 01:25:05 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: print information when THP is disabled automatically
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <1308587683-2555-3-git-send-email-amwang@redhat.com> <20110620165425.GF20843@redhat.com>
In-Reply-To: <20110620165425.GF20843@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 00:54, Andrea Arcangeli a??e??:
> On Tue, Jun 21, 2011 at 12:34:30AM +0800, Amerigo Wang wrote:
>> Print information when THP is disabled automatically so that
>> users can find this info in dmesg.
>>
>> Signed-off-by: WANG Cong<amwang@redhat.com>
>> ---
>>   mm/huge_memory.c |    5 ++++-
>>   1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 7fb44cc..07679da 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -544,8 +544,11 @@ static int __init hugepage_init(void)
>>   	 * where the extra memory used could hurt more than TLB overhead
>>   	 * is likely to save.  The admin can still enable it through /sys.
>>   	 */
>> -	if (totalram_pages<  (CONFIG_TRANSPARENT_HUGEPAGE_THRESHOLD<<  (20 - PAGE_SHIFT)))
>> +	if (totalram_pages<  (CONFIG_TRANSPARENT_HUGEPAGE_THRESHOLD
>> +					<<  (20 - PAGE_SHIFT))) {
>> +		printk(KERN_INFO "hugepage: disabled auotmatically\n");
>
> typo automatically. I'd suggest to change the prefix from "hugepage:"
> to "THP:" to avoid the risk of possible confusion with hugetlbfs
> support. Maybe you could print the minimal threshold too ("disabled
> automatically with less than %dMB of RAM").

Well, the "hugepage:" prefix is copied from other printk messages
in the same function. ;-)

Yeah, it would be nice to print the threshold too.

Thanks for your reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
