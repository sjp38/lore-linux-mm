Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 688B8C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02EC420840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:46:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rJA3PnBU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02EC420840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 823C98E0003; Thu,  7 Mar 2019 13:46:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AA318E0002; Thu,  7 Mar 2019 13:46:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64B2C8E0003; Thu,  7 Mar 2019 13:46:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 358FF8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:46:12 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id x22so13491977iob.10
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:46:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=ksfG1G8pTbA4zffj+7R6P94fppfAV5JVtMRARVaBhak=;
        b=gaq2ESLfl7kRSf75+jnbi/Ssl1ayEmZjDY6+AibZgcSIDlpCa/G9foHKib7AFMNtGZ
         0KBUi1E8Z8gaWufiK8M7AEp+7b0V8C9LqQfgzoudBahp6NZ8yNtFdGZ2o8eggzfsu0KU
         otvZgxIzlcTOI8Lm2JGzgiqp2OT8WQCEjBr+QxLHFHhLpzUQ7FMmagWD7bbQct9ayuev
         vOTr+hcC0hrrPfDHCTQu1b/5nQ0czMmIn7j0p1mbEdDkN4trMxinCEhuwhZJWvfXDe/I
         ABe8tqBVFc56SFnQNmU0b0dzFJQkESoGw7YFQa4q0pD1f1R6h+bVB8+nhbeumHZyI57N
         aYUw==
X-Gm-Message-State: APjAAAXZQaSBlpNSgHqm23hE9KIT219kYYopEHOBjUbersd/q3SeFm0d
	kQwZFZJMeSOXCsZFS9LeXy/s37v/uLEf28gySQgKMg+MoyzvlrATaXVHJqIKyUMg6esOQXh3cBB
	kHF80bIAjHZmFYX5QAw4I2pjBkAjxrgdLjmyWOEEUXSfSKrc0xOb1iRQLE3V0C1Fx2+GOjrr9O1
	bgKNKqLluvgs2ADqpRE0W7bE3F+4G9thvwy7YXeIKfQksNu+1Lv7gKKATjiBPaf8tFTYoYTRFnX
	lxBkiGEi/0IC8EANC1CvNBh+IdJ7m9LdBsWfUeIMsYtovaOHeEFa5bAb6CNOBPThgmX4dOODUOm
	oD5FppFX76/CmoFR1x7lJtrVqEhiaQwv7BGU36/RQqOVJFlkf8y3B7HoiCq34Cd/QvyWeshEUJz
	q
X-Received: by 2002:a6b:7847:: with SMTP id h7mr7103765iop.83.1551984371833;
        Thu, 07 Mar 2019 10:46:11 -0800 (PST)
X-Received: by 2002:a6b:7847:: with SMTP id h7mr7103702iop.83.1551984370312;
        Thu, 07 Mar 2019 10:46:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551984370; cv=none;
        d=google.com; s=arc-20160816;
        b=QfnORo7HwqPqK8uuNnnwF3kKaWPBGhNiPG0XuSJXKHjq05g1YOhHmlUnF07b1BvJI9
         OBai96KxEOKYT5KpHXjAlm2h6VQ3H4+hGBty1MEGRBuBoNKNPOHTPxgke8dmKeuq743r
         1MNmtDscQB9kNi0f0sKXX/vnvA4v8OdcaFcGoFoJlv29TJ0UwTDTGAi7i1oa6+xSx5RA
         R1cNIFta4mfZNxeqMrfvsPh4ZXWlrNsqhSZTNbkMrBDeIYFEcf5eWkNnsWJpjVgTM97W
         SfpgGr7YOrG+c7jjSgOjXGiU5xa4hfB00z/Z9jVJ/LPAzrn1DmfkrW1rJCPC4szShDkh
         sxKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ksfG1G8pTbA4zffj+7R6P94fppfAV5JVtMRARVaBhak=;
        b=SX24pwqySSWhLfAR4dDcJbz9GsV2N8V4zior7CFil1biXGaIcnuRztjTdo+aoWJUuS
         B9VDrXdFacR5F0weQLuQ3NmmHLH/N/EQUY0OCbqZJP5o4oKm4Y5I9WcOigVT+U+IPWJ2
         degM4/VYimBjtnQr/J4dRWdWcCBIBzFLGGxnAMqQPuZ+G/PsoieF3Ln/Dkd3zk+WrgJD
         v61DYvxuRO7kFi1rHmS/wyVqSXUTta/HYshUNC/wK9xmX2ESZkUte7tB6di9kFI3753a
         COabdIx1lZD9ccbn0rjIsep8J1ytUeTd7GRMIUTktDPLeH/DKQqZw7/TRrAi/GCsXn03
         vUYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rJA3PnBU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c7sor12630329jac.4.2019.03.07.10.46.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 10:46:10 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rJA3PnBU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ksfG1G8pTbA4zffj+7R6P94fppfAV5JVtMRARVaBhak=;
        b=rJA3PnBUxfpGsSDeY5OdxbGLyxug/fu8siHwtDyfgslFKnLul4X5gMqNd0BNuyITIi
         IcnI5njTiCIcMrSsr16hPn+IYUpS0eXybbTX3WlrIbIZ/3PTjimijBqGrZk5wrQjsVvk
         ZAsYib903oFf5jLw1mYrEpwWNfAg3hOJQuFqhMiC++aReN/yOjzdgv/5ew3RShMTlPY8
         1QsTCxPQr4ZF3g7Kqt7Xj96JHQFx/3u8eqeZy1ezaAp/+gBGYCCjrnrai7HrZaMQvGO0
         iOacIk4MujjQ9Agbi99KXq/DtjABIpVrzut6zkSbiKK4s3QaNkWjm4pcQ2K72zMx8KRk
         GTdg==
X-Google-Smtp-Source: APXvYqz7e5ux+sKr6XEIByolgMAqbf6rFi/BPqSb3aUZzgZSvcs6TSlE7eK156WupCCP4N23PyfKME3X+J2rApYM8To=
X-Received: by 2002:a02:95a:: with SMTP id f87mr7933807jad.83.1551984369683;
 Thu, 07 Mar 2019 10:46:09 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com> <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
In-Reply-To: <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 7 Mar 2019 10:45:58 -0800
Message-ID: <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 5:09 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote=
:
>
>
> On 3/6/19 5:05 PM, Alexander Duyck wrote:
> > On Wed, Mar 6, 2019 at 11:07 AM Nitesh Narayan Lal <nitesh@redhat.com> =
wrote:
> >>
> >> On 3/6/19 1:00 PM, Alexander Duyck wrote:
> >>> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com>=
 wrote:
> >>>> The following patch-set proposes an efficient mechanism for handing =
freed memory between the guest and the host. It enables the guests with no =
page cache to rapidly free and reclaims memory to and from the host respect=
ively.
> >>>>
> >>>> Benefit:
> >>>> With this patch-series, in our test-case, executed on a single syste=
m and single NUMA node with 15GB memory, we were able to successfully launc=
h 5 guests(each with 5 GB memory) when page hinting was enabled and 3 witho=
ut it. (Detailed explanation of the test procedure is provided at the botto=
m under Test - 1).
> >>>>
> >>>> Changelog in v9:
> >>>>         * Guest free page hinting hook is now invoked after a page h=
as been merged in the buddy.
> >>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(cur=
rently defined as MAX_ORDER - 1) are captured.
> >>>>         * Removed kthread which was earlier used to perform the scan=
ning, isolation & reporting of free pages.
> >>> Without a kthread this has the potential to get really ugly really
> >>> fast. If we are going to run asynchronously we should probably be
> >>> truly asynchonous and just place a few pieces of data in the page tha=
t
> >>> a worker thread can use to identify which pages have been hinted and
> >>> which pages have not.
> >> Can you please explain what do you mean by truly asynchronous?
> >>
> >> With this implementation also I am not reporting the pages synchronous=
ly.
> > The problem is you are making it pseudo synchronous by having to push
> > pages off to a side buffer aren't you? In my mind we should be able to
> > have the page hinting go on with little to no interference with
> > existing page allocation and freeing.
> We have to opt one of the two options:
> 1. Block allocation by using a flag or acquire a lock to prevent the
> usage of pages we are hinting.
> 2. Remove the page set entirely from the buddy. (This is what I am doing
> right now)
>
> The reason I would prefer the second approach is that we are not
> blocking the allocation in any way and as we are only working with a
> smaller set of pages we should be fine.
> However, with the current approach as we are reporting asynchronously
> there is a chance that we end up hinting more than 2-3 times for a
> single workload run. In situation where this could lead to low memory
> condition in the guest, the hinting will anyways fail as the guest will
> not allow page isolation.
> I can possibly try and test the same to ensure that we don't get OOM due
> to hinting when the guest is under memory pressure.

So in either case you are essentially blocking allocation since the
memory cannot be used. My concern is more with guaranteeing forward
progress for as many CPUs as possible.

With your current design you have one minor issue in that you aren't
taking the lock to re-insert the pages back into the buddy allocator.
When you add that step in it means you are going to be blocking
allocation on that zone while you are reinserting the pages.

Also right now you are using the calls to free_one_page to generate a
list of hints where to search. I'm thinking that may not be the best
approach since what we want to do is provide hints on idle free pages,
not just pages that will be free for a short period of time.

To that end what I think w may want to do is instead just walk the LRU
list for a given zone/order in reverse order so that we can try to
identify the pages that are most likely to be cold and unused and
those are the first ones we want to be hinting on rather than the ones
that were just freed. If we can look at doing something like adding a
jiffies value to the page indicating when it was last freed we could
even have a good point for determining when we should stop processing
pages in a given zone/order list.

In reality the approach wouldn't be too different from what you are
doing now, the only real difference would be that we would just want
to walk the LRU list for the given zone/order rather then pulling
hints on what to free from the calls to free_one_page. In addition we
would need to add a couple bits to indicate if the page has been
hinted on, is in the middle of getting hinted on, and something such
as the jiffies value I mentioned which we could use to determine how
old the page is.

> >
> >>> Then we can have that one thread just walking
> >>> through the zone memory pulling out fixed size pieces at a time and
> >>> providing hints on that. By doing that we avoid the potential of
> >>> creating a batch of pages that eat up most of the system memory.
> >>>
> >>>>         * Pages, captured in the per cpu array are sorted based on t=
he zone numbers. This is to avoid redundancy of acquiring zone locks.
> >>>>         * Dynamically allocated space is used to hold the isolated g=
uest free pages.
> >>> I have concerns that doing this per CPU and allocating memory
> >>> dynamically can result in you losing a significant amount of memory a=
s
> >>> it sits waiting to be hinted.
> >> It should not as the buddy will keep merging the pages and we are only
> >> capturing MAX_ORDER - 1.
> >> This was the issue with the last patch-series when I was capturing all
> >> order pages resulting in the per-cpu array to be filled with lower ord=
er
> >> pages.
> >>>>         * All the pages are reported asynchronously to the host via =
virtio driver.
> >>>>         * Pages are returned back to the guest buddy free list only =
when the host response is received.
> >>> I have been thinking about this. Instead of stealing the page couldn'=
t
> >>> you simply flag it that there is a hint in progress and simply wait i=
n
> >>> arch_alloc_page until the hint has been processed?
> >> With the flag, I am assuming you mean to block the allocation until
> >> hinting is going on, which is an issue. That was one of the issues
> >> discussed earlier which I wanted to solve with this implementation.
> > With the flag we would allow the allocation, but would have to
> > synchronize with the hinting at that point. I got the idea from the
> > way the s390 code works. They have both an arch_free_page and an
> > arch_alloc_page. If I understand correctly the arch_alloc_page is what
> > is meant to handle the case of a page that has been marked for
> > hinting, but may not have been hinted on yet. My thought for now is to
> > keep it simple and use a page flag to indicate that a page is
> > currently pending a hint.
> I am assuming this page flag will be located in the page structure.
> > We should be able to spin in such a case and
> > it would probably still perform better than a solution where we would
> > not have the memory available and possibly be under memory pressure.
> I had this same idea earlier. However, the thing about which I was not
> sure is if adding a flag in the page structure will be acceptable upstrea=
m.
> >
> >>> The problem is in
> >>> stealing pages you are going to introduce false OOM issues when the
> >>> memory isn't available because it is being hinted on.
> >> I think this situation will arise when the guest is under memory
> >> pressure. In such situations any attempt to perform isolation will
> >> anyways fail and we may not be reporting anything at that time.
> > What I want to avoid is the scenario where an application grabs a
> > large amount of memory, then frees said memory, and we are sitting on
> > it for some time because we decide to try and hint on the large chunk.
> I agree.
> > By processing this sometime after the pages are sent to the buddy
> > allocator in a separate thread, and by processing a small fixed window
> > of memory at a time we can avoid making freeing memory expensive, and
> > still provide the hints in a reasonable time frame.
>
> My impression is that the current window on which I am working may give
> issues for smaller size guests. But otherwise, we are already working
> with a smaller fixed window of memory.
>
> I can further restrict this to just 128 entries and test which would
> bring down the window of memory. Let me know what you think.

The problem is 128 entries is still pretty big when you consider you
are working with 4M pages. If I am not mistaken that is a half
gigabyte of memory. For lower order pages 128 would probably be fine,
but with the higher order pages we may want to contain things to
something smaller like 16MB to 64MB worth of memory.

> >
> >>>> Pending items:
> >>>>         * Make sure that the guest free page hinting's current imple=
mentation doesn't break hugepages or device assigned guests.
> >>>>         * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side su=
pport. (It is currently missing)
> >>>>         * Compare reporting free pages via vring with vhost.
> >>>>         * Decide between MADV_DONTNEED and MADV_FREE.
> >>>>         * Analyze overall performance impact due to guest free page =
hinting.
> >>>>         * Come up with proper/traceable error-message/logs.
> >>> I'll try applying these patches and see if I can reproduce the result=
s
> >>> you reported.
> >> Thanks. Let me know if you run into any issues.
> >>> With the last patch set I couldn't reproduce the results
> >>> as you reported them.
> >> If I remember correctly then the last time you only tried with multipl=
e
> >> vcpus and not with 1 vcpu.
> > I had tried 1 vcpu, however I ended up running into some other issues
> > that made it difficult to even boot the system last week.
> >
> >>> It has me wondering if you were somehow seeing
> >>> the effects of a balloon instead of the actual memory hints as I
> >>> couldn't find any evidence of the memory ever actually being freed
> >>> back by the hints functionality.
> >> Can you please elaborate what kind of evidence you are looking for?
> >>
> >> I did trace the hints on the QEMU/host side.
> > It looks like the new patches are working as I am seeing the memory
> > freeing occurring this time around. Although it looks like this is
> > still generating traces from free_pcpages_bulk if I enable multiple
> > VCPUs:
> I am assuming with the changes you suggested you were able to run this
> patch-series. Is that correct?

Yes, I got it working by disabling SMP. I think I found and pointed
out the issue in your other patch where you were using __free_one_page
without holding the zone lock.

> >
> > [  175.823539] list_add corruption. next->prev should be prev
> > (ffff947c7ffd61e0), but was ffffc7a29f9e0008. (next=3Dffffc7a29f4c0008)=
.
> > [  175.825978] ------------[ cut here ]------------
> > [  175.826889] kernel BUG at lib/list_debug.c:25!
> > [  175.827766] invalid opcode: 0000 [#1] SMP PTI
> > [  175.828621] CPU: 5 PID: 1344 Comm: page_fault1_thr Not tainted
> > 5.0.0-next-20190306-baseline+ #76
> > [  175.830312] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> > BIOS Bochs 01/01/2011
> > [  175.831885] RIP: 0010:__list_add_valid+0x35/0x70
> > [  175.832784] Code: 18 48 8b 32 48 39 f0 75 39 48 39 c7 74 1e 48 39
> > fa 74 19 b8 01 00 00 00 c3 48 89 c1 48 c7 c7 80 b5 0f a9 31 c0 e8 8f
> > aa c8 ff <0f> 0b 48 89 c1 48 89 fe 31 c0 48 c7 c7 30 b6 0f a9 e8 79 aa
> > c8 ff
> > [  175.836379] RSP: 0018:ffffa717c40839b0 EFLAGS: 00010046
> > [  175.837394] RAX: 0000000000000075 RBX: ffff947c7ffd61e0 RCX: 0000000=
000000000
> > [  175.838779] RDX: 0000000000000000 RSI: ffff947c5f957188 RDI: ffff947=
c5f957188
> > [  175.840162] RBP: ffff947c7ffd61d0 R08: 000000000000026f R09: 0000000=
000000005
> > [  175.841539] R10: 0000000000000000 R11: ffffa717c4083730 R12: ffffc7a=
29f260008
> > [  175.842932] R13: ffff947c7ffd5d00 R14: ffffc7a29f4c0008 R15: ffffc7a=
29f260000
> > [  175.844319] FS:  0000000000000000(0000) GS:ffff947c5f940000(0000)
> > knlGS:0000000000000000
> > [  175.845896] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  175.847009] CR2: 00007fffe3421000 CR3: 000000051220e006 CR4: 0000000=
000160ee0
> > [  175.848390] Call Trace:
> > [  175.848896]  free_pcppages_bulk+0x4bc/0x6a0
> > [  175.849723]  free_unref_page_list+0x10d/0x190
> > [  175.850567]  release_pages+0x103/0x4a0
> > [  175.851313]  tlb_flush_mmu_free+0x36/0x50
> > [  175.852105]  unmap_page_range+0x963/0xd50
> > [  175.852897]  unmap_vmas+0x62/0xc0
> > [  175.853549]  exit_mmap+0xb5/0x1a0
> > [  175.854205]  mmput+0x5b/0x120
> > [  175.854794]  do_exit+0x273/0xc30
> > [  175.855426]  ? free_unref_page_commit+0x85/0xf0
> > [  175.856312]  do_group_exit+0x39/0xa0
> > [  175.857018]  get_signal+0x172/0x7c0
> > [  175.857703]  do_signal+0x36/0x620
> > [  175.858355]  ? percpu_counter_add_batch+0x4b/0x60
> > [  175.859280]  ? __do_munmap+0x288/0x390
> > [  175.860020]  exit_to_usermode_loop+0x4c/0xa8
> > [  175.860859]  do_syscall_64+0x152/0x170
> > [  175.861595]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > [  175.862586] RIP: 0033:0x7ffff76a8ec7
> > [  175.863292] Code: Bad RIP value.
> > [  175.863928] RSP: 002b:00007ffff4422eb8 EFLAGS: 00000212 ORIG_RAX:
> > 000000000000000b
> > [  175.865396] RAX: 0000000000000000 RBX: 00007ffff7ff7280 RCX: 00007ff=
ff76a8ec7
> > [  175.866799] RDX: 00007fffe3422000 RSI: 0000000008000000 RDI: 00007ff=
fdb422000
> > [  175.868194] RBP: 0000000000001000 R08: ffffffffffffffff R09: 0000000=
000000000
> > [  175.869582] R10: 0000000000000022 R11: 0000000000000212 R12: 00007ff=
ff4422fc0
> > [  175.870984] R13: 0000000000000001 R14: 00007fffffffc1b0 R15: 00007ff=
ff44239c0
> > [  175.872350] Modules linked in: ip6t_rpfilter ip6t_REJECT
> > nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat
> > ebtable_broute bridge stp llc ip6table_nat ip6table_mangle
> > ip6table_raw ip6table_security iptable_nat nf_nat nf_conntrack
> > nf_defrag_ipv6 nf_defrag_ipv4 iptable_mangle iptable_raw
> > iptable_security ebtable_filter ebtables ip6table_filter ip6_tables
> > sunrpc sb_edac crct10dif_pclmul crc32_pclmul ghash_clmulni_intel
> > kvm_intel kvm ppdev irqbypass parport_pc parport virtio_balloon pcspkr
> > i2c_piix4 joydev xfs libcrc32c cirrus drm_kms_helper ttm drm e1000
> > crc32c_intel virtio_blk serio_raw ata_generic floppy pata_acpi
> > qemu_fw_cfg
> > [  175.883153] ---[ end trace 5b67f12a67d1f373 ]---
> >
> > I should be able to rebuild the kernels/qemu and test this patch set
> > over the next day or two.
> Thanks.
> >
> > Thanks.
> >
> > - Alex
> --
> Regards
> Nitesh
>

