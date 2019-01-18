Return-Path: <SRS0=AIe5=P2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C5C8C43387
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 15:41:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA9832087E
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 15:41:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA9832087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 378428E0008; Fri, 18 Jan 2019 10:41:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 328058E0002; Fri, 18 Jan 2019 10:41:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 216CD8E0008; Fri, 18 Jan 2019 10:41:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC77A8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 10:41:49 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id n22so6326273otq.8
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 07:41:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=G0ykY1/+kywVMCQ6IaQb2fZXNN81n+1BtLur2XQf38M=;
        b=j2WMrr6O0dDEiu+nv7btkf92hqCepgvluF4K9NeL6CIgEa1ESDLyHzf7dPOvrteHxh
         aoPYvKXIbC+A5avMGFDyGHfstwzhvA5YdoSfht1wnbt8fcb9SNL2Fv5APPxiCV9JzCAB
         rNlRvQFXGnTnqy2/CxJcul3DUzyt3U33Ik00LEhZ0z3KdluzUkAzTutX10cYgCJCwDc+
         sAWqbkmKIFT/u5nWyhgZ8u/9K9BxOFdp7nyJ954mgNpC80eb8LGSnCvZ57EGBZhgjhNr
         kgddaklZMeSx/lSwfXCR6+kHXyBGrs7UjMXgaA/64VUwmnbAy0ynhrOyNLjLrm9/mRfq
         murg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: AJcUukdsjdOraDFFMnwHhnWLUvbFrqK5Px1BqmTEPH9nFQnhWXLAXi3v
	2ntXGOoleb5j2ligboEUh7PBgd336yPNnd+oxq8eKoD7ZvgQ9i11jTBzjxXhv0WuYZPkS4LN3pN
	9IBZbIZ7OQVUpZqrv5zIvqUkWCWwJ9OKs5KokqbzMQxLNaF3qJkRXRivRq7mgVd0Z1A==
X-Received: by 2002:a9d:65ca:: with SMTP id z10mr12639209oth.4.1547826109547;
        Fri, 18 Jan 2019 07:41:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7uHE66p3CTA2NuEUxn62hW6zt/FVvoQ/VRBlAHaoHnwh6p4BSU1GaNbG0/3b06m6Qoj0Xo
X-Received: by 2002:a9d:65ca:: with SMTP id z10mr12639171oth.4.1547826108380;
        Fri, 18 Jan 2019 07:41:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547826108; cv=none;
        d=google.com; s=arc-20160816;
        b=xjHPYUhnTxlrA4A6xijTKO83Zd/zoZDLnHxAOUJSXaFR0N0mE6Ukn7/MM+mcPpV1eM
         eI6g7N0qiS22c+FoIQ2gH/Mk3OKC97Jv8CPWy9sy14fMKWgwFUwq8wbY9KzpdRSqZel2
         yUxltflqz1iNGdfIUeml67Z81LWnfDxAxv84zy9SEWYY2iMBv6o6b4L2SjQooIih3728
         m8njQM31l9HQl16C195/OEDGfAfK3dzGYYZonYoQ8UvydzR8e2G3aHAl7/MuCUbjNThJ
         Ms6JDFI2qDgKIGNFPe1xVEEz3wWoXEgB/FQEvZTqpFXP/hGFjWG57TDzgNfzdkOZdzwO
         UItA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=G0ykY1/+kywVMCQ6IaQb2fZXNN81n+1BtLur2XQf38M=;
        b=AAza5bgRnIKKrchV2eBQS7FRfxa5N6ru7vPv9ucTGBL4aHf8+t95RJLlUn+ilngytY
         7mi2qsKUvi+Rem6vRGTtDOwZYFcrJYvPBEmzthmq6Hr8RyQNvoU15QgM1N1rbNgkYAuh
         l1Ur/aq221zbq/bPAyq9sgGR/mQax38s+pCZG9pbnZBwFVC0fHhUUviaI4PPebaBnqB6
         byg5BH6iN5QQ1OuYd088kD2s8WIteX3O/PZN9m3iS75ps823TYUymKOCMIazZgDv4qnQ
         JrZS8+PiTbRRpwKFzzZb81tIAmYkz96/edsbCcrVtrmoVZJKw5/ljCfVQJ7Lm5qpKLB2
         ujLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id e187si2583122oih.90.2019.01.18.07.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 07:41:48 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id E56938C93445AEE9F056;
	Fri, 18 Jan 2019 23:41:42 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.408.0; Fri, 18 Jan 2019
 23:41:42 +0800
Message-ID: <5C41F3B5.5030700@huawei.com>
Date: Fri, 18 Jan 2019 23:41:41 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
CC: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>,
	<charante@codeaurora.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org> <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org> <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com> <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org> <5C40A48F.6070306@huawei.com> <38d69e03-df52-394e-514d-bdadc8f640ca@linux.vnet.ibm.com>
In-Reply-To: <38d69e03-df52-394e-514d-bdadc8f640ca@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190118154141.Fpj9IFjdWrK_KEfL8tvJTNG0dJCHW4B9yeKwBYsJLqg@z>

On 2019/1/18 17:29, Laurent Dufour wrote:
> Le 17/01/2019 à 16:51, zhong jiang a écrit :
>> On 2019/1/16 19:41, Vinayak Menon wrote:
>>> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>>>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>>>> Hi Laurent,
>>>>>>
>>>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>>>
>>>>> With the patch below, we don't hit the issue.
>>>>>
>>>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>>>
>>>>> It is observed that the following scenario results in
>>>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>>>> forever after few iterations.
>>>>>
>>>>> CPU 1                   CPU 2                    CPU 3
>>>>> Process 1,              Process 1,               Process 1,
>>>>> Thread A                Thread B                 Thread C
>>>>>
>>>>> while (1) {             while (1) {              while(1) {
>>>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>>>> }                       }
>>>>>
>>>>> When from thread C, copy_one_pte write-protects the parent pte
>>>>> (of lock l), stale tlb entries can exist with write permissions
>>>>> on one of the CPUs at least. This can create a problem if one
>>>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>>>> does not take mmap_sem it can proceed further fixing a fault soon
>>>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>>>> entry can still modify old_page even after it is copied to
>>>>> new_page by wp_page_copy, thus causing a corruption.
>>>> Nice catch and thanks for your investigation!
>>>>
>>>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>>>
>>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>>> ---
>>>>>    mm/memory.c | 7 +++++++
>>>>>    1 file changed, 7 insertions(+)
>>>>>
>>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>>> index 52080e4..1ea168ff 100644
>>>>> --- a/mm/memory.c
>>>>> +++ b/mm/memory.c
>>>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>>>                   return VM_FAULT_RETRY;
>>>>>           }
>>>>>
>>>>> +       /*
>>>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>>>> +        * in copy_one_pte
>>>>> +        */
>>>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>>> +               flush_tlb_page(vmf.vma, address);
>>>>> +
>>>>>           mem_cgroup_oom_enable();
>>>>>           ret = handle_pte_fault(&vmf);
>>>>>           mem_cgroup_oom_disable();
>>>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>>>
>>>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
>>>
>>> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?
>>>
>>>
>>>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>>>
>>> Your patch works fine on arm64 with a minor change. Thanks Laurent.
>> Hi, Vinayak and Laurent
>>
>> I think the below change will impact the performance significantly. Becuase most of process has many
>> vmas with cow flags. Flush the tlb in advance is not the better way to avoid the issue and it will
>> call the flush_tlb_mm  later.
>>
>> I think we can try the following way to do.
>>
>> vm_write_begin(vma)
>> copy_pte_range
>> vm_write_end(vma)
>>
>> The speculative page fault will return to grap the mmap_sem to run the nromal path.
>> Any thought?
>
> Hi Zhong,
>
> I agree that flushing the TLB could have a bad impact on the performance, but tagging the VMA when copy_pte_range() is not fixing the issue as the VMA must be flagged until the PTE are flushed.
>
> Here is what happens:
>
> CPU A                CPU B                       CPU C
> fork()
> copy_pte_range()
>   set PTE rdonly
> got to next VMA...           
>  .                   PTE is seen rdonly             PTE still writable
>  .                   thread is writing to page
>  .                   -> page fault
>  .                     copy the page             Thread writes to page
>  .                      .                        -> no page fault
>  .                     update the PTE
>  .                     flush TLB for that PTE
> flush TLB                                        PTE are now rdonly  
>
> So the write done by the CPU C is interfering with the page copy operation done by CPU B, leading to the data corruption.
>
I want to know the case if the CPU B has finished in front of the CPU C that the data still is vaild ?

This is to say, the old_page will be changed from other cpu because of the access from other cpu.

Maybe this is a stupid qestion :-)

Thanks,
zhong jiang.
> Flushing the PTE in copy_pte_range() is fixing the issue as the CPU C is seeing the PTE as rdonly earlier. But this impacts performance.
>
> Another option, I'll work on is to flag _all the COW eligible_ VMA before starting copying them and until the PTE are flushed on the CPU A.
> This way when the CPU B will page fault the speculative handler will abort because the VMA is in the way to be touched.
>
> But I need to ensure that all the calls to copy_pte_range() are handling this correctly.
>
> Laurent.
>
>
> .
>


