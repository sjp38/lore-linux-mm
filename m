Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC092C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:19:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C0262184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:19:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C0262184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 079C86B0003; Wed, 20 Mar 2019 09:19:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 028976B0006; Wed, 20 Mar 2019 09:19:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5A926B0007; Wed, 20 Mar 2019 09:19:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEDD16B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 09:19:20 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v2so2102198qkf.21
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:19:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=6tT1aEvEuRjizCUJBxf4Y2JJN6MGtmvVc3856d38wco=;
        b=OfUSPXHJJGn/3sRJr6Y8A7Hb6Gvum0hmAl3F7LP71qt5SuYtRlgeNcmZl+Hd/FlUnY
         yr5v25LjBCgQVHZChOTrKlfWos8qlnxvvJM8JTL9aAxfFJfif3OU34ZWZtXbScn7cNFP
         GqPAbNV9lgwGaCAfrHRmkz9uF8KgcckXVs14/a4302D2phi+h5RKMtEK2ssP/sX5DXWG
         2vibaLkggBbkKAeAPGldUZyxp8jeoI2EzIasV5K0lP8CMh6GM2DQHiX0T9fvXCEfErnB
         uQUzTEgzElTmadmSof7LCOJsYiyFOzeMymu24jYYikog8QW/8Zo6OuU29YDQEvTFuiT0
         ZwZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW0ahT1y6firIVdd2o+0hHmG9kSjn0b39NL03/l7SwvLy7NiwF8
	LqDw14qulZcTR+4CmVjyBOX0lKXKyAU4EzaJzcwckTIkKP0+kFAECU0IEpb4fgCGZhvoGKihsia
	TvRaq5aNgHM7CLKn2GLHT/3Soxdyb6nqda++CfmESkjJxxp2AUCD1324ncBSmCFT9dg==
X-Received: by 2002:aed:3bd8:: with SMTP id s24mr6802778qte.358.1553087960462;
        Wed, 20 Mar 2019 06:19:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfhOmt59FKRtxXsI3v5zKSrRXeDweiTHBvBQdqzI5IHcmwlFpf/C0rcjEg5/AYTDdYSBPe
X-Received: by 2002:aed:3bd8:: with SMTP id s24mr6802575qte.358.1553087957875;
        Wed, 20 Mar 2019 06:19:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553087957; cv=none;
        d=google.com; s=arc-20160816;
        b=ZLf/h22mpOK2P4FZ4O+waF1LFH8Kz0whl7kxH3vFPsYG04SSuQWfyQhHiZvtuQnPgK
         dMVqY1+wqQgglAktDdIQt5/H0g0fqsAUNpGK1Fdu5S9OUVT8vEvyfH6nD7b8FEqIlY2p
         a6LerFom94lzqCyNF4Hg8GdrtLGYsHb+8xQ4Kb8/8bZ5TqS7YGK9DwdaW8I80IFoqxRD
         3k7Qh5hSo8MSz0gsjVbqv3z/JJXEwmt9gtR/L22p7z/Btj/tKeI1hhkpucnNfaZuvNI2
         32aVCVSbnGAbA4XL4xulUPYi9XRTdAIQydviIupkcV8kTw2HmM32Ui1tXf+SK1qw6J9m
         sbtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=6tT1aEvEuRjizCUJBxf4Y2JJN6MGtmvVc3856d38wco=;
        b=l4jiaDIY0L5vvXLd3n8kB4Vnj/3lMQWKU00LCZ0xtUp/ATGceF0+HnTysv9o97kghX
         CfKawcDa2e3zICt7SICAYeBS+tqFBKTxZTJPBxwTU/xXo7J05IrJjcJm1ZzkqLszju7g
         9lEjYFg9O93pJGg1MfqQG07A5hZvtrxnMp//7rmY9nVtviu9VhKHxlBW5WF7kIwi9YO1
         ZQcg11V0TAlS6xjWaPfSL581AxbLGZbdqB2HQ0JhyNbPsTZzKXravAGKWYQAcotjQtb4
         XoiCz1tvR9vYumhxZcUltY88wZDlWbpVohvZXrSD0ImgNj7JJIkHOaZzq6wn3wdz6vlI
         vYbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si340922qti.265.2019.03.20.06.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 06:19:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 06229C05FFCD;
	Wed, 20 Mar 2019 13:19:17 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7E2566CE47;
	Wed, 20 Mar 2019 13:19:05 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin"
 <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
 <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
 <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
 <4bd54f8b-3e9a-3493-40be-668962282431@redhat.com>
 <6d744ed6-9c1c-b29f-aa32-d38387187b74@redhat.com>
 <CAKgT0UcBDKr0ACHQWUCvmm8atxM6wSu7aCRFJkFvfjT_W_femQ@mail.gmail.com>
 <6709bb82-5e99-019d-7de0-3fded385b9ac@redhat.com>
Organization: Red Hat Inc,
Message-ID: <6ab9b763-ac90-b3db-3712-79a20c949d5d@redhat.com>
Date: Wed, 20 Mar 2019 09:18:58 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <6709bb82-5e99-019d-7de0-3fded385b9ac@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="ljVdVK49VIMJXB753VvPfu4u4TWQ5p4Jo"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 20 Mar 2019 13:19:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ljVdVK49VIMJXB753VvPfu4u4TWQ5p4Jo
Content-Type: multipart/mixed; boundary="puea2Pqtx7g0FHFUlNpkuRlwK4Aylk1Rt";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin"
 <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <6ab9b763-ac90-b3db-3712-79a20c949d5d@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--puea2Pqtx7g0FHFUlNpkuRlwK4Aylk1Rt
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/19/19 1:59 PM, Nitesh Narayan Lal wrote:
> On 3/19/19 1:38 PM, Alexander Duyck wrote:
>> On Tue, Mar 19, 2019 at 9:04 AM Nitesh Narayan Lal <nitesh@redhat.com>=
 wrote:
>>> On 3/19/19 9:33 AM, David Hildenbrand wrote:
>>>> On 18.03.19 16:57, Nitesh Narayan Lal wrote:
>>>>> On 3/14/19 12:58 PM, Alexander Duyck wrote:
>>>>>> On Thu, Mar 14, 2019 at 9:43 AM Nitesh Narayan Lal <nitesh@redhat.=
com> wrote:
>>>>>>> On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
>>>>>>>> On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wro=
te:
>>>>>>>>> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
>>>>>>>>>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal w=
rote:
>>>>>>>>>>> The following patch-set proposes an efficient mechanism for h=
anding freed memory between the guest and the host. It enables the guests=
 with no page cache to rapidly free and reclaims memory to and from the h=
ost respectively.
>>>>>>>>>>>
>>>>>>>>>>> Benefit:
>>>>>>>>>>> With this patch-series, in our test-case, executed on a singl=
e system and single NUMA node with 15GB memory, we were able to successfu=
lly launch 5 guests(each with 5 GB memory) when page hinting was enabled =
and 3 without it. (Detailed explanation of the test procedure is provided=
 at the bottom under Test - 1).
>>>>>>>>>>>
>>>>>>>>>>> Changelog in v9:
>>>>>>>>>>>    * Guest free page hinting hook is now invoked after a page=
 has been merged in the buddy.
>>>>>>>>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_OR=
DER(currently defined as MAX_ORDER - 1) are captured.
>>>>>>>>>>>    * Removed kthread which was earlier used to perform the sc=
anning, isolation & reporting of free pages.
>>>>>>>>>>>    * Pages, captured in the per cpu array are sorted based on=
 the zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>>>>>>>>         * Dynamically allocated space is used to hold the iso=
lated guest free pages.
>>>>>>>>>>>         * All the pages are reported asynchronously to the ho=
st via virtio driver.
>>>>>>>>>>>         * Pages are returned back to the guest buddy free lis=
t only when the host response is received.
>>>>>>>>>>>
>>>>>>>>>>> Pending items:
>>>>>>>>>>>         * Make sure that the guest free page hinting's curren=
t implementation doesn't break hugepages or device assigned guests.
>>>>>>>>>>>    * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side =
support. (It is currently missing)
>>>>>>>>>>>         * Compare reporting free pages via vring with vhost.
>>>>>>>>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>>>>>>>>>    * Analyze overall performance impact due to guest free pag=
e hinting.
>>>>>>>>>>>    * Come up with proper/traceable error-message/logs.
>>>>>>>>>>>
>>>>>>>>>>> Tests:
>>>>>>>>>>> 1. Use-case - Number of guests we can launch
>>>>>>>>>>>
>>>>>>>>>>>    NUMA Nodes =3D 1 with 15 GB memory
>>>>>>>>>>>    Guest Memory =3D 5 GB
>>>>>>>>>>>    Number of cores in guest =3D 1
>>>>>>>>>>>    Workload =3D test allocation program allocates 4GB memory,=
 touches it via memset and exits.
>>>>>>>>>>>    Procedure =3D
>>>>>>>>>>>    The first guest is launched and once its console is up, th=
e test allocation program is executed with 4 GB memory request (Due to th=
is the guest occupies almost 4-5 GB of memory in the host in a system wit=
hout page hinting). Once this program exits at that time another guest is=
 launched in the host and the same process is followed. We continue launc=
hing the guests until a guest gets killed due to low memory condition in =
the host.
>>>>>>>>>>>
>>>>>>>>>>>    Results:
>>>>>>>>>>>    Without hinting =3D 3
>>>>>>>>>>>    With hinting =3D 5
>>>>>>>>>>>
>>>>>>>>>>> 2. Hackbench
>>>>>>>>>>>    Guest Memory =3D 5 GB
>>>>>>>>>>>    Number of cores =3D 4
>>>>>>>>>>>    Number of tasks         Time with Hinting       Time witho=
ut Hinting
>>>>>>>>>>>    4000                    19.540                  17.818
>>>>>>>>>>>
>>>>>>>>>> How about memhog btw?
>>>>>>>>>> Alex reported:
>>>>>>>>>>
>>>>>>>>>>     My testing up till now has consisted of setting up 4 8GB V=
Ms on a system
>>>>>>>>>>     with 32GB of memory and 4GB of swap. To stress the memory =
on the system I
>>>>>>>>>>     would run "memhog 8G" sequentially on each of the guests a=
nd observe how
>>>>>>>>>>     long it took to complete the run. The observed behavior is=
 that on the
>>>>>>>>>>     systems with these patches applied in both the guest and o=
n the host I was
>>>>>>>>>>     able to complete the test with a time of 5 to 7 seconds pe=
r guest. On a
>>>>>>>>>>     system without these patches the time ranged from 7 to 49 =
seconds per
>>>>>>>>>>     guest. I am assuming the variability is due to time being =
spent writing
>>>>>>>>>>     pages out to disk in order to free up space for the guest.=

>>>>>>>>>>
>>>>>>>>> Here are the results:
>>>>>>>>>
>>>>>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA no=
de with
>>>>>>>>> total memory of 15GB and no swap. In each of the guest, memhog =
is run
>>>>>>>>> with 5GB. Post-execution of memhog, Host memory usage is monito=
red by
>>>>>>>>> using Free command.
>>>>>>>>>
>>>>>>>>> Without Hinting:
>>>>>>>>>                  Time of execution    Host used memory
>>>>>>>>> Guest 1:        45 seconds            5.4 GB
>>>>>>>>> Guest 2:        45 seconds            10 GB
>>>>>>>>> Guest 3:        1  minute               15 GB
>>>>>>>>>
>>>>>>>>> With Hinting:
>>>>>>>>>                 Time of execution     Host used memory
>>>>>>>>> Guest 1:        49 seconds            2.4 GB
>>>>>>>>> Guest 2:        40 seconds            4.3 GB
>>>>>>>>> Guest 3:        50 seconds            6.3 GB
>>>>>>>> OK so no improvement. OTOH Alex's patches cut time down to 5-7 s=
econds
>>>>>>>> which seems better. Want to try testing Alex's patches for compa=
rison?
>>>>>>>>
>>>>>>> I realized that the last time I reported the memhog numbers, I di=
dn't
>>>>>>> enable the swap due to which the actual benefits of the series we=
re not
>>>>>>> shown.
>>>>>>> I have re-run the test by including some of the changes suggested=
 by
>>>>>>> Alexander and David:
>>>>>>>     * Reduced the size of the per-cpu array to 32 and minimum hin=
ting
>>>>>>> threshold to 16.
>>>>>>>     * Reported length of isolated pages along with start pfn, ins=
tead of
>>>>>>> the order from the guest.
>>>>>>>     * Used the reported length to madvise the entire length of ad=
dress
>>>>>>> instead of a single 4K page.
>>>>>>>     * Replaced MADV_DONTNEED with MADV_FREE.
>>>>>>>
>>>>>>> Setup for the test:
>>>>>>> NUMA node:1
>>>>>>> Memory: 15GB
>>>>>>> Swap: 4GB
>>>>>>> Guest memory: 6GB
>>>>>>> Number of core: 1
>>>>>>>
>>>>>>> Process: A guest is launched and memhog is run with 6GB. As its
>>>>>>> execution is over next guest is launched. Everytime memhog execut=
ion
>>>>>>> time is monitored.
>>>>>>> Results:
>>>>>>>     Without Hinting:
>>>>>>>                  Time of execution
>>>>>>>     Guest1:    22s
>>>>>>>     Guest2:    24s
>>>>>>>     Guest3: 1m29s
>>>>>>>
>>>>>>>     With Hinting:
>>>>>>>                 Time of execution
>>>>>>>     Guest1:    24s
>>>>>>>     Guest2:    25s
>>>>>>>     Guest3:    28s
>>>>>>>
>>>>>>> When hinting is enabled swap space is not used until memhog with =
6GB is
>>>>>>> ran in 6th guest.
>>>>>> So one change you may want to make to your test setup would be to
>>>>>> launch the tests sequentially after all the guests all up, instead=
 of
>>>>>> combining the test and guest bring-up. In addition you could run
>>>>>> through the guests more than once to determine a more-or-less stea=
dy
>>>>>> state in terms of the performance as you move between the guests a=
fter
>>>>>> they have hit the point of having to either swap or pull MADV_FREE=

>>>>>> pages.
>>>>> I tried running memhog as you suggested, here are the results:
>>>>> Setup for the test:
>>>>> NUMA node:1
>>>>> Memory: 15GB
>>>>> Swap: 4GB
>>>>> Guest memory: 6GB
>>>>> Number of core: 1
>>>>>
>>>>> Process: 3 guests are launched and memhog is run with 6GB. Results =
are
>>>>> monitored after 1st-time execution of memhog. Memhog is launched
>>>>> sequentially in each of the guests and time is observed after the
>>>>> execution of all 3 memhog is over.
>>>>>
>>>>> Results:
>>>>> Without Hinting
>>>>>     Time of Execution
>>>>> 1.    6m48s
>>>>> 2.    6m9s
>>>>>
>>>>> With Hinting
>>>>> Array size:16 Minimum Threshold:8
>>>>> 1.    2m57s
>>>>> 2.    2m20s
>>>>>
>>>>> The memhog execution time in the case of hinting is still not that =
low
>>>>> as we would have expected. This is due to the usage of swap space.
>>>>> Although wrt to non-hinting when swap used space is around 3.5G, wi=
th
>>>>> hinting it remains to around 1.1-1.5G.
>>>>> I did try using a zone free page barrier which prevented hinting wh=
en
>>>>> free pages of order HINTING_ORDER goes below 256. This further brin=
gs
>>>>> down the swap usage to 100-150 MB. The tricky part of this approach=
 is
>>>>> to configure this barrier condition for different guests.
>>>>>
>>>>> Array size:16 Minimum Threshold:8
>>>>> 1.    1m16s
>>>>> 2.    1m41s
>>>>>
>>>>> Note: Memhog time does seem to vary a little bit on every boot with=
 or
>>>>> without hinting.
>>>>>
>>>> I don't quite understand yet why "hinting more pages" (no free page
>>>> barrier) should result in a higher swap usage in the hypervisor
>>>> (1.1-1.5GB vs. 100-150 MB). If we are "hinting more pages" I would h=
ave
>>>> guessed that runtime could get slower, but not that we need more swa=
p.
>>>>
>>>> One theory:
>>>>
>>>> If you hint all MAX_ORDER - 1 pages, at one point it could be that a=
ll
>>>> "remaining" free pages are currently isolated to be hinted. As MM ne=
eds
>>>> more pages for a process, it will fallback to using "MAX_ORDER - 2"
>>>> pages and so on. These pages, when they are freed, you won't hint
>>>> anymore unless they get merged. But after all they won't get merged
>>>> because they can't be merged (otherwise they wouldn't be "MAX_ORDER =
- 2"
>>>> after all right from the beginning).
>>>>
>>>> Try hinting a smaller granularity to see if this could actually be t=
he case.
>>> So I have two questions in my mind after looking at the results now:
>>> 1. Why swap is coming into the picture when hinting is enabled?
>>> 2. Same to what you have raised.
>>> For the 1st question, I think the answer is: (correct me if I am wron=
g.)
>>> Memhog while writing the memory does free memory but the pages it fre=
es
>>> are of a lower order which doesn't merge until the memhog write
>>> completes. After which we do get the MAX_ORDER - 1 page from the budd=
y
>>> resulting in hinting.
>>> As all 3 memhog are running parallelly we don't get free memory until=

>>> one of them completes.
>>> This does explain that when 3 guests each of 6GB on a 15GB host tries=
 to
>>> run memhog with 6GB parallelly, swap comes into the picture even if
>>> hinting is enabled.
>> Are you running them in parallel or sequentially?=20
> I was running them parallelly but then I realized to see any benefits,
> in that case, I should have run less number of guests.
>> I had suggested
>> running them serially so that the previous one could complete and free=

>> the memory before the next one allocated memory. In that setup you
>> should see the guests still swapping without hints, but with hints the=

>> guest should free the memory up before the next one starts using it.
> Yeah, I just realized this. Thanks for the clarification.
>> If you are running them in parallel then you are going to see things
>> going to swap because memhog does like what the name implies and it
>> will use all of the memory you give it. It isn't until it completes
>> that the memory is freed.
>>
>>> This doesn't explain why putting a barrier or avoid hinting reduced t=
he
>>> swap usage. It seems I possibly had a wrong impression of the delayin=
g
>>> hinting idea which we discussed.
>>> As I was observing the value of the swap at the end of the memhog
>>> execution which is logically incorrect. I will re-run the test and
>>> observe the highest swap usage during the entire execution of memhog =
for
>>> hinting vs non-hinting.
>> So one option you may look at if you are wanting to run the tests in
>> parallel would be to limit the number of tests you have running at the=

>> same time. If you have 15G of memory and 6G per guest you should be
>> able to run 2 sessions at a time without going to swap, however if you=

>> run all 3 then you are likely going to be going to swap even with
>> hinting.
>>
>> - Alex
Here are the updated numbers excluding the guest bring-up cost:
Setup for the test-
NUMA node:1
Memory: 15GB
Swap: 4GB
Guest memory: 6GB
Number of core: 1
Process: 3 guests are launched and memhog is run serially with 6GB.
Results:
Without Hinting
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=
 =C2=A0=C2=A0=C2=A0 Time of Execution=C2=A0=C2=A0=C2=A0
Guest1:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 56s =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
Guest2: =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =
45s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
Guest3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 3m41s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0

With Hinting
Guest1:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 46s =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
Guest2: =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 45s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
Guest3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 49s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0




--=20
Regards
Nitesh


--puea2Pqtx7g0FHFUlNpkuRlwK4Aylk1Rt--

--ljVdVK49VIMJXB753VvPfu4u4TWQ5p4Jo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlySPcMACgkQo4ZA3AYy
oznSchAAx7bkW+tUwDEaMvO18HWDujdtEypSN1k5b2Z26jVxf0Cp2JQICQG1WX74
o5CY75nPr4hwVJUnfkAPCWevNd7JIRa1yZd2XYgJFgaH22Q9X1dfgIzfGr/ymV4r
VXypFUK7/V2jVBVzfCPUaoFq7dITwsHv1GuoDj9fJdADy4ppFdGRehJOj9dpswDN
O/Aw9WCPoVwAlFVElHkhJ4R7bS+OtkIXnMfk7KRKDzRuTGX1djzzZx3r24mMq+Kw
z5WNtV3pd4/1VLt2DNpwch3f2NEHsrTALgNGeWMnaexQVcIVS3OVurPogHzOKmDp
P8Y5QbDzne/uod63+6062F1oKzvN2kMiG3f5lLhaMdhkWDNAur6ak84hMWFX8olX
mQ+PKcqIlye+ctapP8Ylq4xfZ3KcQW1RMZDRYqDpoaiOFZ/OQuFLKT63yFMfX5qX
hla0BzIkjzi8wXrPwrzkA69GcgFAqFJAV+0QNN4C1JEzDCbx/NcwgLVH3vl4LZx2
/Lcx/ObsVRShSbF5NXTjts0AI+YCNUpd6j4pUdUIs1o7u+bIoZorMz+PNiaJvRdO
GQj8FajIq61xPcJbNtt+Ls1Hv485LriRZz7oRUz7fWmBD7ombYHUysYGgXZg3Ocw
T15m39IrnaLMjRGqEAHKGIou2fXmA8OlboY8tB51WDNyHwOVU4Y=
=9yCz
-----END PGP SIGNATURE-----

--ljVdVK49VIMJXB753VvPfu4u4TWQ5p4Jo--

