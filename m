Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A4ABC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:10:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E045E2081B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:10:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E045E2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9BF28E0004; Thu,  7 Mar 2019 08:10:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4C868E0002; Thu,  7 Mar 2019 08:10:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AECD68E0004; Thu,  7 Mar 2019 08:10:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8898E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 08:10:01 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id u66so1563362qkf.17
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 05:10:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=l2wxGK8dP1dCf5IH9r/ErzLILdvY8qTVpz/AlGxKajI=;
        b=Vh9VfzmL8cc4lfp3SVm6H4RAcrxnEB+/6VeBlg2yBMsns6LLESiCse22upLvWqnc6e
         1OSUldOKCNhjhwHjjRyXMaeh6Er9WXo1zqyjxB9RlIEG2MX6pY0d84XFuyYCM2Y6jnv+
         V4nl01xgh3om9B0yZcj3RD0Kj6+a5DHUpNmU+MOkcHdWqrpt0hjubEeH1UPk4S8Fby4l
         H0AEiyKrRtIofMlySWmGxP1QLkeJ592KLIEWirX0wCL5+Gnyc16EBRCUr4yLVl4hWN4c
         VB9kIIjTONH+sVScZfwLz2DHlrbbYQyP7MFIsS9aFOaiu0CPuWN4wTHLSHSh63cAcMlR
         68Vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUNZ5YKOtFT3n4hyXi2U9Kape7yrw8YRKa8TDuSQMahBC0ivo3h
	QHFOs0zSkxBtaC/Y/0nM5ZAjIY/KNUBqqXb5RxEh7tUN6CKxhmHWOnNXpnm7Kfkdf371bNDtJot
	fkIMF+NhLHKc1zER5E6TNOJBINuFWaZoAv0Qi3xm6uhcwCdmAaVYm4JuPmQeLlaBGpA==
X-Received: by 2002:a0c:8a44:: with SMTP id 4mr10294903qvu.110.1551964201151;
        Thu, 07 Mar 2019 05:10:01 -0800 (PST)
X-Google-Smtp-Source: APXvYqxhoJe/8cRs43HAhw1qbZ94TW3ONfovHO4rWHFNw/+ejvGyQmep2GEi2TkGCycjICqqMygT
X-Received: by 2002:a0c:8a44:: with SMTP id 4mr10294780qvu.110.1551964199492;
        Thu, 07 Mar 2019 05:09:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551964199; cv=none;
        d=google.com; s=arc-20160816;
        b=oeTiEQ43HUeKy4pEeBjW/imbxWQ3eDEeVwAUUwmo9FY0VijIUNLG34Zd6usH6CRsCR
         FyWTW2KiHhePw7VwGOZsaDgzTYMXbxmj5ZBCXnkjl6mog5Q0NuTypc9UQll5Q7etAJSA
         2iDZIPDJi/NTGn69LiYY4rFXBZobDaBNyehWImdGNW8cOjZtNHZdszHn2jfuYje/AzWn
         e7r4EwMLvi2RznM5S9rO1BEFABM2N+xTb0WSgFrZVLtKrp9yPhZCXJb8289/uCTVQOTr
         RT004HzMn6YKlk3/DgcjuDvd4rVJms4wnmTouF8bhIk3FNK1eDp1EYLjxjKk+xPm8JjA
         hwuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=l2wxGK8dP1dCf5IH9r/ErzLILdvY8qTVpz/AlGxKajI=;
        b=mIcTK4RGF7mSAsrn8jfFt3GJl92yQY9OW11cXNFhAnMycbQ+Amc25HLukl4i2U89AE
         Bu4Kip6M2PaxBNzNaEN1JKD7KqZQfetAss7TE1a0utjQ/kRdX8dvxrZ2cO+pbJ8wBlW5
         T64UdPjw2TyZMbcPPHM91eyWdydvt8HJCNa1DHJMjm5LVGhJ9caM5cMFz1HrkFCVGajs
         5M5uiLEyBAoIdab6xb0qQZY5hcDPxjW9BQGxCLfgG9pLoD7NqYt9tHeuadxaihw/rpCD
         40PrR8citPDJbH/6MyF+nFjWoHBHNIZUjr4m/dnL+D2quJjkk0R/mnZ22iuZQZ8Rz/ys
         DnmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x3si1650574qkl.28.2019.03.07.05.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 05:09:59 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5896381E00;
	Thu,  7 Mar 2019 13:09:58 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 29F8919C69;
	Thu,  7 Mar 2019 13:09:40 +0000 (UTC)
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
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
Date: Thu, 7 Mar 2019 08:09:27 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="vkpqsOf8GQMsEjMRZopY8oJsd8II0GPmR"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 07 Mar 2019 13:09:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vkpqsOf8GQMsEjMRZopY8oJsd8II0GPmR
Content-Type: multipart/mixed; boundary="4xemsept6MTTW3tWJftykOEW9JW7amP03";
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
Message-ID: <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
 <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
In-Reply-To: <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>

--4xemsept6MTTW3tWJftykOEW9JW7amP03
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/6/19 5:05 PM, Alexander Duyck wrote:
> On Wed, Mar 6, 2019 at 11:07 AM Nitesh Narayan Lal <nitesh@redhat.com> =
wrote:
>>
>> On 3/6/19 1:00 PM, Alexander Duyck wrote:
>>> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com>=
 wrote:
>>>> The following patch-set proposes an efficient mechanism for handing =
freed memory between the guest and the host. It enables the guests with n=
o page cache to rapidly free and reclaims memory to and from the host res=
pectively.
>>>>
>>>> Benefit:
>>>> With this patch-series, in our test-case, executed on a single syste=
m and single NUMA node with 15GB memory, we were able to successfully lau=
nch 5 guests(each with 5 GB memory) when page hinting was enabled and 3 w=
ithout it. (Detailed explanation of the test procedure is provided at the=
 bottom under Test - 1).
>>>>
>>>> Changelog in v9:
>>>>         * Guest free page hinting hook is now invoked after a page h=
as been merged in the buddy.
>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(cur=
rently defined as MAX_ORDER - 1) are captured.
>>>>         * Removed kthread which was earlier used to perform the scan=
ning, isolation & reporting of free pages.
>>> Without a kthread this has the potential to get really ugly really
>>> fast. If we are going to run asynchronously we should probably be
>>> truly asynchonous and just place a few pieces of data in the page tha=
t
>>> a worker thread can use to identify which pages have been hinted and
>>> which pages have not.
>> Can you please explain what do you mean by truly asynchronous?
>>
>> With this implementation also I am not reporting the pages synchronous=
ly.
> The problem is you are making it pseudo synchronous by having to push
> pages off to a side buffer aren't you? In my mind we should be able to
> have the page hinting go on with little to no interference with
> existing page allocation and freeing.
We have to opt one of the two options:
1. Block allocation by using a flag or acquire a lock to prevent the
usage of pages we are hinting.
2. Remove the page set entirely from the buddy. (This is what I am doing
right now)

The reason I would prefer the second approach is that we are not
blocking the allocation in any way and as we are only working with a
smaller set of pages we should be fine.
However, with the current approach as we are reporting asynchronously
there is a chance that we end up hinting more than 2-3 times for a
single workload run. In situation where this could lead to low memory
condition in the guest, the hinting will anyways fail as the guest will
not allow page isolation.
I can possibly try and test the same to ensure that we don't get OOM due
to hinting when the guest is under memory pressure.


>
>>> Then we can have that one thread just walking
>>> through the zone memory pulling out fixed size pieces at a time and
>>> providing hints on that. By doing that we avoid the potential of
>>> creating a batch of pages that eat up most of the system memory.
>>>
>>>>         * Pages, captured in the per cpu array are sorted based on t=
he zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>         * Dynamically allocated space is used to hold the isolated g=
uest free pages.
>>> I have concerns that doing this per CPU and allocating memory
>>> dynamically can result in you losing a significant amount of memory a=
s
>>> it sits waiting to be hinted.
>> It should not as the buddy will keep merging the pages and we are only=

>> capturing MAX_ORDER - 1.
>> This was the issue with the last patch-series when I was capturing all=

>> order pages resulting in the per-cpu array to be filled with lower ord=
er
>> pages.
>>>>         * All the pages are reported asynchronously to the host via =
virtio driver.
>>>>         * Pages are returned back to the guest buddy free list only =
when the host response is received.
>>> I have been thinking about this. Instead of stealing the page couldn'=
t
>>> you simply flag it that there is a hint in progress and simply wait i=
n
>>> arch_alloc_page until the hint has been processed?
>> With the flag, I am assuming you mean to block the allocation until
>> hinting is going on, which is an issue. That was one of the issues
>> discussed earlier which I wanted to solve with this implementation.
> With the flag we would allow the allocation, but would have to
> synchronize with the hinting at that point. I got the idea from the
> way the s390 code works. They have both an arch_free_page and an
> arch_alloc_page. If I understand correctly the arch_alloc_page is what
> is meant to handle the case of a page that has been marked for
> hinting, but may not have been hinted on yet. My thought for now is to
> keep it simple and use a page flag to indicate that a page is
> currently pending a hint.=20
I am assuming this page flag will be located in the page structure.
> We should be able to spin in such a case and
> it would probably still perform better than a solution where we would
> not have the memory available and possibly be under memory pressure.
I had this same idea earlier. However, the thing about which I was not
sure is if adding a flag in the page structure will be acceptable upstrea=
m.
>
>>> The problem is in
>>> stealing pages you are going to introduce false OOM issues when the
>>> memory isn't available because it is being hinted on.
>> I think this situation will arise when the guest is under memory
>> pressure. In such situations any attempt to perform isolation will
>> anyways fail and we may not be reporting anything at that time.
> What I want to avoid is the scenario where an application grabs a
> large amount of memory, then frees said memory, and we are sitting on
> it for some time because we decide to try and hint on the large chunk.
I agree.
> By processing this sometime after the pages are sent to the buddy
> allocator in a separate thread, and by processing a small fixed window
> of memory at a time we can avoid making freeing memory expensive, and
> still provide the hints in a reasonable time frame.

My impression is that the current window on which I am working may give
issues for smaller size guests. But otherwise, we are already working
with a smaller fixed window of memory.

I can further restrict this to just 128 entries and test which would
bring down the window of memory. Let me know what you think.

>
>>>> Pending items:
>>>>         * Make sure that the guest free page hinting's current imple=
mentation doesn't break hugepages or device assigned guests.
>>>>         * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side su=
pport. (It is currently missing)
>>>>         * Compare reporting free pages via vring with vhost.
>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>>         * Analyze overall performance impact due to guest free page =
hinting.
>>>>         * Come up with proper/traceable error-message/logs.
>>> I'll try applying these patches and see if I can reproduce the result=
s
>>> you reported.
>> Thanks. Let me know if you run into any issues.
>>> With the last patch set I couldn't reproduce the results
>>> as you reported them.
>> If I remember correctly then the last time you only tried with multipl=
e
>> vcpus and not with 1 vcpu.
> I had tried 1 vcpu, however I ended up running into some other issues
> that made it difficult to even boot the system last week.
>
>>> It has me wondering if you were somehow seeing
>>> the effects of a balloon instead of the actual memory hints as I
>>> couldn't find any evidence of the memory ever actually being freed
>>> back by the hints functionality.
>> Can you please elaborate what kind of evidence you are looking for?
>>
>> I did trace the hints on the QEMU/host side.
> It looks like the new patches are working as I am seeing the memory
> freeing occurring this time around. Although it looks like this is
> still generating traces from free_pcpages_bulk if I enable multiple
> VCPUs:
I am assuming with the changes you suggested you were able to run this
patch-series. Is that correct?
>
> [  175.823539] list_add corruption. next->prev should be prev
> (ffff947c7ffd61e0), but was ffffc7a29f9e0008. (next=3Dffffc7a29f4c0008)=
=2E
> [  175.825978] ------------[ cut here ]------------
> [  175.826889] kernel BUG at lib/list_debug.c:25!
> [  175.827766] invalid opcode: 0000 [#1] SMP PTI
> [  175.828621] CPU: 5 PID: 1344 Comm: page_fault1_thr Not tainted
> 5.0.0-next-20190306-baseline+ #76
> [  175.830312] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS Bochs 01/01/2011
> [  175.831885] RIP: 0010:__list_add_valid+0x35/0x70
> [  175.832784] Code: 18 48 8b 32 48 39 f0 75 39 48 39 c7 74 1e 48 39
> fa 74 19 b8 01 00 00 00 c3 48 89 c1 48 c7 c7 80 b5 0f a9 31 c0 e8 8f
> aa c8 ff <0f> 0b 48 89 c1 48 89 fe 31 c0 48 c7 c7 30 b6 0f a9 e8 79 aa
> c8 ff
> [  175.836379] RSP: 0018:ffffa717c40839b0 EFLAGS: 00010046
> [  175.837394] RAX: 0000000000000075 RBX: ffff947c7ffd61e0 RCX: 0000000=
000000000
> [  175.838779] RDX: 0000000000000000 RSI: ffff947c5f957188 RDI: ffff947=
c5f957188
> [  175.840162] RBP: ffff947c7ffd61d0 R08: 000000000000026f R09: 0000000=
000000005
> [  175.841539] R10: 0000000000000000 R11: ffffa717c4083730 R12: ffffc7a=
29f260008
> [  175.842932] R13: ffff947c7ffd5d00 R14: ffffc7a29f4c0008 R15: ffffc7a=
29f260000
> [  175.844319] FS:  0000000000000000(0000) GS:ffff947c5f940000(0000)
> knlGS:0000000000000000
> [  175.845896] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  175.847009] CR2: 00007fffe3421000 CR3: 000000051220e006 CR4: 0000000=
000160ee0
> [  175.848390] Call Trace:
> [  175.848896]  free_pcppages_bulk+0x4bc/0x6a0
> [  175.849723]  free_unref_page_list+0x10d/0x190
> [  175.850567]  release_pages+0x103/0x4a0
> [  175.851313]  tlb_flush_mmu_free+0x36/0x50
> [  175.852105]  unmap_page_range+0x963/0xd50
> [  175.852897]  unmap_vmas+0x62/0xc0
> [  175.853549]  exit_mmap+0xb5/0x1a0
> [  175.854205]  mmput+0x5b/0x120
> [  175.854794]  do_exit+0x273/0xc30
> [  175.855426]  ? free_unref_page_commit+0x85/0xf0
> [  175.856312]  do_group_exit+0x39/0xa0
> [  175.857018]  get_signal+0x172/0x7c0
> [  175.857703]  do_signal+0x36/0x620
> [  175.858355]  ? percpu_counter_add_batch+0x4b/0x60
> [  175.859280]  ? __do_munmap+0x288/0x390
> [  175.860020]  exit_to_usermode_loop+0x4c/0xa8
> [  175.860859]  do_syscall_64+0x152/0x170
> [  175.861595]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [  175.862586] RIP: 0033:0x7ffff76a8ec7
> [  175.863292] Code: Bad RIP value.
> [  175.863928] RSP: 002b:00007ffff4422eb8 EFLAGS: 00000212 ORIG_RAX:
> 000000000000000b
> [  175.865396] RAX: 0000000000000000 RBX: 00007ffff7ff7280 RCX: 00007ff=
ff76a8ec7
> [  175.866799] RDX: 00007fffe3422000 RSI: 0000000008000000 RDI: 00007ff=
fdb422000
> [  175.868194] RBP: 0000000000001000 R08: ffffffffffffffff R09: 0000000=
000000000
> [  175.869582] R10: 0000000000000022 R11: 0000000000000212 R12: 00007ff=
ff4422fc0
> [  175.870984] R13: 0000000000000001 R14: 00007fffffffc1b0 R15: 00007ff=
ff44239c0
> [  175.872350] Modules linked in: ip6t_rpfilter ip6t_REJECT
> nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat
> ebtable_broute bridge stp llc ip6table_nat ip6table_mangle
> ip6table_raw ip6table_security iptable_nat nf_nat nf_conntrack
> nf_defrag_ipv6 nf_defrag_ipv4 iptable_mangle iptable_raw
> iptable_security ebtable_filter ebtables ip6table_filter ip6_tables
> sunrpc sb_edac crct10dif_pclmul crc32_pclmul ghash_clmulni_intel
> kvm_intel kvm ppdev irqbypass parport_pc parport virtio_balloon pcspkr
> i2c_piix4 joydev xfs libcrc32c cirrus drm_kms_helper ttm drm e1000
> crc32c_intel virtio_blk serio_raw ata_generic floppy pata_acpi
> qemu_fw_cfg
> [  175.883153] ---[ end trace 5b67f12a67d1f373 ]---
>
> I should be able to rebuild the kernels/qemu and test this patch set
> over the next day or two.
Thanks.
>
> Thanks.
>
> - Alex
--=20
Regards
Nitesh


--4xemsept6MTTW3tWJftykOEW9JW7amP03--

--vkpqsOf8GQMsEjMRZopY8oJsd8II0GPmR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyBGAoACgkQo4ZA3AYy
ozlG4w/+OKDnQZFLusHCBM7dQQVHQea3/sIqrzBmbzSYH4nxW0ZNVCgzFTow12YW
nRj3ROCMZL6GNVOC4Am/L+1MfYzpLAKo5A5gGNTbcccb+IdGwQY6TPEtogBbvrZg
CUTx63iCjZnvaOntL76RwLhtb73Hfgf7yXZ/vzai6e2glNLkB50aRNliHFNV5akT
aqmJuIGJKccwyOXpSXPU/oHitqHksOTuBJJ4PRt28GLWJ87u3jC8l8XiYdnsy1xv
GjzmwEmWoLgQ1ocwaNpBbEAG8Z86VzXAiklf6Vo11z1u/JGa5PopgIEcEOHBDRtN
ws2ltI2OXvFkzD7Tq/9gE7YaBXU94lH3v01+ENyrG7AlObcSZikV4pM0we8g2U+q
+df7ibDj/FXW73dT+RoWHkSHOwvk3yt6XU5/vOpxVfENBHUpGvr4XjbZjOixFI+L
qQhtgNlDpX1oxYj6hL0Qe0c7WBiUr/8MnIsxiYiESNiTB1HFiirF+GD8k6dhL+kF
Zsd+xISsodjIlsIvjUm53RSDR82TSH+FYh8Nfn+G6T1zUAV9p6Yqsfqt3W142M78
Il8onw/UWd0Asw24e7DCVmvFmz7XP9C03f1nqjKI9zpbIxlF4g5PVYPgklehEvi3
I2jhabcr6ZMiABzcUdiuiDb1ez61O6/QvQFvX/Uv49qgmUma0e8=
=Cwx5
-----END PGP SIGNATURE-----

--vkpqsOf8GQMsEjMRZopY8oJsd8II0GPmR--

