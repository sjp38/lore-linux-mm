Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A8C7C282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 16:22:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6109C21726
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 16:22:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6109C21726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2C3F8E0003; Tue, 22 Jan 2019 11:22:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDA608E0001; Tue, 22 Jan 2019 11:22:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCA0A8E0003; Tue, 22 Jan 2019 11:22:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACA328E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:22:50 -0500 (EST)
Received: by mail-vk1-f199.google.com with SMTP id g87so4872726vkc.12
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:22:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=YS/tcDM5Yeldu8TR08uoHOg6VLim84vgWCFhj2LwtGg=;
        b=C66Q7iMT8PmU7k+w4gFDkSGWiAlXCyN0jw5StERx/8eKTqc/Zmidz6sEiPBcZZhILH
         BgVsaL2opy720bL3FUSnP8V/DeQLyL1BrL+PJJTNeqiluwzeF1I9LsopNNfV7NlQthhU
         q6xts2Dm9gYpsfQxCQC+Y6ZwYKLg+F9IVaC4z53xzlT1Gs6Xkhh6/Z1Gt53KZNxB4/+x
         evL6LBgDREpnzggffoWMbgEHJrYEhnIYcHoDnewtvdsQURo4MnhmHgaCEXkWLuhPt8QA
         LZ4oluUfL5wfmeOEPFVGxVBp7Od9pK5jPKEpFUcmhGLRng/GI3QzsDbo3hpUnlAXV+ry
         pi2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: AJcUukcaagBPkKBEFI1UGz1/T/umSqQDTVeNrPf5+vGI3aWdvmqSnI4Q
	y08xmlHQuY5/0VU2kH0TTmfTo9MxoTjieCQcdwJKQu07HaBJzyQSGVm/pZFnGlrS7YjjDZa4zQP
	O1PCnatS0x39tOPiehw2YUWtQWjHp1sHgMIj20wTvnVC1/XAeOmXT4fOpht16B+C+eQ==
X-Received: by 2002:a67:694f:: with SMTP id e76mr12992054vsc.161.1548174170333;
        Tue, 22 Jan 2019 08:22:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7EqvJzzu7fxnVXBpkZ8QBt5CnCyNWCl5keCXRAy+owKRxIsQReYT/bfSeHgGUOJR9Q4La8
X-Received: by 2002:a67:694f:: with SMTP id e76mr12992028vsc.161.1548174169308;
        Tue, 22 Jan 2019 08:22:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548174169; cv=none;
        d=google.com; s=arc-20160816;
        b=zsvGYKrPP6kAZ8v6ZrZi+5FQn1AnPg8w2jxswrAQBj2UagET9qyI8ePgWyjWoldhqZ
         KsSwD+NlCym6xlOTWcgSP/XJoCrkxJXqycaJgdLJJyy8sbrKSRH1CntcAiKcEwAKUP3X
         rqzAm39Zr8QzlPEATiRY4De9ZnyKYxlsPBTwMQY5+oDX9av4Z6O/XkYWypwJhBwj4p2X
         DrGhqbCb52I7Ab4tRvgH/yTZcJPOm1vkVBCfXtRTNDVhSf695I7WXBprjLguhDkyPmDh
         3j0PR15nhxAvxS/IPuCuhR2Q//FtJLov++vN1NrXocInC4ooZIy+/HzG7o9bkmtS2CdP
         A/Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=YS/tcDM5Yeldu8TR08uoHOg6VLim84vgWCFhj2LwtGg=;
        b=AtjqS4MDzfAAsPZzg89k8JyOHvQytOPEpI/SGIWzFps0tgdgGuPW36Q4oJ6Lzpm9yU
         zofz9N62XSoocrw7XVkE+HvIyNXoE/NVKAquDY2am63OuH5xFurBP48bGWNa3kP9huUX
         vwtoRi8pJ/DGzu9d9RbAE1QcrWxBDzDBzrULjhCPubzFsbHJt432dYs6rv2nUxtV24ol
         ahAMM6Xma/lDjdYh0liu5sA+ufL5CPp67uge5UW9iCBg3icjvJUnR8Qe12n12mhNTdeK
         zXtHhcpsySnc5ZJyhU5NZVaTKiC/o7NUcVypd/pJ+yfFWXMhm2NHJtzEN1o7aYOTw7wu
         zzHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id o20si11883633vsr.351.2019.01.22.08.22.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 08:22:49 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id A0EE7EADA7A022A28C0A;
	Wed, 23 Jan 2019 00:22:44 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS407-HUB.china.huawei.com
 (10.3.19.207) with Microsoft SMTP Server id 14.3.408.0; Wed, 23 Jan 2019
 00:22:41 +0800
Message-ID: <5C474351.5030603@huawei.com>
Date: Wed, 23 Jan 2019 00:22:41 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
CC: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>,
	<charante@codeaurora.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org> <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org> <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com> <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org> <5C40A48F.6070306@huawei.com> <8bfaf41b-6d88-c0de-35c0-1c41db7a691e@linux.vnet.ibm.com>
In-Reply-To: <8bfaf41b-6d88-c0de-35c0-1c41db7a691e@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190122162241.DU3EbxblTUzniaSC1M97thFCdjYql-QTE2Q_QKQu_3g@z>

On 2019/1/19 0:24, Laurent Dufour wrote:
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
> Here is a new version of the patch fixing this issue. There is no additional TLB flush, all the fix is belonging on vm_write_{begin,end} calls.
>
> I did some test on x86_64 and PowerPC but that needs to be double check on arm64.
>
> Vinayak, Zhong, could you please give it a try ?
>
Hi Laurent

I apply the patch you had attached and none of any abnormal thing came in two days. It is feasible to fix the issue.

but It will better to filter the condition by is_cow_mapping. is it right?

for example:

if (is_cow_mapping(mnpt->vm_flags)) {
      
    ........
}
   
Thanks,
zhong jiang
> Thanks,
> Laurent.
>


