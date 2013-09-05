Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 8A5FC6B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 23:37:39 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 13:19:42 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 58DB83578050
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 13:37:14 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r853auW710813698
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 13:37:03 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r853b6e6015189
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 13:37:07 +1000
Date: Thu, 5 Sep 2013 11:37:04 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/thp: fix comments in transparent_hugepage_flags
Message-ID: <20130905033704.GA18909@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1378301422-9468-1-git-send-email-wujianguo@huawei.com>
 <5227e870.ab42320a.62d4.3d12SMTPIN_ADDED_BROKEN@mx.google.com>
 <5227F4B6.40009@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5227F4B6.40009@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Jianguo Wu <wujianguo106@gmail.com>, akpm@linux-foundation.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 05, 2013 at 11:04:22AM +0800, Jianguo Wu wrote:
>Hi Wanpeng,
>
>On 2013/9/5 10:11, Wanpeng Li wrote:
>
>> Hi Jianguo,
>> On Wed, Sep 04, 2013 at 09:30:22PM +0800, Jianguo Wu wrote:
>>> Since commit d39d33c332(thp: enable direct defrag), defrag is enable
>>> for all transparent hugepage page faults by default, not only in
>>> MADV_HUGEPAGE regions.
>>>
>>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>>> ---
>>> mm/huge_memory.c | 6 ++----
>>> 1 file changed, 2 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>> index a92012a..abf047e 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -28,10 +28,8 @@
>>>
>>> /*
>>>  * By default transparent hugepage support is enabled for all mappings
>> 
>> This is also stale. TRANSPARENT_HUGEPAGE_ALWAYS is not configured by default in
>> order that avoid to risk increase the memory footprint of applications w/o a 
>> guaranteed benefit.
>> 
>
>Right, how about this:
>
>By default transparent hugepage support is disabled in order that avoid to risk

I don't think it's disabled. TRANSPARENT_HUGEPAGE_MADVISE is configured
by default.

Regards,
Wanpeng Li 

>increase the memory footprint of applications w/o a guaranteed benefit, and
>khugepaged scans all mappings when transparent hugepage enabled.
>Defrag is invoked by khugepaged hugepage allocations and by page faults for all
>hugepage allocations.
>
>Thanks,
>Jianguo Wu
>
>> Regards,
>> Wanpeng Li 
>> 
>>> - * and khugepaged scans all mappings. Defrag is only invoked by
>>> - * khugepaged hugepage allocations and by page faults inside
>>> - * MADV_HUGEPAGE regions to avoid the risk of slowing down short lived
>>> - * allocations.
>>> + * and khugepaged scans all mappings. Defrag is invoked by khugepaged
>>> + * hugepage allocations and by page faults for all hugepage allocations.
>>>  */
>>> unsigned long transparent_hugepage_flags __read_mostly =
>>> #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
>>> -- 
>>> 1.8.1.2
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 
>> 
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
