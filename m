Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A5E436B0038
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 05:49:27 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so11418527pdi.34
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 02:49:27 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ok13si10289578pdb.392.2014.07.29.02.49.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 02:49:26 -0700 (PDT)
Message-ID: <53D76DBD.9080403@huawei.com>
Date: Tue, 29 Jul 2014 17:47:41 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory hotplug: update the variables after memory
 removed
References: <1406619310-20555-1-git-send-email-zhenzhang.zhang@huawei.com> <53D74EE5.1070308@huawei.com> <alpine.DEB.2.02.1407290046470.7998@chino.kir.corp.google.com> <53D75E13.8000702@huawei.com> <alpine.DEB.2.02.1407290216520.13227@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407290216520.13227@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, mgorman@suse.de, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 2014/7/29 17:18, David Rientjes wrote:
> On Tue, 29 Jul 2014, Zhang Zhen wrote:
> 
>>>> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>>>> index df1a992..fd7bd6b 100644
>>>> --- a/arch/x86/mm/init_64.c
>>>> +++ b/arch/x86/mm/init_64.c
>>>> @@ -673,15 +673,11 @@ void __init paging_init(void)
>>>>   * After memory hotplug the variables max_pfn, max_low_pfn and high_memory need
>>>>   * updating.
>>>>   */
>>>> -static void  update_end_of_memory_vars(u64 start, u64 size)
>>>> +static void  update_end_of_memory_vars(u64 end_pfn)
>>>
>>> Extra space that can be removed here at the same time as a cleanup.
>>>
>> Sorry, where is the extra space here?
>>
> 
> There are two spaces between the function identifier and the function 
> type whereas there is traditionally only one.  It existed before your 
> patch, it would just be nice to clean it up since you're already touching 
> the line.
> 
Ok. Thanks.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
