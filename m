Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 194E3C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:45:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC84820675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:45:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC84820675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5596B8E0003; Thu,  7 Mar 2019 14:45:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50BAA8E0002; Thu,  7 Mar 2019 14:45:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D32A8E0003; Thu,  7 Mar 2019 14:45:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 077488E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 14:45:56 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w134so14003487qka.6
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 11:45:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=kwe10XD6CXdFn9PHpd74/8C85F3JIaiGDY0WLToDMnk=;
        b=RBh18OJeX04MCN9Olk0529stXkszNG32Xlw1ja3DIMI80H8c7CVlUIM/Q6/7PxpkLo
         9hr0B01iESTNWvTr2e+TBQTkhttvoO87CrCCWauNFX5pBip8k5O5TRsVeyZEpMFSlCHf
         oh3mOsQgShe6tMnJCmDHMIX1Djah+B2+zuJWSFY27zfeqrFYAuFqT6izep5Nh+syQ+pA
         W+X86nhMKCXFIkyWXFoaGFr7oZcEy0zWZXgFPEwsXJ6ALlpWnyC1caylhWru7UOQ4p+S
         QyT18egICMGiOfJoFsXMsm4ZaZItIszpstisrGKHdNnPMCHcdSFkBy1pnjKtfIRAwL+s
         tADw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXVEGvdJhSjikBlnNFCB+N7ULFTAEvBqiuImQhhE0m+PaHqaKGh
	yFa4wV+4iNLl5TJkWhMmtg3B7Ce1MK8LDhCil1SgYbtEydkh9qxbop9IIkXoRt1jL9y82PTC6gP
	EfNRIjUAy8dEHM9YW+1YYCwzmiEBLq6vUQrohaUhwTjEBgMTMOkzJn08Co9KFpW6odA==
X-Received: by 2002:a0c:b64a:: with SMTP id q10mr11871821qvf.6.1551987955709;
        Thu, 07 Mar 2019 11:45:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqz+kkUmI+cUzp76r+GhvwshDbnGIYam9KzQkGylEg+AF8VOAddRdi4IFJtJfUX4gCoexhU+
X-Received: by 2002:a0c:b64a:: with SMTP id q10mr11871741qvf.6.1551987954085;
        Thu, 07 Mar 2019 11:45:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551987954; cv=none;
        d=google.com; s=arc-20160816;
        b=C8OJMa12VepPgfIqoXTd6mvKUCsI374VdvARl8EVmil9J75EaJjaychJ8qqonVQbYI
         BX7B16Tlhd01RlL6wjI92D4vrFS+b+h08IVaJM0Fz0UVm9h3TDvNB7aWpOBySfBLdnPE
         e+/ZpVBDlps/rhsUnqnBs5rfZoEGpFSKehr/wEkSp9SX6o5mcyw7XRJAcEGE1ifJEsyC
         sfckdZHdS68a4mlUa50/RmB5/hL8ysdfgInFt8JtltipjbH/fEoFie8ThBn9kV4TmlJP
         qDIZVWtXjPpgiMx9hoAl1Js5VvX5Gjzm1J91Y9dYelVEMDFylLPJmoZa8Awkd/VQzLQY
         ojrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=kwe10XD6CXdFn9PHpd74/8C85F3JIaiGDY0WLToDMnk=;
        b=F3VPwq3Vu60XW19y0pjt+YI0UuXRIxbpQxr5HOVnl2OouF9kMQSZsfi8zuDyF0nolJ
         1716rESKOnJUcD+KBhkqgWduK9CNTBc9bN0no8C/jPS+OviWhiB8yrRx/mU5mgJH9EyV
         dV46YnmapN6KfZGJX9SQL/UTpWU3m1EKtUMQIJySlKcW7ZlfMShSlqHbKS06/Yvbz5lB
         35VPrmiFBaXrXBHQOPcBH4Id1OlCwPtz/kA/QvSSulM43sOPl+MHv5HZyDKd9ceduIqP
         zOAqafGSRzBxQnAmIOzBe4fWMEYrIMk2pvnsc3ESxxrSeTli9LioIZDzRiKqOR51uYnU
         BbCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m61si3375802qte.390.2019.03.07.11.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 11:45:54 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 32982301E11D;
	Thu,  7 Mar 2019 19:45:53 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C67405C545;
	Thu,  7 Mar 2019 19:45:42 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
 <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
 <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <cb8daeef-40a0-4a09-bfd7-61b5822762cd@redhat.com>
Date: Thu, 7 Mar 2019 14:45:41 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="bWBqOMw8AtsTm9gbha5w36I2jNHleutzD"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 07 Mar 2019 19:45:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bWBqOMw8AtsTm9gbha5w36I2jNHleutzD
Content-Type: multipart/mixed; boundary="y4cVQaPmAucBZLncBWuX4eW6Ewy8T9UtR";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <cb8daeef-40a0-4a09-bfd7-61b5822762cd@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
 <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
 <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
In-Reply-To: <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>

--y4cVQaPmAucBZLncBWuX4eW6Ewy8T9UtR
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/7/19 1:45 PM, Alexander Duyck wrote:
> On Thu, Mar 7, 2019 at 5:09 AM Nitesh Narayan Lal <nitesh@redhat.com> w=
rote:
>>
>> On 3/6/19 5:05 PM, Alexander Duyck wrote:
>>> On Wed, Mar 6, 2019 at 11:07 AM Nitesh Narayan Lal <nitesh@redhat.com=
> wrote:
>>>> On 3/6/19 1:00 PM, Alexander Duyck wrote:
>>>>> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.co=
m> wrote:
>>>>>> The following patch-set proposes an efficient mechanism for handin=
g freed memory between the guest and the host. It enables the guests with=
 no page cache to rapidly free and reclaims memory to and from the host r=
espectively.
>>>>>>
>>>>>> Benefit:
>>>>>> With this patch-series, in our test-case, executed on a single sys=
tem and single NUMA node with 15GB memory, we were able to successfully l=
aunch 5 guests(each with 5 GB memory) when page hinting was enabled and 3=
 without it. (Detailed explanation of the test procedure is provided at t=
he bottom under Test - 1).
>>>>>>
>>>>>> Changelog in v9:
>>>>>>         * Guest free page hinting hook is now invoked after a page=
 has been merged in the buddy.
>>>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(c=
urrently defined as MAX_ORDER - 1) are captured.
>>>>>>         * Removed kthread which was earlier used to perform the sc=
anning, isolation & reporting of free pages.
>>>>> Without a kthread this has the potential to get really ugly really
>>>>> fast. If we are going to run asynchronously we should probably be
>>>>> truly asynchonous and just place a few pieces of data in the page t=
hat
>>>>> a worker thread can use to identify which pages have been hinted an=
d
>>>>> which pages have not.
>>>> Can you please explain what do you mean by truly asynchronous?
>>>>
>>>> With this implementation also I am not reporting the pages synchrono=
usly.
>>> The problem is you are making it pseudo synchronous by having to push=

>>> pages off to a side buffer aren't you? In my mind we should be able t=
o
>>> have the page hinting go on with little to no interference with
>>> existing page allocation and freeing.
>> We have to opt one of the two options:
>> 1. Block allocation by using a flag or acquire a lock to prevent the
>> usage of pages we are hinting.
>> 2. Remove the page set entirely from the buddy. (This is what I am doi=
ng
>> right now)
>>
>> The reason I would prefer the second approach is that we are not
>> blocking the allocation in any way and as we are only working with a
>> smaller set of pages we should be fine.
>> However, with the current approach as we are reporting asynchronously
>> there is a chance that we end up hinting more than 2-3 times for a
>> single workload run. In situation where this could lead to low memory
>> condition in the guest, the hinting will anyways fail as the guest wil=
l
>> not allow page isolation.
>> I can possibly try and test the same to ensure that we don't get OOM d=
ue
>> to hinting when the guest is under memory pressure.
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
>>>>> Then we can have that one thread just walking
>>>>> through the zone memory pulling out fixed size pieces at a time and=

>>>>> providing hints on that. By doing that we avoid the potential of
>>>>> creating a batch of pages that eat up most of the system memory.
>>>>>
>>>>>>         * Pages, captured in the per cpu array are sorted based on=
 the zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>>>         * Dynamically allocated space is used to hold the isolated=
 guest free pages.
>>>>> I have concerns that doing this per CPU and allocating memory
>>>>> dynamically can result in you losing a significant amount of memory=
 as
>>>>> it sits waiting to be hinted.
>>>> It should not as the buddy will keep merging the pages and we are on=
ly
>>>> capturing MAX_ORDER - 1.
>>>> This was the issue with the last patch-series when I was capturing a=
ll
>>>> order pages resulting in the per-cpu array to be filled with lower o=
rder
>>>> pages.
>>>>>>         * All the pages are reported asynchronously to the host vi=
a virtio driver.
>>>>>>         * Pages are returned back to the guest buddy free list onl=
y when the host response is received.
>>>>> I have been thinking about this. Instead of stealing the page could=
n't
>>>>> you simply flag it that there is a hint in progress and simply wait=
 in
>>>>> arch_alloc_page until the hint has been processed?
>>>> With the flag, I am assuming you mean to block the allocation until
>>>> hinting is going on, which is an issue. That was one of the issues
>>>> discussed earlier which I wanted to solve with this implementation.
>>> With the flag we would allow the allocation, but would have to
>>> synchronize with the hinting at that point. I got the idea from the
>>> way the s390 code works. They have both an arch_free_page and an
>>> arch_alloc_page. If I understand correctly the arch_alloc_page is wha=
t
>>> is meant to handle the case of a page that has been marked for
>>> hinting, but may not have been hinted on yet. My thought for now is t=
o
>>> keep it simple and use a page flag to indicate that a page is
>>> currently pending a hint.
>> I am assuming this page flag will be located in the page structure.
>>> We should be able to spin in such a case and
>>> it would probably still perform better than a solution where we would=

>>> not have the memory available and possibly be under memory pressure.
>> I had this same idea earlier. However, the thing about which I was not=

>> sure is if adding a flag in the page structure will be acceptable upst=
ream.
>>>>> The problem is in
>>>>> stealing pages you are going to introduce false OOM issues when the=

>>>>> memory isn't available because it is being hinted on.
>>>> I think this situation will arise when the guest is under memory
>>>> pressure. In such situations any attempt to perform isolation will
>>>> anyways fail and we may not be reporting anything at that time.
>>> What I want to avoid is the scenario where an application grabs a
>>> large amount of memory, then frees said memory, and we are sitting on=

>>> it for some time because we decide to try and hint on the large chunk=
=2E
>> I agree.
>>> By processing this sometime after the pages are sent to the buddy
>>> allocator in a separate thread, and by processing a small fixed windo=
w
>>> of memory at a time we can avoid making freeing memory expensive, and=

>>> still provide the hints in a reasonable time frame.
>> My impression is that the current window on which I am working may giv=
e
>> issues for smaller size guests. But otherwise, we are already working
>> with a smaller fixed window of memory.
>>
>> I can further restrict this to just 128 entries and test which would
>> bring down the window of memory. Let me know what you think.
> The problem is 128 entries is still pretty big when you consider you
> are working with 4M pages. If I am not mistaken that is a half
> gigabyte of memory. For lower order pages 128 would probably be fine,
> but with the higher order pages we may want to contain things to
> something smaller like 16MB to 64MB worth of memory.
This is something with which we can certainly play around or may even
make configurable.
For now, I think I will continue testing with 128.
>
>>>>>> Pending items:
>>>>>>         * Make sure that the guest free page hinting's current imp=
lementation doesn't break hugepages or device assigned guests.
>>>>>>         * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side =
support. (It is currently missing)
>>>>>>         * Compare reporting free pages via vring with vhost.
>>>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>>>>         * Analyze overall performance impact due to guest free pag=
e hinting.
>>>>>>         * Come up with proper/traceable error-message/logs.
>>>>> I'll try applying these patches and see if I can reproduce the resu=
lts
>>>>> you reported.
>>>> Thanks. Let me know if you run into any issues.
>>>>> With the last patch set I couldn't reproduce the results
>>>>> as you reported them.
>>>> If I remember correctly then the last time you only tried with multi=
ple
>>>> vcpus and not with 1 vcpu.
>>> I had tried 1 vcpu, however I ended up running into some other issues=

>>> that made it difficult to even boot the system last week.
>>>
>>>>> It has me wondering if you were somehow seeing
>>>>> the effects of a balloon instead of the actual memory hints as I
>>>>> couldn't find any evidence of the memory ever actually being freed
>>>>> back by the hints functionality.
>>>> Can you please elaborate what kind of evidence you are looking for?
>>>>
>>>> I did trace the hints on the QEMU/host side.
>>> It looks like the new patches are working as I am seeing the memory
>>> freeing occurring this time around. Although it looks like this is
>>> still generating traces from free_pcpages_bulk if I enable multiple
>>> VCPUs:
>> I am assuming with the changes you suggested you were able to run this=

>> patch-series. Is that correct?
> Yes, I got it working by disabling SMP. I think I found and pointed
> out the issue in your other patch where you were using __free_one_page
> without holding the zone lock.
Yeah. Thanks.
>
>>> [  175.823539] list_add corruption. next->prev should be prev
>>> (ffff947c7ffd61e0), but was ffffc7a29f9e0008. (next=3Dffffc7a29f4c000=
8).
>>> [  175.825978] ------------[ cut here ]------------
>>> [  175.826889] kernel BUG at lib/list_debug.c:25!
>>> [  175.827766] invalid opcode: 0000 [#1] SMP PTI
>>> [  175.828621] CPU: 5 PID: 1344 Comm: page_fault1_thr Not tainted
>>> 5.0.0-next-20190306-baseline+ #76
>>> [  175.830312] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),=

>>> BIOS Bochs 01/01/2011
>>> [  175.831885] RIP: 0010:__list_add_valid+0x35/0x70
>>> [  175.832784] Code: 18 48 8b 32 48 39 f0 75 39 48 39 c7 74 1e 48 39
>>> fa 74 19 b8 01 00 00 00 c3 48 89 c1 48 c7 c7 80 b5 0f a9 31 c0 e8 8f
>>> aa c8 ff <0f> 0b 48 89 c1 48 89 fe 31 c0 48 c7 c7 30 b6 0f a9 e8 79 a=
a
>>> c8 ff
>>> [  175.836379] RSP: 0018:ffffa717c40839b0 EFLAGS: 00010046
>>> [  175.837394] RAX: 0000000000000075 RBX: ffff947c7ffd61e0 RCX: 00000=
00000000000
>>> [  175.838779] RDX: 0000000000000000 RSI: ffff947c5f957188 RDI: ffff9=
47c5f957188
>>> [  175.840162] RBP: ffff947c7ffd61d0 R08: 000000000000026f R09: 00000=
00000000005
>>> [  175.841539] R10: 0000000000000000 R11: ffffa717c4083730 R12: ffffc=
7a29f260008
>>> [  175.842932] R13: ffff947c7ffd5d00 R14: ffffc7a29f4c0008 R15: ffffc=
7a29f260000
>>> [  175.844319] FS:  0000000000000000(0000) GS:ffff947c5f940000(0000)
>>> knlGS:0000000000000000
>>> [  175.845896] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> [  175.847009] CR2: 00007fffe3421000 CR3: 000000051220e006 CR4: 00000=
00000160ee0
>>> [  175.848390] Call Trace:
>>> [  175.848896]  free_pcppages_bulk+0x4bc/0x6a0
>>> [  175.849723]  free_unref_page_list+0x10d/0x190
>>> [  175.850567]  release_pages+0x103/0x4a0
>>> [  175.851313]  tlb_flush_mmu_free+0x36/0x50
>>> [  175.852105]  unmap_page_range+0x963/0xd50
>>> [  175.852897]  unmap_vmas+0x62/0xc0
>>> [  175.853549]  exit_mmap+0xb5/0x1a0
>>> [  175.854205]  mmput+0x5b/0x120
>>> [  175.854794]  do_exit+0x273/0xc30
>>> [  175.855426]  ? free_unref_page_commit+0x85/0xf0
>>> [  175.856312]  do_group_exit+0x39/0xa0
>>> [  175.857018]  get_signal+0x172/0x7c0
>>> [  175.857703]  do_signal+0x36/0x620
>>> [  175.858355]  ? percpu_counter_add_batch+0x4b/0x60
>>> [  175.859280]  ? __do_munmap+0x288/0x390
>>> [  175.860020]  exit_to_usermode_loop+0x4c/0xa8
>>> [  175.860859]  do_syscall_64+0x152/0x170
>>> [  175.861595]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>> [  175.862586] RIP: 0033:0x7ffff76a8ec7
>>> [  175.863292] Code: Bad RIP value.
>>> [  175.863928] RSP: 002b:00007ffff4422eb8 EFLAGS: 00000212 ORIG_RAX:
>>> 000000000000000b
>>> [  175.865396] RAX: 0000000000000000 RBX: 00007ffff7ff7280 RCX: 00007=
ffff76a8ec7
>>> [  175.866799] RDX: 00007fffe3422000 RSI: 0000000008000000 RDI: 00007=
fffdb422000
>>> [  175.868194] RBP: 0000000000001000 R08: ffffffffffffffff R09: 00000=
00000000000
>>> [  175.869582] R10: 0000000000000022 R11: 0000000000000212 R12: 00007=
ffff4422fc0
>>> [  175.870984] R13: 0000000000000001 R14: 00007fffffffc1b0 R15: 00007=
ffff44239c0
>>> [  175.872350] Modules linked in: ip6t_rpfilter ip6t_REJECT
>>> nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat
>>> ebtable_broute bridge stp llc ip6table_nat ip6table_mangle
>>> ip6table_raw ip6table_security iptable_nat nf_nat nf_conntrack
>>> nf_defrag_ipv6 nf_defrag_ipv4 iptable_mangle iptable_raw
>>> iptable_security ebtable_filter ebtables ip6table_filter ip6_tables
>>> sunrpc sb_edac crct10dif_pclmul crc32_pclmul ghash_clmulni_intel
>>> kvm_intel kvm ppdev irqbypass parport_pc parport virtio_balloon pcspk=
r
>>> i2c_piix4 joydev xfs libcrc32c cirrus drm_kms_helper ttm drm e1000
>>> crc32c_intel virtio_blk serio_raw ata_generic floppy pata_acpi
>>> qemu_fw_cfg
>>> [  175.883153] ---[ end trace 5b67f12a67d1f373 ]---
>>>
>>> I should be able to rebuild the kernels/qemu and test this patch set
>>> over the next day or two.
>> Thanks.
>>> Thanks.
>>>
>>> - Alex
>> --
>> Regards
>> Nitesh
>>
--=20
Regards
Nitesh


--y4cVQaPmAucBZLncBWuX4eW6Ewy8T9UtR--

--bWBqOMw8AtsTm9gbha5w36I2jNHleutzD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyBdOUACgkQo4ZA3AYy
ozlW6RAAleX7/f9VEu1DL5gzpIh3bQuHW2Y9caTo+ajuHuj21cAKTPFCH9nW1yq+
kg+ML8hrxkKP4QacWedFhO0SwyouRgNklr/Wuvi3FRhaRQ48LpFYhE/pyQO2FyHZ
zNuQ1ZPWMgMmrF1wLkmagAsVXfb/PX37A5E4X9xQ4h2E0AN7dGVj6nAopGsTazE7
fCk1pUk/b1zs373427V1n8tlF3b/2thVh1tP2qFQJIpR9PsdXM2bPchRFwuxhNex
DXR/yAREA3TNp8vmcK1U5u5AarhiyE6t1dPsth5GFhuXssHM126is5MfTidmniLX
w0fNUP2SzM+sQCAEuWSH1JqrWPJcgCR8VlRgDB2GA7wF2lqYJ0WYe3tdGDbaugbU
n0/GJFhMuCnYBvs8tzFBHX38FgjPIRWx3zsC6SHsJVglaxrL5S8sKjVwYOyDx7Ao
dSDPkxwnZLVNbD2/ddruQGGKUP3VVXBaktPHBLGKVAHHVyj1b05KRsATfkZqDHXZ
8NR7NOkpNV7qt/E/K0B8eNNil1rdwGXTUhaqFGCWipcz46O5ct2BYsTciLjIfztt
LQ9Kc+ItBT1CRk6oEGY4/bZu8l7ckTMifNXk2yiT71nzx9WBEpkwKvKxlGO3pfJb
guEzGPtNfKeQ3q/0/F2WwiUx0Jj+zlFuA4R2v//uxlPu/zJ6WCo=
=1sjK
-----END PGP SIGNATURE-----

--bWBqOMw8AtsTm9gbha5w36I2jNHleutzD--

