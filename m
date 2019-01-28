Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8118FC282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 14:09:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B8B820989
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 14:09:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B8B820989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCE7B8E0002; Mon, 28 Jan 2019 09:09:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C80018E0001; Mon, 28 Jan 2019 09:09:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B95AE8E0002; Mon, 28 Jan 2019 09:09:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEF18E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:09:34 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id a3so6281507otl.9
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:09:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=X43PN/KkX8iYmVRPjQyvHzO8JiIiVO1t62ypCst02PM=;
        b=LYu8GqnjVrlPrpsNvPavC355mltERtjTlKmpEz62HVIE6DfduRRptHrAZqBx7SEtHF
         ryYCmnvp0K16zDcMmtLfu+mqz3cfhMl25QHBbFsoje9v4gc/GHssGtvR7Qaj1Np7B3j8
         geo23xwgZqxRt1X8TQOBU4bxCBfNsBB0Y2phctEAO/d57pf+84wPwUQUDntEQShTdTKa
         79XPwVKPgFRsYrW8HNHLSRPiyS+yfMM7r1zODnnpwmPewa8dBOKAp7SLmPeQdlXNPgdU
         +lmIF+j+WjK2jkMwAsGmpSHP72U6qtA+1cbfINR5qqcC/mjFU7empFj90mu/WKlAPAnO
         Xo2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: AJcUukdwxkIJ+1wjO0NJzSnEpjcrgagwx7TyU+KoT1XkIE1kcM0Xis0o
	3woWnHMErTJZ/grOX+1M1qJuEUq28gyfCPEz4yjOz6J0uVtjPUZauLmiAh731jR1fzi51PLeaXN
	UFkoKx+H+iQANbqck0B/sf873kSg2QyyLvDHKT5W1+ClxurlRxRDQTYfkDVhmybteBg==
X-Received: by 2002:a9d:4595:: with SMTP id x21mr16085585ote.234.1548684574215;
        Mon, 28 Jan 2019 06:09:34 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4qrqqbe5ELAv5vUw5kkRk5i5HLHY06O0pVd8m/4POpVEa2Ywu/WxAHV67KsY/x2ea+XZ8Z
X-Received: by 2002:a9d:4595:: with SMTP id x21mr16085539ote.234.1548684573209;
        Mon, 28 Jan 2019 06:09:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548684573; cv=none;
        d=google.com; s=arc-20160816;
        b=HEM8wHRmhSO+/0J6UfOrhJWa0EV9db8bikgc2jmG2/7u5abozoDdM0tlIMzzgyXCPU
         ac/TM2A5fXmVGzlW+1lQgYKH36CZRaKmJH6gOv0ecT9HIatBJL7V8aPmeB4egw3KPvFQ
         k6TouBtAUDNLb2fost4c0Cyl8rl4eBybrUdAwXbpuybYlHiyI57emJ8AZifUFbHUWb0o
         qIEfSiGW7IPqbRQI4ze9wt5UFTSBHoH9anPcR9NQgT6oirQUavtc68H1XwvpHGhU3lDa
         IPwplwfXt1YFJ3XyqnWN/BQcCiBv2yMoidiVqOrr+ruH+RsyJNt2Vh1nQNirbrzWic5r
         nLSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=X43PN/KkX8iYmVRPjQyvHzO8JiIiVO1t62ypCst02PM=;
        b=npB6Cap07ckxRDf1KFCKVHmzHssJnHYqaumO86fRcVjfDNPE9DM/nFjgkQZaSF2JIo
         PAhUbOmcch2lfxXubov0D12WxtTmjmSQs4STai6AyiSO+7zE7bm8fshAcNHWY0xc2DnG
         6SGd6eE1/oGQFJ2Yg8I7K6BlPsic2mOqOsN9i9wGGwxs/E0ATSRSAV9kPouEzYYlHkfe
         OXB6W9Ce6N2IAUQWFm7ky27AHMOtQ780r7oQ9Cvxix9A8aZ8TtsgPA1UHs5MutkdXQzB
         aW0n7Cv1LoKl6ua0V5izOCI7FcYMfj4CnpWGyarNjx7RxwAI9C1XcDo0NH1QJFb9BMXl
         GFtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id v89si4824432otb.145.2019.01.28.06.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 06:09:33 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 8463275FBAF29EF716B6;
	Mon, 28 Jan 2019 22:09:27 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS407-HUB.china.huawei.com
 (10.3.19.207) with Microsoft SMTP Server id 14.3.408.0; Mon, 28 Jan 2019
 22:09:24 +0800
Message-ID: <5C4F0D13.5070100@huawei.com>
Date: Mon, 28 Jan 2019 22:09:23 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
CC: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>,
	<charante@codeaurora.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org> <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org> <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com> <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org> <5C40A48F.6070306@huawei.com> <8bfaf41b-6d88-c0de-35c0-1c41db7a691e@linux.vnet.ibm.com> <5C474351.5030603@huawei.com> <0ab93858-dcd2-b28a-3445-6ed2f75b844b@linux.vnet.ibm.com> <5C4B01F1.5020100@huawei.com> <77ff7d2e-38aa-137b-6800-9b328239a321@linux.vnet.ibm.com>
In-Reply-To: <77ff7d2e-38aa-137b-6800-9b328239a321@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128140923.px0_SwHWtefLEMvk09oXaozj31_J-CkWIKgOteWk4lQ@z>

On 2019/1/28 16:59, Laurent Dufour wrote:
> Le 25/01/2019 à 13:32, zhong jiang a écrit :
>> On 2019/1/24 16:20, Laurent Dufour wrote:
>>> Le 22/01/2019 à 17:22, zhong jiang a écrit :
>>>> On 2019/1/19 0:24, Laurent Dufour wrote:
>>>>> Le 17/01/2019 à 16:51, zhong jiang a écrit :
>>>>>> On 2019/1/16 19:41, Vinayak Menon wrote:
>>>>>>> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>>>>>>>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>>>>>>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>>>>>>>> Hi Laurent,
>>>>>>>>>>
>>>>>>>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>>>>>>>
>>>>>>>>> With the patch below, we don't hit the issue.
>>>>>>>>>
>>>>>>>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>>>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>>>>>>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>>>>>>>
>>>>>>>>> It is observed that the following scenario results in
>>>>>>>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>>>>>>>> forever after few iterations.
>>>>>>>>>
>>>>>>>>> CPU 1                   CPU 2                    CPU 3
>>>>>>>>> Process 1,              Process 1,               Process 1,
>>>>>>>>> Thread A                Thread B                 Thread C
>>>>>>>>>
>>>>>>>>> while (1) {             while (1) {              while(1) {
>>>>>>>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>>>>>>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>>>>>>>> }                       }
>>>>>>>>>
>>>>>>>>> When from thread C, copy_one_pte write-protects the parent pte
>>>>>>>>> (of lock l), stale tlb entries can exist with write permissions
>>>>>>>>> on one of the CPUs at least. This can create a problem if one
>>>>>>>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>>>>>>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>>>>>>>> does not take mmap_sem it can proceed further fixing a fault soon
>>>>>>>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>>>>>>>> entry can still modify old_page even after it is copied to
>>>>>>>>> new_page by wp_page_copy, thus causing a corruption.
>>>>>>>> Nice catch and thanks for your investigation!
>>>>>>>>
>>>>>>>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>>>>>>>
>>>>>>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>>>>> ---
>>>>>>>>>      mm/memory.c | 7 +++++++
>>>>>>>>>      1 file changed, 7 insertions(+)
>>>>>>>>>
>>>>>>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>>>>>>> index 52080e4..1ea168ff 100644
>>>>>>>>> --- a/mm/memory.c
>>>>>>>>> +++ b/mm/memory.c
>>>>>>>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>>>>>>>                     return VM_FAULT_RETRY;
>>>>>>>>>             }
>>>>>>>>>
>>>>>>>>> +       /*
>>>>>>>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>>>>>>>> +        * in copy_one_pte
>>>>>>>>> +        */
>>>>>>>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>>>>>>> +               flush_tlb_page(vmf.vma, address);
>>>>>>>>> +
>>>>>>>>>             mem_cgroup_oom_enable();
>>>>>>>>>             ret = handle_pte_fault(&vmf);
>>>>>>>>>             mem_cgroup_oom_disable();
>>>>>>>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>>>>>>>
>>>>>>>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
>>>>>>>
>>>>>>> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?
>>>>>>>
>>>>>>>
>>>>>>>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>>>>>>>
>>>>>>> Your patch works fine on arm64 with a minor change. Thanks Laurent.
>>>>>> Hi, Vinayak and Laurent
>>>>>>
>>>>>> I think the below change will impact the performance significantly. Becuase most of process has many
>>>>>> vmas with cow flags. Flush the tlb in advance is not the better way to avoid the issue and it will
>>>>>> call the flush_tlb_mm  later.
>>>>>>
>>>>>> I think we can try the following way to do.
>>>>>>
>>>>>> vm_write_begin(vma)
>>>>>> copy_pte_range
>>>>>> vm_write_end(vma)
>>>>>>
>>>>>> The speculative page fault will return to grap the mmap_sem to run the nromal path.
>>>>>> Any thought?
>>>>>
>>>>> Here is a new version of the patch fixing this issue. There is no additional TLB flush, all the fix is belonging on vm_write_{begin,end} calls.
>>>>>
>>>>> I did some test on x86_64 and PowerPC but that needs to be double check on arm64.
>>>>>
>>>>> Vinayak, Zhong, could you please give it a try ?
>>>>>
>>>> Hi Laurent
>>>>
>>>> I apply the patch you had attached and none of any abnormal thing came in two days. It is feasible to fix the issue.
>>>
>>> Good news !
>>>
>>>>
>>>> but It will better to filter the condition by is_cow_mapping. is it right?
>>>>
>>>> for example:
>>>>
>>>> if (is_cow_mapping(mnpt->vm_flags)) {
>>>>              ........
>>>> }
>>>
>>> That's doable for sure but I don't think this has to be introduce in dup_mmap().
>>> Unless there is a real performance benefit to do so, I don't think dup_mmap() has to mimic underlying checks done in copy_page_range().
>>>
>>
>> Hi, Laurent
>>
>> I test the performace with microbench after appling the patch. I find
>> the page fault latency will increase about 8% than before.  I think we
>> should use is_cow_mapping to waken the impact and I will try it out.
>
> That's interesting,  I would not expect such a higher latency assuming that most of the area not in copied on write are also not managed by the speculative page fault handler (file mapping, etc.). Anyway I'm looking forward to see the result with additional is_cow_mapping() check.
>
I test the performance again. It is the protect error access latency in lat_sig.c that it will result in a drop of 8% in that testcase.
The page fault latency, In fact, does not impact the performace. It seems to just the fluctuation.

Thanks,
zhong jiang
>> or we can use the following solution to replace as Vinayak has said.
>>
>> if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>      return VM_FAULT_RETRY;
>>
>> Even though it will influence the performance of SPF, but at least it does
>> not bring in any negative impact. Any thought?
>
> I don't agree, this checks will completely by pass the SPF handler for all the COW areas, even if there is no race situation.
>
> Cheers,
> Laurent.
>>
>> Thanks,
>>
>>
>>> Cheers,
>>> Laurent.
>>>
>>>
>>> .
>>>
>>
>>
>
>
>


