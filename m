Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5762C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:49:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CD982146F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:49:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CD982146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE5278E0003; Thu,  7 Mar 2019 14:49:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6D568E0002; Thu,  7 Mar 2019 14:49:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0D728E0003; Thu,  7 Mar 2019 14:49:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 923678E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 14:49:29 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n186so846574qke.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 11:49:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=kiztqygo9lkP6uWLypzYiA12THup8wUNQqJHcivnFAc=;
        b=PeZvHaNfpdnTuOh0Ov/qHO69W7usLZ4li3w3ywSiv+7ePpZYsUPBU2sTeOCbD9ncXQ
         CZQeIkEwXmJ4UZJ78kdjwXmlLJVSROk69Z252frqEyHr4I9wgmQgBOBtepkMiwly1li2
         R1Ui2ANwWz+jJ2TbajbbVED421WCN9Znhb73v80pr7Ki2wBETT9NvIbugCcpwXzKAtUY
         lZGyUzi36RUHBus2vTogRpjimJiCcXDirdkV9hXCl9+We3NHIjfRwOsjvzT0Drw8TMOu
         qBZ07cgAoe6o7DVX6I7JycbX8IXOpC5xok+usEPfFNjqU6piUa5ONJ57xypblbGcfELs
         QcSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXVbedAcpYUFcnhiqYXMWtucnf+bkAm4GYYyEoIKRGnfINU6H0D
	5r+k1qFS+3MlcfAYG++rgbSaaUPNk5zsi32BDTnhQwdJwTkoiMkVHC52pRqCmZ0nfdfMjwsbFEi
	cwZYdEvnJO2THJxYuTbdvFZ9TO6DSyMu6JZwvTy1ijoP2ETyARuil7g/TRjyUKewvNQ==
X-Received: by 2002:ac8:5157:: with SMTP id h23mr11955412qtn.370.1551988169301;
        Thu, 07 Mar 2019 11:49:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqxXo+CMLzf7mALmneC+yP9YQof+BpiUiq+LsUt64Y/kjMx/UBBSGvvOU2+3Z6EBfEOEnPav
X-Received: by 2002:ac8:5157:: with SMTP id h23mr11955333qtn.370.1551988168011;
        Thu, 07 Mar 2019 11:49:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551988168; cv=none;
        d=google.com; s=arc-20160816;
        b=Rudw//9QxpiNfs/7rbEnHgBa6YSs8+q6AdpyxC7bl6ZBV8Ddc/7W0FoFWwFdG6BOUg
         WcuMQSnVk3U5FploKcJLn5IMTJD2sBuJv/BL3SpQLvx0EY54yt7xW8YbkJHhZhdvUBC5
         Afg0a7t5i2Pco0Zw++Lj+t+UpjvrGYvh4bZbliRt7XAnupj8lq20PBH05tWumeu0SEGx
         ARcUkK7ZUg+c04zXKaY3ZPQq66Xz5cDqu51EhpNYtlqhZ28dNk0eY/DbDMz+WUP4Va5R
         p4QoFUQ2DJMj4CfGIum5wy811lWpzj1OONJPSNu9dV7Ov0eHGYdo4746orKLsIfrZsuD
         JbBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=kiztqygo9lkP6uWLypzYiA12THup8wUNQqJHcivnFAc=;
        b=l05vZY8LMHs6XhI1MBMc9ZLK0uQ3gLnH+usRxc5J8BnhwoCMMzJN0NCKUgr3tZye4e
         AfQtMaEDZF2daADGHVY4UI2yGJalW9tFdLeNWwjl68CO/Clq8eXq6F4TNBLmDoU6m1Hh
         OX691jsBDpX/BPCoShjlOGbvV5rEUittYGVd10SS4dVUZJakSOvhumw7FYgbXFFCMXYJ
         1H25wHFYi1AY6ZCtAv8rYqKKs2kKlZmmpIkYf9K9uqxylqFQxO4Pn03IdWbBKDS7ACY6
         yt09aKGEge0yc7XKJ42V9ReNqdqiMUwhGDPpH56H6MCXiVib2VKer9V6EoaIPEwdOHNn
         1YyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n21si3463177qvc.65.2019.03.07.11.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 11:49:28 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 312613087BB0;
	Thu,  7 Mar 2019 19:49:27 +0000 (UTC)
Received: from [10.36.116.67] (ovpn-116-67.ams2.redhat.com [10.36.116.67])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D1EF85D9C9;
	Thu,  7 Mar 2019 19:49:17 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Alexander Duyck <alexander.duyck@gmail.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
 <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
 <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <e234c51b-cdd5-08b6-6b6f-5d48c4b2e91e@redhat.com>
Date: Thu, 7 Mar 2019 20:49:16 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 07 Mar 2019 19:49:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.03.19 19:45, Alexander Duyck wrote:
> On Thu, Mar 7, 2019 at 5:09 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>
>>
>> On 3/6/19 5:05 PM, Alexander Duyck wrote:
>>> On Wed, Mar 6, 2019 at 11:07 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>>>
>>>> On 3/6/19 1:00 PM, Alexander Duyck wrote:
>>>>> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>>>>> The following patch-set proposes an efficient mechanism for handing freed memory between the guest and the host. It enables the guests with no page cache to rapidly free and reclaims memory to and from the host respectively.
>>>>>>
>>>>>> Benefit:
>>>>>> With this patch-series, in our test-case, executed on a single system and single NUMA node with 15GB memory, we were able to successfully launch 5 guests(each with 5 GB memory) when page hinting was enabled and 3 without it. (Detailed explanation of the test procedure is provided at the bottom under Test - 1).
>>>>>>
>>>>>> Changelog in v9:
>>>>>>         * Guest free page hinting hook is now invoked after a page has been merged in the buddy.
>>>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(currently defined as MAX_ORDER - 1) are captured.
>>>>>>         * Removed kthread which was earlier used to perform the scanning, isolation & reporting of free pages.
>>>>> Without a kthread this has the potential to get really ugly really
>>>>> fast. If we are going to run asynchronously we should probably be
>>>>> truly asynchonous and just place a few pieces of data in the page that
>>>>> a worker thread can use to identify which pages have been hinted and
>>>>> which pages have not.
>>>> Can you please explain what do you mean by truly asynchronous?
>>>>
>>>> With this implementation also I am not reporting the pages synchronously.
>>> The problem is you are making it pseudo synchronous by having to push
>>> pages off to a side buffer aren't you? In my mind we should be able to
>>> have the page hinting go on with little to no interference with
>>> existing page allocation and freeing.
>> We have to opt one of the two options:
>> 1. Block allocation by using a flag or acquire a lock to prevent the
>> usage of pages we are hinting.
>> 2. Remove the page set entirely from the buddy. (This is what I am doing
>> right now)
>>
>> The reason I would prefer the second approach is that we are not
>> blocking the allocation in any way and as we are only working with a
>> smaller set of pages we should be fine.
>> However, with the current approach as we are reporting asynchronously
>> there is a chance that we end up hinting more than 2-3 times for a
>> single workload run. In situation where this could lead to low memory
>> condition in the guest, the hinting will anyways fail as the guest will
>> not allow page isolation.
>> I can possibly try and test the same to ensure that we don't get OOM due
>> to hinting when the guest is under memory pressure.
> 
> So in either case you are essentially blocking allocation since the
> memory cannot be used. My concern is more with guaranteeing forward
> progress for as many CPUs as possible.
> 
> With your current design you have one minor issue in that you aren't
> taking the lock to re-insert the pages back into the buddy allocator.
> When you add that step in it means you are going to be blocking
> allocation on that zone while you are reinserting the pages.
> 
> Also right now you are using the calls to free_one_page to generate a
> list of hints where to search. I'm thinking that may not be the best
> approach since what we want to do is provide hints on idle free pages,
> not just pages that will be free for a short period of time.
> 
> To that end what I think w may want to do is instead just walk the LRU
> list for a given zone/order in reverse order so that we can try to
> identify the pages that are most likely to be cold and unused and
> those are the first ones we want to be hinting on rather than the ones
> that were just freed. If we can look at doing something like adding a
> jiffies value to the page indicating when it was last freed we could
> even have a good point for determining when we should stop processing
> pages in a given zone/order list.
> 
> In reality the approach wouldn't be too different from what you are
> doing now, the only real difference would be that we would just want
> to walk the LRU list for the given zone/order rather then pulling
> hints on what to free from the calls to free_one_page. In addition we
> would need to add a couple bits to indicate if the page has been
> hinted on, is in the middle of getting hinted on, and something such
> as the jiffies value I mentioned which we could use to determine how
> old the page is.
> 
>>>
>>>>> Then we can have that one thread just walking
>>>>> through the zone memory pulling out fixed size pieces at a time and
>>>>> providing hints on that. By doing that we avoid the potential of
>>>>> creating a batch of pages that eat up most of the system memory.
>>>>>
>>>>>>         * Pages, captured in the per cpu array are sorted based on the zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>>>         * Dynamically allocated space is used to hold the isolated guest free pages.
>>>>> I have concerns that doing this per CPU and allocating memory
>>>>> dynamically can result in you losing a significant amount of memory as
>>>>> it sits waiting to be hinted.
>>>> It should not as the buddy will keep merging the pages and we are only
>>>> capturing MAX_ORDER - 1.
>>>> This was the issue with the last patch-series when I was capturing all
>>>> order pages resulting in the per-cpu array to be filled with lower order
>>>> pages.
>>>>>>         * All the pages are reported asynchronously to the host via virtio driver.
>>>>>>         * Pages are returned back to the guest buddy free list only when the host response is received.
>>>>> I have been thinking about this. Instead of stealing the page couldn't
>>>>> you simply flag it that there is a hint in progress and simply wait in
>>>>> arch_alloc_page until the hint has been processed?
>>>> With the flag, I am assuming you mean to block the allocation until
>>>> hinting is going on, which is an issue. That was one of the issues
>>>> discussed earlier which I wanted to solve with this implementation.
>>> With the flag we would allow the allocation, but would have to
>>> synchronize with the hinting at that point. I got the idea from the
>>> way the s390 code works. They have both an arch_free_page and an
>>> arch_alloc_page. If I understand correctly the arch_alloc_page is what
>>> is meant to handle the case of a page that has been marked for
>>> hinting, but may not have been hinted on yet. My thought for now is to
>>> keep it simple and use a page flag to indicate that a page is
>>> currently pending a hint.
>> I am assuming this page flag will be located in the page structure.
>>> We should be able to spin in such a case and
>>> it would probably still perform better than a solution where we would
>>> not have the memory available and possibly be under memory pressure.
>> I had this same idea earlier. However, the thing about which I was not
>> sure is if adding a flag in the page structure will be acceptable upstream.
>>>
>>>>> The problem is in
>>>>> stealing pages you are going to introduce false OOM issues when the
>>>>> memory isn't available because it is being hinted on.
>>>> I think this situation will arise when the guest is under memory
>>>> pressure. In such situations any attempt to perform isolation will
>>>> anyways fail and we may not be reporting anything at that time.
>>> What I want to avoid is the scenario where an application grabs a
>>> large amount of memory, then frees said memory, and we are sitting on
>>> it for some time because we decide to try and hint on the large chunk.
>> I agree.
>>> By processing this sometime after the pages are sent to the buddy
>>> allocator in a separate thread, and by processing a small fixed window
>>> of memory at a time we can avoid making freeing memory expensive, and
>>> still provide the hints in a reasonable time frame.
>>
>> My impression is that the current window on which I am working may give
>> issues for smaller size guests. But otherwise, we are already working
>> with a smaller fixed window of memory.
>>
>> I can further restrict this to just 128 entries and test which would
>> bring down the window of memory. Let me know what you think.
> 
> The problem is 128 entries is still pretty big when you consider you
> are working with 4M pages. If I am not mistaken that is a half
> gigabyte of memory. For lower order pages 128 would probably be fine,
> but with the higher order pages we may want to contain things to
> something smaller like 16MB to 64MB worth of memory.
>

I agree, I also still consider it too big for 4MB pages. It would be
different e.g. for 128KB pages.

-- 

Thanks,

David / dhildenb

