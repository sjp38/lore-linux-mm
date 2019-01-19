Return-Path: <SRS0=Ztt1=P3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EA95C61CE8
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 17:06:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D40B2084F
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 17:06:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D40B2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 877368E0003; Sat, 19 Jan 2019 12:06:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 826C68E0002; Sat, 19 Jan 2019 12:06:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73ED88E0003; Sat, 19 Jan 2019 12:06:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4145E8E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 12:06:00 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id c201so7687530vsd.4
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 09:06:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=hPZrItUXd2H0WcwlY6Ng1Q7UljN2zVyzpIW25JQnrbY=;
        b=Ya8tQf8BlX4s25FiOUcfv06MGYB7tO369aWZb+iTUQQnY6YAZngF4uuv/LpjHzMxFE
         ywGdTqlXiLmzx4mJ0dMkefz6acyXe6Q/2QVpCyQWBygkSOBxgHs7Wmbh7Tcng2mMuQXR
         dni/zrAKnyO5JH/HUK7p8UIeXBDu19Gp9L07xdRa8g2V59Aqh92YDx3v/qbRzywjWeir
         Ivnpk7RSVIem62JH/gfnwM+uNE6UPc3852ilwKM4R0dHMo2N10SS8HYjL60LZ0DUjeXJ
         l9LylwA3U2jstvA8OcFclhcVT+pH9BEO2tBJIhMTZVL2OHxgGE8hZOkIEpW8WI/7u1no
         iHcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: AJcUukcMRXOCCaEst7J66586yAF+WlS7JtPnPU6Pm5vtuStcqtI9RWEo
	PgKLcVc+FnzDuYOfxaCFg8vEtAOZEbOgD0DMHlleiFn+qTA76P5lH8gDTFzf/HCxmEW+4nPNdzf
	iuQcawrVKHeAxEnF+dPd5j+gn+3Nu7O7IzDVKXpMDT/x2PyZ9pBf2nCN7pPnrjOeeLA==
X-Received: by 2002:a1f:7d02:: with SMTP id y2mr4578220vkc.62.1547917559865;
        Sat, 19 Jan 2019 09:05:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5/OReB0RoIqMEpyGcmEFmMkGbr79lSZmiobx3XSO/k2TWBqQcDeMa0U/HZYgk3Tlf6svFB
X-Received: by 2002:a1f:7d02:: with SMTP id y2mr4578204vkc.62.1547917559115;
        Sat, 19 Jan 2019 09:05:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547917559; cv=none;
        d=google.com; s=arc-20160816;
        b=ub9GHpkbpjkxygBxHN7DfExuGii+ae0gidmDQEZ0A0Q5xUQcWDbmhFtox79N8toiIs
         aKme2M4DfnlbMTgfMSDyQ4MaEaO8dfmqpHkjKRO1n/rqH23axY16A0YnZQx8TnpjhzAi
         7m8GamWDs15lh3xoTFnZqHK5t2jvEVSXpWxJaH4USFPg2WRkOYhmfHX/r3zRKMBuO541
         MCs4RS1rG6YWMwGTcYLp9RMSOWQL4PGLwS1O0/XIOQEEf1vb657vm1wVSek3+rs4Ngoz
         f7h9/QcV2VoDahrckEGJbJPjXIIPX4ur1Sq+rwz1egscvYBvRuANf+Q3x/D44DCVvA5d
         aM+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=hPZrItUXd2H0WcwlY6Ng1Q7UljN2zVyzpIW25JQnrbY=;
        b=iy5FbeJ+DNcxBE7cZXbbft5znpj+07VTUDBSEbbdbW4j49BS6ij7m1fAoxyDrXKbZH
         gc9dQSGAg0mtanGkFAKkAGQ9f2Webl90uYe1MvLscVUSEkKlRhuWVzG/gw+cQ62ugCHm
         Tj7sowaUHlv4NNiRxs6rmWu9icV9h1VV+46Y1TG+8bykEpkw1bLpFK/Rle15X1lGE8wy
         4E9XjWpnQfxyWS9NJ33CqfSTN8W4w0GJH21xEtnWi7Zn6hiiYiA/HCZO2JpctRYe2W7V
         nr8F5wjiAlRmdrQ8+hksedmDnhZI2IHOxR3v8uX0Li5IZeP8kFSODXLJ8SiXmVygg768
         4z7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id 78si5648677uav.234.2019.01.19.09.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Jan 2019 09:05:59 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 0A3BDBE72D27548D7AB7;
	Sun, 20 Jan 2019 01:05:55 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Sun, 20 Jan 2019
 01:05:54 +0800
Message-ID: <5C4358F1.1080505@huawei.com>
Date: Sun, 20 Jan 2019 01:05:53 +0800
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
Message-ID: <20190119170553.UScSi21nIn9FErwK5_dq71KwaUjn2h7Sy4tYWiySr3g@z>

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
Thanks, look good to me. I will try it.

Sincerely,
zhong jiang
> Thanks,
> Laurent.
>


