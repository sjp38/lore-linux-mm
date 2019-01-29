Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86E75C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:40:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 422E221473
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:40:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 422E221473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4E6B8E0002; Tue, 29 Jan 2019 10:40:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFE768E0001; Tue, 29 Jan 2019 10:40:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEDE28E0002; Tue, 29 Jan 2019 10:40:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8167F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:40:33 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id m5so9413765vso.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 07:40:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=1WEGQGXDasGJ1axnsdYDvhxRGCUhcimtYxJ+MXygFPc=;
        b=C2xLUzlUs/W3DKZbXBZD95lAGiTeciIBxx0xUt87EMme5BbEOP5AOarjMm3rFSo+Ry
         tC+Yg/3gqbXpnQoRWow4WcPDGEwAjNGzD5fmCBcbuqvs5skwFEaD0QU0X/VagTrLav9O
         i2mR71u+tNLuhQ5QKxUsYGdMbo0Ek8rawGhx3mhkMGjiZn5JdFLwux06J7XQA60/wqd6
         VD+okDANfXpR3q9JJ/eeiypsGDgFR+h6qa61yyzWt0sT70Zfjnm89aAyr2zUUVOY2svp
         b19QlEKMWmNyHenfQyXSFmHW37ug5X40kyv7jrvcZL02lSVegENQ+cB5rHy+rSf2AcYh
         CAvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: AJcUukeDxLRuNHtQeW00W6GyorhTTkAMHkRMosNRnIN43F5BBa0wNytV
	6DsnpStEPh4TJ4oB/hRNPbvN6bNf20GizsPrq1wC5QdTo5HZVlbJAS8+J6FNnxF3qij7PD/zP6B
	p5tkQc962+stVSjys4DvRazxDWx2WgMbF0a4j7GUop1wzA0Wq1kkd7qoMxo2ZIG+69A==
X-Received: by 2002:a67:d00f:: with SMTP id r15mr10962555vsi.191.1548776433152;
        Tue, 29 Jan 2019 07:40:33 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4zGO41AHIdMjZxjxEt4ePIqNs7cgsYsx05RCWLT0l34PVGx62fIHkDnq43/dlkFBsOGIHJ
X-Received: by 2002:a67:d00f:: with SMTP id r15mr10962541vsi.191.1548776432440;
        Tue, 29 Jan 2019 07:40:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548776432; cv=none;
        d=google.com; s=arc-20160816;
        b=ZX8SXRbc7QUvnJ+XfAf1ZPpQbBg4GBfApJ6OF5HYy2vY0J/pQRTHv1PKt5wrtKy8TK
         /nR7Ngytcn+7Uvo9fBRierFdfiOQOjbUDI42vb+tz+s8KVcJEkH6il4zItU+DkoVwr9c
         8hXE3twOD4FdTzbIubP1cJ7/g5nd+YptTGWlU6+R7lJHdcZ4dnBZOrwdCQKhn9nJoeWU
         D7z09bnJcOVf4ldtWZUUMvE2KyUEAmAMkqgVF7Gy1o9lL1yuQsDTMLOURAtFhYJiOmUY
         m3aFa7x3ZUq8xNHAq6yMduksENdsea/5dRHy/vdVtPpM1gCp1rHBpcrngZaqb9Bt/V3u
         Yo9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=1WEGQGXDasGJ1axnsdYDvhxRGCUhcimtYxJ+MXygFPc=;
        b=a8HRohrnrr78F+JCHLwzhZC+iS36KrswbO5/MIG/0tiPII8mLAEDBD5wJYyqLA1ApG
         OWHe+Z5ndyKQHfGFEt0sHFFHwTRQbaTpMZ7XsS0D1W5ZZVTYZgdi78Wv0zEvTqdHiHiO
         NwoVpy450yakRWq/kZSAVxsUzGnGkpOJ+OBLoSuIX8hS8/V96Quyd1BnNzc69zLpTWcW
         fOLCNVcXE3Tv2EWdpWepaQV89noYbS9NUsk3OeGxUdHmWyGugPiURRnqvuoLb7F9uQSx
         ZcnPvzJ1c1t28rgbIOPTzKWpbWBaCKXw5kmnZBZF3wzk0c2BoFw0H/puZv2GwgejFpUC
         AgPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id l15si8511614vsa.400.2019.01.29.07.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 07:40:32 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 2D363104CA26B66BDE98;
	Tue, 29 Jan 2019 23:40:26 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Tue, 29 Jan 2019
 23:40:25 +0800
Message-ID: <5C5073E8.5060205@huawei.com>
Date: Tue, 29 Jan 2019 23:40:24 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
CC: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>,
	<charante@codeaurora.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org> <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org> <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com> <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org> <5C40A48F.6070306@huawei.com> <8bfaf41b-6d88-c0de-35c0-1c41db7a691e@linux.vnet.ibm.com> <5C474351.5030603@huawei.com> <0ab93858-dcd2-b28a-3445-6ed2f75b844b@linux.vnet.ibm.com> <5C4B01F1.5020100@huawei.com> <77ff7d2e-38aa-137b-6800-9b328239a321@linux.vnet.ibm.com> <5C4F0D13.5070100@huawei.com> <c2217ac1-1a16-44f6-2f9e-d294121d3ed0@linux.vnet.ibm.com>
In-Reply-To: <c2217ac1-1a16-44f6-2f9e-d294121d3ed0@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/1/28 23:45, Laurent Dufour wrote:
> Le 28/01/2019 à 15:09, zhong jiang a écrit :
>> On 2019/1/28 16:59, Laurent Dufour wrote:
>>> Le 25/01/2019 à 13:32, zhong jiang a écrit :
>>>> On 2019/1/24 16:20, Laurent Dufour wrote:
>>>>> Le 22/01/2019 à 17:22, zhong jiang a écrit :
>>>>>> On 2019/1/19 0:24, Laurent Dufour wrote:
>>>>>>> Le 17/01/2019 à 16:51, zhong jiang a écrit :
>>>>>>>> On 2019/1/16 19:41, Vinayak Menon wrote:
>>>>>>>>> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>>>>>>>>>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>>>>>>>>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>>>>>>>>>> Hi Laurent,
>>>>>>>>>>>>
>>>>>>>>>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>>>>>>>>>
>>>>>>>>>>> With the patch below, we don't hit the issue.
>>>>>>>>>>>
>>>>>>>>>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>>>>>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>>>>>>>>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>>>>>>>>>
>>>>>>>>>>> It is observed that the following scenario results in
>>>>>>>>>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>>>>>>>>>> forever after few iterations.
>>>>>>>>>>>
>>>>>>>>>>> CPU 1                   CPU 2                    CPU 3
>>>>>>>>>>> Process 1,              Process 1,               Process 1,
>>>>>>>>>>> Thread A                Thread B                 Thread C
>>>>>>>>>>>
>>>>>>>>>>> while (1) {             while (1) {              while(1) {
>>>>>>>>>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>>>>>>>>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>>>>>>>>>> }                       }
>>>>>>>>>>>
>>>>>>>>>>> When from thread C, copy_one_pte write-protects the parent pte
>>>>>>>>>>> (of lock l), stale tlb entries can exist with write permissions
>>>>>>>>>>> on one of the CPUs at least. This can create a problem if one
>>>>>>>>>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>>>>>>>>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>>>>>>>>>> does not take mmap_sem it can proceed further fixing a fault soon
>>>>>>>>>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>>>>>>>>>> entry can still modify old_page even after it is copied to
>>>>>>>>>>> new_page by wp_page_copy, thus causing a corruption.
>>>>>>>>>> Nice catch and thanks for your investigation!
>>>>>>>>>>
>>>>>>>>>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>>>>>>>>>
>>>>>>>>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>>>>>>> ---
>>>>>>>>>>>       mm/memory.c | 7 +++++++
>>>>>>>>>>>       1 file changed, 7 insertions(+)
>>>>>>>>>>>
>>>>>>>>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>>>>>>>>> index 52080e4..1ea168ff 100644
>>>>>>>>>>> --- a/mm/memory.c
>>>>>>>>>>> +++ b/mm/memory.c
>>>>>>>>>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>>>>>>>>>                      return VM_FAULT_RETRY;
>>>>>>>>>>>              }
>>>>>>>>>>>
>>>>>>>>>>> +       /*
>>>>>>>>>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>>>>>>>>>> +        * in copy_one_pte
>>>>>>>>>>> +        */
>>>>>>>>>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>>>>>>>>> +               flush_tlb_page(vmf.vma, address);
>>>>>>>>>>> +
>>>>>>>>>>>              mem_cgroup_oom_enable();
>>>>>>>>>>>              ret = handle_pte_fault(&vmf);
>>>>>>>>>>>              mem_cgroup_oom_disable();
>>>>>>>>>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>>>>>>>>>
>>>>>>>>>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
>>>>>>>>>
>>>>>>>>> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>>>>>>>>>
>>>>>>>>> Your patch works fine on arm64 with a minor change. Thanks Laurent.
>>>>>>>> Hi, Vinayak and Laurent
>>>>>>>>
>>>>>>>> I think the below change will impact the performance significantly. Becuase most of process has many
>>>>>>>> vmas with cow flags. Flush the tlb in advance is not the better way to avoid the issue and it will
>>>>>>>> call the flush_tlb_mm  later.
>>>>>>>>
>>>>>>>> I think we can try the following way to do.
>>>>>>>>
>>>>>>>> vm_write_begin(vma)
>>>>>>>> copy_pte_range
>>>>>>>> vm_write_end(vma)
>>>>>>>>
>>>>>>>> The speculative page fault will return to grap the mmap_sem to run the nromal path.
>>>>>>>> Any thought?
>>>>>>>
>>>>>>> Here is a new version of the patch fixing this issue. There is no additional TLB flush, all the fix is belonging on vm_write_{begin,end} calls.
>>>>>>>
>>>>>>> I did some test on x86_64 and PowerPC but that needs to be double check on arm64.
>>>>>>>
>>>>>>> Vinayak, Zhong, could you please give it a try ?
>>>>>>>
>>>>>> Hi Laurent
>>>>>>
>>>>>> I apply the patch you had attached and none of any abnormal thing came in two days. It is feasible to fix the issue.
>>>>>
>>>>> Good news !
>>>>>
>>>>>>
>>>>>> but It will better to filter the condition by is_cow_mapping. is it right?
>>>>>>
>>>>>> for example:
>>>>>>
>>>>>> if (is_cow_mapping(mnpt->vm_flags)) {
>>>>>>               ........
>>>>>> }
>>>>>
>>>>> That's doable for sure but I don't think this has to be introduce in dup_mmap().
>>>>> Unless there is a real performance benefit to do so, I don't think dup_mmap() has to mimic underlying checks done in copy_page_range().
>>>>>
>>>>
>>>> Hi, Laurent
>>>>
>>>> I test the performace with microbench after appling the patch. I find
>>>> the page fault latency will increase about 8% than before.  I think we
>>>> should use is_cow_mapping to waken the impact and I will try it out.
>>>
>>> That's interesting,  I would not expect such a higher latency assuming that most of the area not in copied on write are also not managed by the speculative page fault handler (file mapping, etc.). Anyway I'm looking forward to see the result with additional is_cow_mapping() check.
>>>
>> I test the performance again. It is the protect error access latency in lat_sig.c that it will result in a drop of 8% in that testcase.
>
> What is that "protect error access latency in lat_sig.c" ?
>
It is the protect error access that the source code is lat_sig.c in microbench.
>> The page fault latency, In fact, does not impact the performace. It seems to just the fluctuation.
>>
>> Thanks,
>> zhong jiang
>>>> or we can use the following solution to replace as Vinayak has said.
>>>>
>>>> if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>>       return VM_FAULT_RETRY;
>>>>
>>>> Even though it will influence the performance of SPF, but at least it does
>>>> not bring in any negative impact. Any thought?
>>>
>>> I don't agree, this checks will completely by pass the SPF handler for all the COW areas, even if there is no race situation.
>>>
>>> Cheers,
>>> Laurent.
>>>>
>>>> Thanks,
>>>>
>>>>
>>>>> Cheers,
>>>>> Laurent.
>>>>>
>>>>>
>>>>> .
>>>>>
>>>>
>>>>
>>>
>>>
>>>
>>
>>
>
>
> .
>


