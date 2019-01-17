Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9C36C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 15:51:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A76AA20855
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 15:51:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A76AA20855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C2BA8E000A; Thu, 17 Jan 2019 10:51:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49A528E0002; Thu, 17 Jan 2019 10:51:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 389FF8E000A; Thu, 17 Jan 2019 10:51:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 108008E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:51:52 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id g79so4419560vsd.6
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:51:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=3qaNAmU6evFJ+KEl134h9W/WxdkVS1/zYL0nrow/i9U=;
        b=VLvPsW68VAfyiU6+naUreZpXs8DqKQeNr0U0ocV9FUE37TBmupkAUojiO9yNT80Ui0
         XIczecnyiI/+5AnE6TItWxOFQdOfQ35bdG9XXRE/kVXtaBcYMFvlJJP2WFC+iKsp+YMB
         1oT3Y0i7ujzYRSPiMGTjfY5QXiJtnXMcTyq1Anlz+NGbaT/87tE0sWVXPvtzfy/E3v4+
         zeJEj2ep38Rln9gZAUBefnzeTtY8+lICO73cUJ+aKUE/+/ZqAQ3w3EroAofsYz+D0lID
         fRSz7omrGfK9Z11BI06dDRTwAibpWF8XCJhujzIVBEsvHJqStc4GaqrigDtcZqSzQxhA
         EpUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: AJcUukfeTioX4pCEIgxSYOVTWir4MdvVmQM/Wn5r/Yv7VjFrIowEHuh3
	ynmokRDg25/uBLJ1jgVoT0HEiUKSHHICi6jnphKsFTgh14crFJ0JXpI6J2NlT2bjjh8scKZHhOH
	8OFHAUe4xV8YjziVdPfddlObd0W6ktDGLrc5t6Yznybhn6Rc2BabqvYSE0qKA/wo9zw==
X-Received: by 2002:a67:334a:: with SMTP id z71mr6378612vsz.40.1547740311748;
        Thu, 17 Jan 2019 07:51:51 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5yx9YJO8AyfPNrv5PtBr6nJmSkZXez+t4rKdrWdYFzndvaiV8ETOlBJd0YXTl9kfpKNSnq
X-Received: by 2002:a67:334a:: with SMTP id z71mr6378586vsz.40.1547740310789;
        Thu, 17 Jan 2019 07:51:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547740310; cv=none;
        d=google.com; s=arc-20160816;
        b=yGsFXeWj6r+H/31/mHfr8DC8nrS2d0nbG+sAgAPZypqWNzOQgfVaXsZrUWDTOFti/N
         vaywzpzvRsiH/7f1lkpNBer/Slyghlg5XMaitWdKuBWuYbJtwlX7BPVil+fwD29x1kj3
         JhBMNSkoHlDt5IihXZ8HgpbBg8iQiXyaDBwgMoFhaLKF1ePDNFOsnNmdXFWaRYixibVt
         DiIED2LscXK0wDhFxzfhVmTMtu/thoCWKdFdfqbxn9YjGpCe1Iuz3L9uPkw/y3UkWshs
         bYMdYIufXQSnm8U9ljYZiZ0VLxLk0T2CcW7fhJueKG7cVigkwvZHT6YfmJU0XN7LOFL1
         ZuTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=3qaNAmU6evFJ+KEl134h9W/WxdkVS1/zYL0nrow/i9U=;
        b=UbsL59IKTmQx0yrQ/oGjA8VOnp0bX/MzoddE4g+ex9m323IkZATokCbpuwcgkBH5MA
         exhn0stPfB5pqsNzlavdsxcnzrWtOn2okGqi13CxNs9fnQblhd/6m0qL7fFtjuNzATpm
         D1iVVLZyNNfH7o9JP3qVOjaaPQbKysudEiQGb+DvBmXxYzbU7Ehl7aJuYlEwcTA0jMhw
         CDZrkCUo413FdUE9ZEjqjMAOpspeqXto6vWfSxIQUUaqnVwK6/tQsa9UdSdmpazl/dLT
         NcWya38ZR/6PFgizJfH+CokAtfSIrgv/ETLym+FpgFdgsSULhtr5I+BJUnyDJV7iNtpO
         qTeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id t8si390703vsn.443.2019.01.17.07.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 07:51:50 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 5482CA5566F563353FE2;
	Thu, 17 Jan 2019 23:51:45 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.408.0; Thu, 17 Jan 2019
 23:51:44 +0800
Message-ID: <5C40A48F.6070306@huawei.com>
Date: Thu, 17 Jan 2019 23:51:43 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Vinayak Menon <vinmenon@codeaurora.org>, Laurent Dufour
	<ldufour@linux.vnet.ibm.com>
CC: Linux-MM <linux-mm@kvack.org>, <charante@codeaurora.org>, Ganesh Mahendran
	<opensource.ganesh@gmail.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org> <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org> <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com> <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org>
In-Reply-To: <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117155143.ZfpF7oKR3WfX_d-frH-VdLctpHqAzkVgJG2j2rTB_UM@z>

On 2019/1/16 19:41, Vinayak Menon wrote:
> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>> Hi Laurent,
>>>>
>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>
>>> With the patch below, we don't hit the issue.
>>>
>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>
>>> It is observed that the following scenario results in
>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>> forever after few iterations.
>>>
>>> CPU 1                   CPU 2                    CPU 3
>>> Process 1,              Process 1,               Process 1,
>>> Thread A                Thread B                 Thread C
>>>
>>> while (1) {             while (1) {              while(1) {
>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>> }                       }
>>>
>>> When from thread C, copy_one_pte write-protects the parent pte
>>> (of lock l), stale tlb entries can exist with write permissions
>>> on one of the CPUs at least. This can create a problem if one
>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>> does not take mmap_sem it can proceed further fixing a fault soon
>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>> entry can still modify old_page even after it is copied to
>>> new_page by wp_page_copy, thus causing a corruption.
>> Nice catch and thanks for your investigation!
>>
>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>
>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>> ---
>>>   mm/memory.c | 7 +++++++
>>>   1 file changed, 7 insertions(+)
>>>
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index 52080e4..1ea168ff 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>                  return VM_FAULT_RETRY;
>>>          }
>>>
>>> +       /*
>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>> +        * in copy_one_pte
>>> +        */
>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>> +               flush_tlb_page(vmf.vma, address);
>>> +
>>>          mem_cgroup_oom_enable();
>>>          ret = handle_pte_fault(&vmf);
>>>          mem_cgroup_oom_disable();
>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>
>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
>
> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?
>
>
>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>
> Your patch works fine on arm64 with a minor change. Thanks Laurent.
Hi, Vinayak and Laurent

I think the below change will impact the performance significantly. Becuase most of process has many
vmas with cow flags. Flush the tlb in advance is not the better way to avoid the issue and it will
call the flush_tlb_mm  later.

I think we can try the following way to do.

vm_write_begin(vma)
copy_pte_range
vm_write_end(vma)

The speculative page fault will return to grap the mmap_sem to run the nromal path.
Any thought?

Thanks,
zhong jiang
> diff --git a/mm/memory.c b/mm/memory.c
> index 52080e4..4767095 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1087,6 +1087,7 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>         spinlock_t *src_ptl, *dst_ptl;
>         int progress = 0;
>         int rss[NR_MM_COUNTERS];
> +       unsigned long orig_addr = addr;
>         swp_entry_t entry = (swp_entry_t){0};
>
>  again:
> @@ -1125,6 +1126,15 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>         } while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
>
>         arch_leave_lazy_mmu_mode();
> +
> +       /*
> +        * Prevent the page fault handler to copy the page while stale tlb entry
> +        * are still not flushed.
> +        */
> +       if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT) &&
> +               is_cow_mapping(vma->vm_flags))
> +                       flush_tlb_range(vma, orig_addr, end);
> +
>         spin_unlock(src_ptl);
>         pte_unmap(orig_src_pte);
>         add_mm_rss_vec(dst_mm, rss);
>
> Thanks,
>
> Vinayak
>
>
>


