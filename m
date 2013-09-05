Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 3246F6B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 03:27:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 12:46:34 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 98C751258053
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 12:57:09 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r857R9EM46465132
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 12:57:10 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r857RApT013644
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 12:57:10 +0530
Date: Thu, 5 Sep 2013 15:27:08 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/thp: fix comments in transparent_hugepage_flags
Message-ID: <20130905072708.GA15294@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1378301422-9468-1-git-send-email-wujianguo@huawei.com>
 <5227e870.ab42320a.62d4.3d12SMTPIN_ADDED_BROKEN@mx.google.com>
 <5227F4B6.40009@huawei.com>
 <20130905033704.GA18909@hacker.(null)>
 <52280058.5070803@huawei.com>
 <52280f92.e72b320a.2501.6de1SMTPIN_ADDED_BROKEN@mx.google.com>
 <522825E4.7080404@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <522825E4.7080404@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Jianguo Wu <wujianguo106@gmail.com>, akpm@linux-foundation.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Jianguo,
On Thu, Sep 05, 2013 at 02:34:12PM +0800, Jianguo Wu wrote:
>On 2013/9/5 12:58, Wanpeng Li wrote:
>
>> Hi Jianguo,
>> On Thu, Sep 05, 2013 at 11:54:00AM +0800, Jianguo Wu wrote:
>>> On 2013/9/5 11:37, Wanpeng Li wrote:
>>>
>>>> On Thu, Sep 05, 2013 at 11:04:22AM +0800, Jianguo Wu wrote:
>>>>> Hi Wanpeng,
>>>>>
>>>>> On 2013/9/5 10:11, Wanpeng Li wrote:
>>>>>
>>>>>> Hi Jianguo,
>>>>>> On Wed, Sep 04, 2013 at 09:30:22PM +0800, Jianguo Wu wrote:
>>>>>>> Since commit d39d33c332(thp: enable direct defrag), defrag is enable
>>>>>>> for all transparent hugepage page faults by default, not only in
>>>>>>> MADV_HUGEPAGE regions.
>>>>>>>
>>>>>>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>>>>>>> ---
>>>>>>> mm/huge_memory.c | 6 ++----
>>>>>>> 1 file changed, 2 insertions(+), 4 deletions(-)
>>>>>>>
>>>>>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>>>>>> index a92012a..abf047e 100644
>>>>>>> --- a/mm/huge_memory.c
>>>>>>> +++ b/mm/huge_memory.c
>>>>>>> @@ -28,10 +28,8 @@
>>>>>>>
>>>>>>> /*
>>>>>>>  * By default transparent hugepage support is enabled for all mappings
>>>>>>
>>>>>> This is also stale. TRANSPARENT_HUGEPAGE_ALWAYS is not configured by default in
>>>>>> order that avoid to risk increase the memory footprint of applications w/o a 
>>>>>> guaranteed benefit.
>>>>>>
>>>>>
>>>>> Right, how about this:
>>>>>
>>>>> By default transparent hugepage support is disabled in order that avoid to risk
>>>>
>>>> I don't think it's disabled. TRANSPARENT_HUGEPAGE_MADVISE is configured
>>>> by default.
>>>>
>>>
>>> Hi Wanpeng,
>>>
>>> We have TRANSPARENT_HUGEPAGE and TRANSPARENT_HUGEPAGE_ALWAYS/TRANSPARENT_HUGEPAGE_MADVISE,
>>> TRANSPARENT_HUGEPAGE_ALWAYS or TRANSPARENT_HUGEPAGE_MADVISE is configured only if TRANSPARENT_HUGEPAGE
>>> is configured.
>>>
>>> By default, TRANSPARENT_HUGEPAGE=n, and TRANSPARENT_HUGEPAGE_ALWAYS is configured when TRANSPARENT_HUGEPAGE=y.
>>>
>>> commit 13ece886d9(thp: transparent hugepage config choice):
>>>
>>> config TRANSPARENT_HUGEPAGE
>>> -       bool "Transparent Hugepage Support" if EMBEDDED
>>> +       bool "Transparent Hugepage Support"
>>>        depends on X86 && MMU
>>> -       default y
>>>
>>> +choice
>>> +       prompt "Transparent Hugepage Support sysfs defaults"
>>> +       depends on TRANSPARENT_HUGEPAGE
>>> +       default TRANSPARENT_HUGEPAGE_ALWAYS
>>>
>> 
>> mmotm tree:
>> 
>> grep 'TRANSPARENT_HUGEPAGE' .config
>> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
>> CONFIG_TRANSPARENT_HUGEPAGE=y
>> # CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
>> CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
>> 
>> distro:
>> 
>> grep 'TRANSPARENT_HUGEPAGE' config-3.8.0-26-generic 
>> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
>> CONFIG_TRANSPARENT_HUGEPAGE=y
>> # CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
>> CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
>> 
>
>Hi Wanpeng,
>
>I'm a little confused, at mm/Kconfig, TRANSPARENT_HUGEPAGE is not configured by default.
>
>and in x86_64, linus tree:
>
>$make defconfig
>$grep 'TRANSPARENT_HUGEPAGE' .config
>CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
># CONFIG_TRANSPARENT_HUGEPAGE is not set
>

Ah, ok, maybe distro enable them.

Regards,
Wanpeng Li 

>Do i misunderstand something herei 1/4 ?
>
>Thanks
>
>> 
>>> Thanks,
>>> Jianguo Wu
>>>
>>>> Regards,
>>>> Wanpeng Li 
>>>>
>>>>> increase the memory footprint of applications w/o a guaranteed benefit, and
>>>>> khugepaged scans all mappings when transparent hugepage enabled.
>>>>> Defrag is invoked by khugepaged hugepage allocations and by page faults for all
>>>>> hugepage allocations.
>>>>>
>>>>> Thanks,
>>>>> Jianguo Wu
>>>>>
>>>>>> Regards,
>>>>>> Wanpeng Li 
>>>>>>
>>>>>>> - * and khugepaged scans all mappings. Defrag is only invoked by
>>>>>>> - * khugepaged hugepage allocations and by page faults inside
>>>>>>> - * MADV_HUGEPAGE regions to avoid the risk of slowing down short lived
>>>>>>> - * allocations.
>>>>>>> + * and khugepaged scans all mappings. Defrag is invoked by khugepaged
>>>>>>> + * hugepage allocations and by page faults for all hugepage allocations.
>>>>>>>  */
>>>>>>> unsigned long transparent_hugepage_flags __read_mostly =
>>>>>>> #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
>>>>>>> -- 
>>>>>>> 1.8.1.2
>>>>>>>
>>>>>>> --
>>>>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>>>>> see: http://www.linux-mm.org/ .
>>>>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>>>>
>>>>>> --
>>>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>>>> see: http://www.linux-mm.org/ .
>>>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>>>>
>>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>> .
>>>>
>>>
>>>
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
