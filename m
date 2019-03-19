Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76B22C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:04:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2695C206B7
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:04:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2695C206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF2506B0003; Tue, 19 Mar 2019 12:04:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA2636B0006; Tue, 19 Mar 2019 12:04:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 969836B0007; Tue, 19 Mar 2019 12:04:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3F76B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:04:25 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 77so16253190qkd.9
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:04:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=m4h3Ks/alLuiyZa5RZDI2rTXK/RVdcHXqGrbVw34L3U=;
        b=rVoqfxJ5A8Z4DpgPkUtOTgDC5DTsWwYxVN53V14pXRVUyTj4zbzTClXAVRLgZRq7Ib
         61Tsdjl+s4fN4rc6d45JR9Z90dqB74Q+F4ZXDKdLD0jITcaKvaYo6H613ZibjdIUofUR
         tztJ9npweeok7D1akA4ZGk+xJx7fL//jN6YdpUpIOUBODBt1mnJUA8yEYRtSARdmSWDv
         XDK+u4ZKZxui+ao5fZD6co6Lsdopn3QVOyZEVshbBMJx0l0X+d67TiSQdbENduvnvruW
         QTPFrzO2QbM5kaSXjccpufpVtBe2CFvYmsH4pRPr64H1z9kmSBKl+T55yeO/i1GhKRXJ
         ha/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXU5K9hWhsQYwhwX4q0Bx+Gq/SGxK5FdlmZG0qh4zuOT5S9+yOF
	Y/qge4doMyaVjKVhDyXm3Ix4Y1im8qoX7IH616HvjDu8i6/+dREJuZSrdhmXd2pIzo9xy4PziNe
	XQWO5mw0yUJJnJTjxIJ+6L8CmthJ2A4sVMJ2w9dYrbl3HOM4KeAH+KwFerlufzxMvIQ==
X-Received: by 2002:ac8:3554:: with SMTP id z20mr2634033qtb.150.1553011464933;
        Tue, 19 Mar 2019 09:04:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIVeZw4LVVzSpA5JBApaNW0lr3KGJZmZpIWmCi5eEk5IM4PUFJmCixV5QEanOpK4AQ86F0
X-Received: by 2002:ac8:3554:: with SMTP id z20mr2633896qtb.150.1553011463430;
        Tue, 19 Mar 2019 09:04:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553011463; cv=none;
        d=google.com; s=arc-20160816;
        b=z+awAe+LNUGcOW8lUip2spdwn7Qm6OOlW9vabe8RHLSIpfdSYuj2TpFu7zu6iMvhMZ
         sq7PZvVqls4qz306sdRd6x7r4nhSY5uwOimg8FnMKDZqe+QANw/Cf+sun5MXsHv/pe14
         lmglymTn6qbGWaXijS/r/icTaV8l8kzN+YjJTKJHkdqCHkS8Eb794zYSDnKsUZx9Y2DT
         ly160T2xdXmxvPPmch7UXPSWck7UM4NMb7wxVTrDb8Y4X4W58VVeV3g/jDK++b4/r0X3
         BVptfpop/rnkGTFrRPj0TtO+CKTryRwNQxE2z/deJ218shCMVkhc8LqrBMkJM3GiQ01H
         LUpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=m4h3Ks/alLuiyZa5RZDI2rTXK/RVdcHXqGrbVw34L3U=;
        b=emORwU4nTngL45PvWqb1s5hodX8mAbasluB49mswR3w75hpwuMO7no0IpCvQgu6cFS
         MxCsHkVhdQiDXafqr2Jj//QcaQ8zOrR9yZgFPtRKRXE6u2LFpUxWuwzQMcWiG/RyKCYh
         HEJPO/b6o1i2mqd5SrjWQMKT9ZNBbdHC1lvOX2kSjI9Sf5hSs7o8L4L9Q6ceeD1wfwWO
         VdWWeKhTS7HptkoP9pWJqixJWF5HJTBG+CK/lhshAiA1kbPczY6v2L6qlFEtFLukUZRU
         wMNCiR6ixXfo1FKkt+dL/5gyAPQcQHbupgR3i8c85ZOJkd0y7+xNZWXV2BE3Buf6I2og
         EWFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f186si774587qkj.215.2019.03.19.09.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 09:04:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5308F88ABB;
	Tue, 19 Mar 2019 16:04:22 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 59E455ED4B;
	Tue, 19 Mar 2019 16:04:14 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
 <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
 <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
 <4bd54f8b-3e9a-3493-40be-668962282431@redhat.com>
Organization: Red Hat Inc,
Message-ID: <6d744ed6-9c1c-b29f-aa32-d38387187b74@redhat.com>
Date: Tue, 19 Mar 2019 12:04:10 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <4bd54f8b-3e9a-3493-40be-668962282431@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="bngpZeDFBG5YQlJZHTX7GAJbxAZIgGJpz"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 19 Mar 2019 16:04:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bngpZeDFBG5YQlJZHTX7GAJbxAZIgGJpz
Content-Type: multipart/mixed; boundary="xij0SfXTxv9ESuRQf6kkiHtCdknUHZkAF";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <6d744ed6-9c1c-b29f-aa32-d38387187b74@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--xij0SfXTxv9ESuRQf6kkiHtCdknUHZkAF
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/19/19 9:33 AM, David Hildenbrand wrote:
> On 18.03.19 16:57, Nitesh Narayan Lal wrote:
>> On 3/14/19 12:58 PM, Alexander Duyck wrote:
>>> On Thu, Mar 14, 2019 at 9:43 AM Nitesh Narayan Lal <nitesh@redhat.com=
> wrote:
>>>> On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
>>>>> On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wrote:=

>>>>>> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
>>>>>>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrot=
e:
>>>>>>>> The following patch-set proposes an efficient mechanism for hand=
ing freed memory between the guest and the host. It enables the guests wi=
th no page cache to rapidly free and reclaims memory to and from the host=
 respectively.
>>>>>>>>
>>>>>>>> Benefit:
>>>>>>>> With this patch-series, in our test-case, executed on a single s=
ystem and single NUMA node with 15GB memory, we were able to successfully=
 launch 5 guests(each with 5 GB memory) when page hinting was enabled and=
 3 without it. (Detailed explanation of the test procedure is provided at=
 the bottom under Test - 1).
>>>>>>>>
>>>>>>>> Changelog in v9:
>>>>>>>>    * Guest free page hinting hook is now invoked after a page ha=
s been merged in the buddy.
>>>>>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER=
(currently defined as MAX_ORDER - 1) are captured.
>>>>>>>>    * Removed kthread which was earlier used to perform the scann=
ing, isolation & reporting of free pages.
>>>>>>>>    * Pages, captured in the per cpu array are sorted based on th=
e zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>>>>>         * Dynamically allocated space is used to hold the isolat=
ed guest free pages.
>>>>>>>>         * All the pages are reported asynchronously to the host =
via virtio driver.
>>>>>>>>         * Pages are returned back to the guest buddy free list o=
nly when the host response is received.
>>>>>>>>
>>>>>>>> Pending items:
>>>>>>>>         * Make sure that the guest free page hinting's current i=
mplementation doesn't break hugepages or device assigned guests.
>>>>>>>>    * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side sup=
port. (It is currently missing)
>>>>>>>>         * Compare reporting free pages via vring with vhost.
>>>>>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>>>>>>    * Analyze overall performance impact due to guest free page h=
inting.
>>>>>>>>    * Come up with proper/traceable error-message/logs.
>>>>>>>>
>>>>>>>> Tests:
>>>>>>>> 1. Use-case - Number of guests we can launch
>>>>>>>>
>>>>>>>>    NUMA Nodes =3D 1 with 15 GB memory
>>>>>>>>    Guest Memory =3D 5 GB
>>>>>>>>    Number of cores in guest =3D 1
>>>>>>>>    Workload =3D test allocation program allocates 4GB memory, to=
uches it via memset and exits.
>>>>>>>>    Procedure =3D
>>>>>>>>    The first guest is launched and once its console is up, the t=
est allocation program is executed with 4 GB memory request (Due to this =
the guest occupies almost 4-5 GB of memory in the host in a system withou=
t page hinting). Once this program exits at that time another guest is la=
unched in the host and the same process is followed. We continue launchin=
g the guests until a guest gets killed due to low memory condition in the=
 host.
>>>>>>>>
>>>>>>>>    Results:
>>>>>>>>    Without hinting =3D 3
>>>>>>>>    With hinting =3D 5
>>>>>>>>
>>>>>>>> 2. Hackbench
>>>>>>>>    Guest Memory =3D 5 GB
>>>>>>>>    Number of cores =3D 4
>>>>>>>>    Number of tasks         Time with Hinting       Time without =
Hinting
>>>>>>>>    4000                    19.540                  17.818
>>>>>>>>
>>>>>>> How about memhog btw?
>>>>>>> Alex reported:
>>>>>>>
>>>>>>>     My testing up till now has consisted of setting up 4 8GB VMs =
on a system
>>>>>>>     with 32GB of memory and 4GB of swap. To stress the memory on =
the system I
>>>>>>>     would run "memhog 8G" sequentially on each of the guests and =
observe how
>>>>>>>     long it took to complete the run. The observed behavior is th=
at on the
>>>>>>>     systems with these patches applied in both the guest and on t=
he host I was
>>>>>>>     able to complete the test with a time of 5 to 7 seconds per g=
uest. On a
>>>>>>>     system without these patches the time ranged from 7 to 49 sec=
onds per
>>>>>>>     guest. I am assuming the variability is due to time being spe=
nt writing
>>>>>>>     pages out to disk in order to free up space for the guest.
>>>>>>>
>>>>>> Here are the results:
>>>>>>
>>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node =
with
>>>>>> total memory of 15GB and no swap. In each of the guest, memhog is =
run
>>>>>> with 5GB. Post-execution of memhog, Host memory usage is monitored=
 by
>>>>>> using Free command.
>>>>>>
>>>>>> Without Hinting:
>>>>>>                  Time of execution    Host used memory
>>>>>> Guest 1:        45 seconds            5.4 GB
>>>>>> Guest 2:        45 seconds            10 GB
>>>>>> Guest 3:        1  minute               15 GB
>>>>>>
>>>>>> With Hinting:
>>>>>>                 Time of execution     Host used memory
>>>>>> Guest 1:        49 seconds            2.4 GB
>>>>>> Guest 2:        40 seconds            4.3 GB
>>>>>> Guest 3:        50 seconds            6.3 GB
>>>>> OK so no improvement. OTOH Alex's patches cut time down to 5-7 seco=
nds
>>>>> which seems better. Want to try testing Alex's patches for comparis=
on?
>>>>>
>>>> I realized that the last time I reported the memhog numbers, I didn'=
t
>>>> enable the swap due to which the actual benefits of the series were =
not
>>>> shown.
>>>> I have re-run the test by including some of the changes suggested by=

>>>> Alexander and David:
>>>>     * Reduced the size of the per-cpu array to 32 and minimum hintin=
g
>>>> threshold to 16.
>>>>     * Reported length of isolated pages along with start pfn, instea=
d of
>>>> the order from the guest.
>>>>     * Used the reported length to madvise the entire length of addre=
ss
>>>> instead of a single 4K page.
>>>>     * Replaced MADV_DONTNEED with MADV_FREE.
>>>>
>>>> Setup for the test:
>>>> NUMA node:1
>>>> Memory: 15GB
>>>> Swap: 4GB
>>>> Guest memory: 6GB
>>>> Number of core: 1
>>>>
>>>> Process: A guest is launched and memhog is run with 6GB. As its
>>>> execution is over next guest is launched. Everytime memhog execution=

>>>> time is monitored.
>>>> Results:
>>>>     Without Hinting:
>>>>                  Time of execution
>>>>     Guest1:    22s
>>>>     Guest2:    24s
>>>>     Guest3: 1m29s
>>>>
>>>>     With Hinting:
>>>>                 Time of execution
>>>>     Guest1:    24s
>>>>     Guest2:    25s
>>>>     Guest3:    28s
>>>>
>>>> When hinting is enabled swap space is not used until memhog with 6GB=
 is
>>>> ran in 6th guest.
>>> So one change you may want to make to your test setup would be to
>>> launch the tests sequentially after all the guests all up, instead of=

>>> combining the test and guest bring-up. In addition you could run
>>> through the guests more than once to determine a more-or-less steady
>>> state in terms of the performance as you move between the guests afte=
r
>>> they have hit the point of having to either swap or pull MADV_FREE
>>> pages.
>> I tried running memhog as you suggested, here are the results:
>> Setup for the test:
>> NUMA node:1
>> Memory: 15GB
>> Swap: 4GB
>> Guest memory: 6GB
>> Number of core: 1
>>
>> Process: 3 guests are launched and memhog is run with 6GB. Results are=

>> monitored after 1st-time execution of memhog. Memhog is launched
>> sequentially in each of the guests and time is observed after the
>> execution of all 3 memhog is over.
>>
>> Results:
>> Without Hinting
>> =C2=A0=C2=A0=C2=A0 Time of Execution=C2=A0=C2=A0=C2=A0
>> 1.=C2=A0=C2=A0=C2=A0 6m48s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=
=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
>> 2.=C2=A0=C2=A0=C2=A0 6m9s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 =C2=A0=C2=A0=C2=A0
>>
>> With Hinting
>> Array size:16 Minimum Threshold:8
>> 1.=C2=A0=C2=A0=C2=A0 2m57s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=
=C2=A0=C2=A0
>> 2.=C2=A0=C2=A0=C2=A0 2m20s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=
=C2=A0=C2=A0
>>
>> The memhog execution time in the case of hinting is still not that low=

>> as we would have expected. This is due to the usage of swap space.
>> Although wrt to non-hinting when swap used space is around 3.5G, with
>> hinting it remains to around 1.1-1.5G.
>> I did try using a zone free page barrier which prevented hinting when
>> free pages of order HINTING_ORDER goes below 256. This further brings
>> down the swap usage to 100-150 MB. The tricky part of this approach is=

>> to configure this barrier condition for different guests.
>>
>> Array size:16 Minimum Threshold:8
>> 1.=C2=A0=C2=A0=C2=A0 1m16s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
>> 2.=C2=A0=C2=A0=C2=A0 1m41s
>>
>> Note: Memhog time does seem to vary a little bit on every boot with or=

>> without hinting.
>>
> I don't quite understand yet why "hinting more pages" (no free page
> barrier) should result in a higher swap usage in the hypervisor
> (1.1-1.5GB vs. 100-150 MB). If we are "hinting more pages" I would have=

> guessed that runtime could get slower, but not that we need more swap.
>
> One theory:
>
> If you hint all MAX_ORDER - 1 pages, at one point it could be that all
> "remaining" free pages are currently isolated to be hinted. As MM needs=

> more pages for a process, it will fallback to using "MAX_ORDER - 2"
> pages and so on. These pages, when they are freed, you won't hint
> anymore unless they get merged. But after all they won't get merged
> because they can't be merged (otherwise they wouldn't be "MAX_ORDER - 2=
"
> after all right from the beginning).
>
> Try hinting a smaller granularity to see if this could actually be the =
case.
So I have two questions in my mind after looking at the results now:
1. Why swap is coming into the picture when hinting is enabled?
2. Same to what you have raised.
For the 1st question, I think the answer is: (correct me if I am wrong.)
Memhog while writing the memory does free memory but the pages it frees
are of a lower order which doesn't merge until the memhog write
completes. After which we do get the MAX_ORDER - 1 page from the buddy
resulting in hinting.
As all 3 memhog are running parallelly we don't get free memory until
one of them completes.
This does explain that when 3 guests each of 6GB on a 15GB host tries to
run memhog with 6GB parallelly, swap comes into the picture even if
hinting is enabled.

This doesn't explain why putting a barrier or avoid hinting reduced the
swap usage. It seems I possibly had a wrong impression of the delaying
hinting idea which we discussed.
As I was observing the value of the swap at the end of the memhog
execution which is logically incorrect. I will re-run the test and
observe the highest swap usage during the entire execution of memhog for
hinting vs non-hinting.

--=20
Regards
Nitesh


--xij0SfXTxv9ESuRQf6kkiHtCdknUHZkAF--

--bngpZeDFBG5YQlJZHTX7GAJbxAZIgGJpz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyREvoACgkQo4ZA3AYy
ozlSfw/9HNw3Q/Q9wJpjHLWrTP3mtx0SuGZdxt+Tr988Du34jyOROvZ1zm0FVJVO
6HqPDbLOFugIdjQd/flBTHHRcR0kkXb0k1vpcY/9Yx9Eqn9wmnQhWzRPHOCqfJbF
fldrUZDlPRYVK+pPZdutyuH8F+CDbgf5r8R5s7WbkyKF58Phw39iQWkV9o5i1KZT
ui+WitolochhPzmt1eOXf0SuyGBnCfzZV0cxZEFJtI38+tM9IOigBsJmhJnm4nnK
9xBwM4PDKSlHAJ/VAFpDb/WO2cH718mjW3GxcBnS46ibLjOz9DI8Zx7o4CxK40QT
t+XSoUsvXu1fc4QAjXB+VCEb27CZXCfGo6I1Cf60OC/gMVaYBKgaHrLG0LuTJc2A
Su4231D+lpgE2iF1uJulht3yS+hgpo90nj8fWStLgLViLZFQB0gYw02+iES+YMza
qQaXqcremlHbIGZk1rFvg8hfZlMX0dpI2GODwaJ3VEiI560zJt+Wqp0WVJUF7SXF
0Y/ntuW0vYZRjjqPr35w0GIwIuyTRvKn67vmi7emo6SUqgT8Wsft8EtapA7fQzlr
y2UXEKNGBwQjU1lqB05C2Pxy/IBFMiTVh8dRqsGKIlrHM+BAMAVw5mOssgwHqFua
4hIVjJfbI2T4nI5Owz97wtEmDe+W3k8fWKF1ozyoMJRTgwosAZs=
=Y1Dd
-----END PGP SIGNATURE-----

--bngpZeDFBG5YQlJZHTX7GAJbxAZIgGJpz--

