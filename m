Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 1808B6B0034
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 04:44:50 -0400 (EDT)
Message-ID: <5228435A.6060807@huawei.com>
Date: Thu, 5 Sep 2013 16:39:54 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/thp: fix stale comments of transparent_hugepage_flags
References: <5228397B.9000502@huawei.com> <52283c3b.e786320a.12f5.ffff90f2SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <52283c3b.e786320a.12f5.ffff90f2SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, Mel Gorman <mgorman@suse.de>, xiaoguangrong@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Wanpeng,
Thanks for your review, but this patch has minor format problem, please see below.
Please review the resend one, thanks.

Thanks,
Jianguo Wu

On 2013/9/5 16:09, Wanpeng Li wrote:

> On Thu, Sep 05, 2013 at 03:57:47PM +0800, Jianguo Wu wrote:
>> Changelog:
>> *v1 -> v2: also update the stale comments about default transparent
>> hugepage support pointed by Wanpeng Li.
>>
>> Since commit 13ece886d9(thp: transparent hugepage config choice),
>> transparent hugepage support is disabled by default, and
>> TRANSPARENT_HUGEPAGE_ALWAYS is configured when TRANSPARENT_HUGEPAGE=y.
>>
>> And since commit d39d33c332(thp: enable direct defrag), defrag is
>> enable for all transparent hugepage page faults by default, not only in
>> MADV_HUGEPAGE regions.
>>
> 
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> 
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> ---
>> mm/huge_memory.c |   12 ++++++------
>> 1 files changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index a92012a..0e42a70 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -26,12 +26,12 @@
>> #include <asm/pgalloc.h>
>> #include "internal.h"
>>
>> -/*
>> - * By default transparent hugepage support is enabled for all mappings
>> - * and khugepaged scans all mappings. Defrag is only invoked by
>> - * khugepaged hugepage allocations and by page faults inside
>> - * MADV_HUGEPAGE regions to avoid the risk of slowing down short lived
>> - * allocations.
>> +/* By default transparent hugepage support is disabled in order that avoid

Should be:
+/*
+ * By default transparent hugepage support is disabled in order that avoid

Please review the resend one.

Thanks.

>> + * to risk increase the memory footprint of applications without a guaranteed
>> + * benefit. When transparent hugepage support is enabled, is for all mappings,
>> + * and khugepaged scans all mappings.
>> + * Defrag is invoked by khugepaged hugepage allocations and by page faults
>> + * for all hugepage allocations.
>>  */
>> unsigned long transparent_hugepage_flags __read_mostly =
>> #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
>> -- 
>> 1.7.1
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
