Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C70AAC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65FBD20830
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:28:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65FBD20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 038226B000C; Mon, 25 Mar 2019 10:28:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00E716B000D; Mon, 25 Mar 2019 10:28:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E19166B000E; Mon, 25 Mar 2019 10:28:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE1996B000C
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:28:39 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so10314001qtz.14
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:28:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=+tPj4VES77aqTnztZrRdMjWdo83QLgtcy5FCxZu0Q24=;
        b=q95/8NRz9jgaS5L6LxBwbhDZVIIonlsyhMz01jmqsD37oOcX0FSghD9RODOk0hh6XF
         uiIDL6ngNecIJd/IgLjMKjVCTSE+PBDX9326lNjM7Z7ry2NMDuDpYJC3NcDmh7sjf3Ng
         PwOTtV/sgx9rAlB8OQHttYFpUm8CInEHBU+dqxWQL1q1oTT5N052CEMT9JX2n5X8k2Sz
         7UWMBVBsRACaGiHIoclkWjDhPfjnaa6Z/VdeQfMeoimoXsAsbriSoOMVzJ5Cw58mU9T9
         Qp/Ajum/ssIb8UG8D6QtIjzfhX6SbI7T0sivAi2qLgKFSAifKNNRgaZaGjiywQo7wllM
         RmBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXuHl2fWJVW/G8miAnCoDWdC/QhYmyZOqjLWvj6h9q2bfD1qeKE
	3O4/nmHBzHjGKSAiRXeU9/XpzWtZirgVLcMvS78y7wibvJqPDCV7I6Nyf6Qhpad6OZi+n/ocJ/V
	nWQFyLFCPyZyyCq3+2cGq6Gd82Z+J2fbnqCdo3FXrMoUKepVtNl4Tl33LFE5ul2X42A==
X-Received: by 2002:a0c:9e68:: with SMTP id z40mr9860585qve.19.1553524119443;
        Mon, 25 Mar 2019 07:28:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2DY+gESPA9t3FvhI5c1an606yRqwhtiKXAQ/SJ/LUmYpMtUg1m6EyW8yKQh394x8MpeR5
X-Received: by 2002:a0c:9e68:: with SMTP id z40mr9860479qve.19.1553524118157;
        Mon, 25 Mar 2019 07:28:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524118; cv=none;
        d=google.com; s=arc-20160816;
        b=DoJokWHUfHM7jNXS1OGbJn3XIrpU0S9YkBRroDAb+TkWXzk9eO+qLspO2bQRavNoTI
         iGGtG4WJtjq7GQPjhZa6lGkLOwPet06cSekp04K7FKr5MbSLcU6yvfuicMriMvNkZpM0
         JO8bScdCpCj88d2bwBZHqZObgYpaK0gFkGipokL4kGW+l3G20eCmCABR1dXuNmwzBnod
         HsVoyIdmK0Ar9dg7Pi9AmzCKz7QH3ZgbFN5J3cO+6GmrmGSES19VkuKINf51m2bENVkt
         MI9OZoe0ERLWbO6PS3GrYD/kift7eZjxGzb7Ejl0IpS5O4RfjcHxHYA75jCZT2PmQ49p
         wxAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=+tPj4VES77aqTnztZrRdMjWdo83QLgtcy5FCxZu0Q24=;
        b=eo/e9Iqf9UJAKRDoXJ4R0t6GrDEX7M+UguO6BIBiLlVNwWG+vLRB4ZKjKiuzG0oPZl
         kvQEzJq+38p+7OX0aqNR06YHTE+sMPxeU8vPngn+cvf9sJRy5B3Ae7wlBH1BLU3YtNIU
         jknYwj1MMRLSRsfRXAvD/IqUzquUIUlH0WpiurC8C47B5JFJykwDQH5cHmbYnJfl05nO
         wFKW6b3kohfoiBRKOTiZqMTIcebkvUAhQyEGj8uGKmSKISbTSyiz5xv7HZgAC983Oo0w
         9FERDqgo79s2/YIHiEXku9IpyxF9oU7N+u76LwcQ467DZCAYCAsAxuqiDwDOPTGAXqJh
         kVsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l22si3371851qtl.183.2019.03.25.07.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:28:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 61F7D3084215;
	Mon, 25 Mar 2019 14:28:36 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BB6DBA33BB;
	Mon, 25 Mar 2019 14:27:56 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
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
 <6ab9b763-ac90-b3db-3712-79a20c949d5d@redhat.com>
Organization: Red Hat Inc,
Message-ID: <99b9fa88-17b1-f2a9-7dd4-7a8f6e790d30@redhat.com>
Date: Mon, 25 Mar 2019 10:27:46 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <6ab9b763-ac90-b3db-3712-79a20c949d5d@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="OUEyeRINyY9r7rkz8NWRKqrGFm2wLnu3L"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 25 Mar 2019 14:28:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OUEyeRINyY9r7rkz8NWRKqrGFm2wLnu3L
Content-Type: multipart/mixed; boundary="Uxy1fcR5FM2Ozt00umK0ZxNrLwPctajkC";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <99b9fa88-17b1-f2a9-7dd4-7a8f6e790d30@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--Uxy1fcR5FM2Ozt00umK0ZxNrLwPctajkC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/20/19 9:18 AM, Nitesh Narayan Lal wrote:
> On 3/19/19 1:59 PM, Nitesh Narayan Lal wrote:
>> On 3/19/19 1:38 PM, Alexander Duyck wrote:
>>> On Tue, Mar 19, 2019 at 9:04 AM Nitesh Narayan Lal <nitesh@redhat.com=
> wrote:
>>>> On 3/19/19 9:33 AM, David Hildenbrand wrote:
>>>>> On 18.03.19 16:57, Nitesh Narayan Lal wrote:
>>>>>> On 3/14/19 12:58 PM, Alexander Duyck wrote:
>>>>>>> On Thu, Mar 14, 2019 at 9:43 AM Nitesh Narayan Lal <nitesh@redhat=
=2Ecom> wrote:
>>>>>>>> On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
>>>>>>>>> On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wr=
ote:
>>>>>>>>>> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
>>>>>>>>>>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal =
wrote:
>>>>>>>>>>>> The following patch-set proposes an efficient mechanism for =
handing freed memory between the guest and the host. It enables the guest=
s with no page cache to rapidly free and reclaims memory to and from the =
host respectively.
>>>>>>>>>>>>
>>>>>>>>>>>> Benefit:
>>>>>>>>>>>> With this patch-series, in our test-case, executed on a sing=
le system and single NUMA node with 15GB memory, we were able to successf=
ully launch 5 guests(each with 5 GB memory) when page hinting was enabled=
 and 3 without it. (Detailed explanation of the test procedure is provide=
d at the bottom under Test - 1).
>>>>>>>>>>>>
>>>>>>>>>>>> Changelog in v9:
>>>>>>>>>>>>    * Guest free page hinting hook is now invoked after a pag=
e has been merged in the buddy.
>>>>>>>>>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_O=
RDER(currently defined as MAX_ORDER - 1) are captured.
>>>>>>>>>>>>    * Removed kthread which was earlier used to perform the s=
canning, isolation & reporting of free pages.
>>>>>>>>>>>>    * Pages, captured in the per cpu array are sorted based o=
n the zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>>>>>>>>>         * Dynamically allocated space is used to hold the is=
olated guest free pages.
>>>>>>>>>>>>         * All the pages are reported asynchronously to the h=
ost via virtio driver.
>>>>>>>>>>>>         * Pages are returned back to the guest buddy free li=
st only when the host response is received.
>>>>>>>>>>>>
>>>>>>>>>>>> Pending items:
>>>>>>>>>>>>         * Make sure that the guest free page hinting's curre=
nt implementation doesn't break hugepages or device assigned guests.
>>>>>>>>>>>>    * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side=
 support. (It is currently missing)
>>>>>>>>>>>>         * Compare reporting free pages via vring with vhost.=

>>>>>>>>>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>>>>>>>>>>    * Analyze overall performance impact due to guest free pa=
ge hinting.
>>>>>>>>>>>>    * Come up with proper/traceable error-message/logs.
>>>>>>>>>>>>
>>>>>>>>>>>> Tests:
>>>>>>>>>>>> 1. Use-case - Number of guests we can launch
>>>>>>>>>>>>
>>>>>>>>>>>>    NUMA Nodes =3D 1 with 15 GB memory
>>>>>>>>>>>>    Guest Memory =3D 5 GB
>>>>>>>>>>>>    Number of cores in guest =3D 1
>>>>>>>>>>>>    Workload =3D test allocation program allocates 4GB memory=
, touches it via memset and exits.
>>>>>>>>>>>>    Procedure =3D
>>>>>>>>>>>>    The first guest is launched and once its console is up, t=
he test allocation program is executed with 4 GB memory request (Due to t=
his the guest occupies almost 4-5 GB of memory in the host in a system wi=
thout page hinting). Once this program exits at that time another guest i=
s launched in the host and the same process is followed. We continue laun=
ching the guests until a guest gets killed due to low memory condition in=
 the host.
>>>>>>>>>>>>
>>>>>>>>>>>>    Results:
>>>>>>>>>>>>    Without hinting =3D 3
>>>>>>>>>>>>    With hinting =3D 5
>>>>>>>>>>>>
>>>>>>>>>>>> 2. Hackbench
>>>>>>>>>>>>    Guest Memory =3D 5 GB
>>>>>>>>>>>>    Number of cores =3D 4
>>>>>>>>>>>>    Number of tasks         Time with Hinting       Time with=
out Hinting
>>>>>>>>>>>>    4000                    19.540                  17.818
>>>>>>>>>>>>
>>>>>>>>>>> How about memhog btw?
>>>>>>>>>>> Alex reported:
>>>>>>>>>>>
>>>>>>>>>>>     My testing up till now has consisted of setting up 4 8GB =
VMs on a system
>>>>>>>>>>>     with 32GB of memory and 4GB of swap. To stress the memory=
 on the system I
>>>>>>>>>>>     would run "memhog 8G" sequentially on each of the guests =
and observe how
>>>>>>>>>>>     long it took to complete the run. The observed behavior i=
s that on the
>>>>>>>>>>>     systems with these patches applied in both the guest and =
on the host I was
>>>>>>>>>>>     able to complete the test with a time of 5 to 7 seconds p=
er guest. On a
>>>>>>>>>>>     system without these patches the time ranged from 7 to 49=
 seconds per
>>>>>>>>>>>     guest. I am assuming the variability is due to time being=
 spent writing
>>>>>>>>>>>     pages out to disk in order to free up space for the guest=
=2E
>>>>>>>>>>>
>>>>>>>>>> Here are the results:
>>>>>>>>>>
>>>>>>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA n=
ode with
>>>>>>>>>> total memory of 15GB and no swap. In each of the guest, memhog=
 is run
>>>>>>>>>> with 5GB. Post-execution of memhog, Host memory usage is monit=
ored by
>>>>>>>>>> using Free command.
>>>>>>>>>>
>>>>>>>>>> Without Hinting:
>>>>>>>>>>                  Time of execution    Host used memory
>>>>>>>>>> Guest 1:        45 seconds            5.4 GB
>>>>>>>>>> Guest 2:        45 seconds            10 GB
>>>>>>>>>> Guest 3:        1  minute               15 GB
>>>>>>>>>>
>>>>>>>>>> With Hinting:
>>>>>>>>>>                 Time of execution     Host used memory
>>>>>>>>>> Guest 1:        49 seconds            2.4 GB
>>>>>>>>>> Guest 2:        40 seconds            4.3 GB
>>>>>>>>>> Guest 3:        50 seconds            6.3 GB
>>>>>>>>> OK so no improvement. OTOH Alex's patches cut time down to 5-7 =
seconds
>>>>>>>>> which seems better. Want to try testing Alex's patches for comp=
arison?
>>>>>>>>>
>>>>>>>> I realized that the last time I reported the memhog numbers, I d=
idn't
>>>>>>>> enable the swap due to which the actual benefits of the series w=
ere not
>>>>>>>> shown.
>>>>>>>> I have re-run the test by including some of the changes suggeste=
d by
>>>>>>>> Alexander and David:
>>>>>>>>     * Reduced the size of the per-cpu array to 32 and minimum hi=
nting
>>>>>>>> threshold to 16.
>>>>>>>>     * Reported length of isolated pages along with start pfn, in=
stead of
>>>>>>>> the order from the guest.
>>>>>>>>     * Used the reported length to madvise the entire length of a=
ddress
>>>>>>>> instead of a single 4K page.
>>>>>>>>     * Replaced MADV_DONTNEED with MADV_FREE.
>>>>>>>>
>>>>>>>> Setup for the test:
>>>>>>>> NUMA node:1
>>>>>>>> Memory: 15GB
>>>>>>>> Swap: 4GB
>>>>>>>> Guest memory: 6GB
>>>>>>>> Number of core: 1
>>>>>>>>
>>>>>>>> Process: A guest is launched and memhog is run with 6GB. As its
>>>>>>>> execution is over next guest is launched. Everytime memhog execu=
tion
>>>>>>>> time is monitored.
>>>>>>>> Results:
>>>>>>>>     Without Hinting:
>>>>>>>>                  Time of execution
>>>>>>>>     Guest1:    22s
>>>>>>>>     Guest2:    24s
>>>>>>>>     Guest3: 1m29s
>>>>>>>>
>>>>>>>>     With Hinting:
>>>>>>>>                 Time of execution
>>>>>>>>     Guest1:    24s
>>>>>>>>     Guest2:    25s
>>>>>>>>     Guest3:    28s
>>>>>>>>
>>>>>>>> When hinting is enabled swap space is not used until memhog with=
 6GB is
>>>>>>>> ran in 6th guest.
>>>>>>> So one change you may want to make to your test setup would be to=

>>>>>>> launch the tests sequentially after all the guests all up, instea=
d of
>>>>>>> combining the test and guest bring-up. In addition you could run
>>>>>>> through the guests more than once to determine a more-or-less ste=
ady
>>>>>>> state in terms of the performance as you move between the guests =
after
>>>>>>> they have hit the point of having to either swap or pull MADV_FRE=
E
>>>>>>> pages.
>>>>>> I tried running memhog as you suggested, here are the results:
>>>>>> Setup for the test:
>>>>>> NUMA node:1
>>>>>> Memory: 15GB
>>>>>> Swap: 4GB
>>>>>> Guest memory: 6GB
>>>>>> Number of core: 1
>>>>>>
>>>>>> Process: 3 guests are launched and memhog is run with 6GB. Results=
 are
>>>>>> monitored after 1st-time execution of memhog. Memhog is launched
>>>>>> sequentially in each of the guests and time is observed after the
>>>>>> execution of all 3 memhog is over.
>>>>>>
>>>>>> Results:
>>>>>> Without Hinting
>>>>>>     Time of Execution
>>>>>> 1.    6m48s
>>>>>> 2.    6m9s
>>>>>>
>>>>>> With Hinting
>>>>>> Array size:16 Minimum Threshold:8
>>>>>> 1.    2m57s
>>>>>> 2.    2m20s
>>>>>>
>>>>>> The memhog execution time in the case of hinting is still not that=
 low
>>>>>> as we would have expected. This is due to the usage of swap space.=

>>>>>> Although wrt to non-hinting when swap used space is around 3.5G, w=
ith
>>>>>> hinting it remains to around 1.1-1.5G.
>>>>>> I did try using a zone free page barrier which prevented hinting w=
hen
>>>>>> free pages of order HINTING_ORDER goes below 256. This further bri=
ngs
>>>>>> down the swap usage to 100-150 MB. The tricky part of this approac=
h is
>>>>>> to configure this barrier condition for different guests.
>>>>>>
>>>>>> Array size:16 Minimum Threshold:8
>>>>>> 1.    1m16s
>>>>>> 2.    1m41s
>>>>>>
>>>>>> Note: Memhog time does seem to vary a little bit on every boot wit=
h or
>>>>>> without hinting.
>>>>>>
>>>>> I don't quite understand yet why "hinting more pages" (no free page=

>>>>> barrier) should result in a higher swap usage in the hypervisor
>>>>> (1.1-1.5GB vs. 100-150 MB). If we are "hinting more pages" I would =
have
>>>>> guessed that runtime could get slower, but not that we need more sw=
ap.
>>>>>
>>>>> One theory:
>>>>>
>>>>> If you hint all MAX_ORDER - 1 pages, at one point it could be that =
all
>>>>> "remaining" free pages are currently isolated to be hinted. As MM n=
eeds
>>>>> more pages for a process, it will fallback to using "MAX_ORDER - 2"=

>>>>> pages and so on. These pages, when they are freed, you won't hint
>>>>> anymore unless they get merged. But after all they won't get merged=

>>>>> because they can't be merged (otherwise they wouldn't be "MAX_ORDER=
 - 2"
>>>>> after all right from the beginning).
>>>>>
>>>>> Try hinting a smaller granularity to see if this could actually be =
the case.
>>>> So I have two questions in my mind after looking at the results now:=

>>>> 1. Why swap is coming into the picture when hinting is enabled?
>>>> 2. Same to what you have raised.
>>>> For the 1st question, I think the answer is: (correct me if I am wro=
ng.)
>>>> Memhog while writing the memory does free memory but the pages it fr=
ees
>>>> are of a lower order which doesn't merge until the memhog write
>>>> completes. After which we do get the MAX_ORDER - 1 page from the bud=
dy
>>>> resulting in hinting.
>>>> As all 3 memhog are running parallelly we don't get free memory unti=
l
>>>> one of them completes.
>>>> This does explain that when 3 guests each of 6GB on a 15GB host trie=
s to
>>>> run memhog with 6GB parallelly, swap comes into the picture even if
>>>> hinting is enabled.
>>> Are you running them in parallel or sequentially?=20
>> I was running them parallelly but then I realized to see any benefits,=

>> in that case, I should have run less number of guests.
>>> I had suggested
>>> running them serially so that the previous one could complete and fre=
e
>>> the memory before the next one allocated memory. In that setup you
>>> should see the guests still swapping without hints, but with hints th=
e
>>> guest should free the memory up before the next one starts using it.
>> Yeah, I just realized this. Thanks for the clarification.
>>> If you are running them in parallel then you are going to see things
>>> going to swap because memhog does like what the name implies and it
>>> will use all of the memory you give it. It isn't until it completes
>>> that the memory is freed.
>>>
>>>> This doesn't explain why putting a barrier or avoid hinting reduced =
the
>>>> swap usage. It seems I possibly had a wrong impression of the delayi=
ng
>>>> hinting idea which we discussed.
>>>> As I was observing the value of the swap at the end of the memhog
>>>> execution which is logically incorrect. I will re-run the test and
>>>> observe the highest swap usage during the entire execution of memhog=
 for
>>>> hinting vs non-hinting.
>>> So one option you may look at if you are wanting to run the tests in
>>> parallel would be to limit the number of tests you have running at th=
e
>>> same time. If you have 15G of memory and 6G per guest you should be
>>> able to run 2 sessions at a time without going to swap, however if yo=
u
>>> run all 3 then you are likely going to be going to swap even with
>>> hinting.
>>>
>>> - Alex
> Here are the updated numbers excluding the guest bring-up cost:
> Setup for the test-
> NUMA node:1
> Memory: 15GB
> Swap: 4GB
> Guest memory: 6GB
> Number of core: 1
> Process: 3 guests are launched and memhog is run serially with 6GB.
> Results:
> Without Hinting
> =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=
=A0 =C2=A0=C2=A0=C2=A0 Time of Execution=C2=A0=C2=A0=C2=A0
> Guest1:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 56s =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
> Guest2: =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0=
 45s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
> Guest3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 3m41s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
>
> With Hinting
> Guest1:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 46s =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
> Guest2: =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 45s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
> Guest3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 49s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
>
>
>
>
I performed some experiments to see if the current implementation of
hinting breaks THP. I used AnonHugePages to track the THP pages
currently in use and memhog as the guest workload.
Setup:
Host Size: 30GB (No swap)
Guest Size: 15GB
THP Size: 2MB
Process: Guest is installed with different kernels to hint different
granularities(MAX_ORDER - 1, MAX_ORDER - 2 and MAX_ORDER - 3). Memhog=C2=A0=

15G is run multiple times in the same guest to see AnonHugePages usage
in the host.

Observation:
There is no THP split for order MAX_ORDER - 1 & MAX_ORDER - 2 whereas
for hinting granularity MAX_ORDER - 3 THP does split irrespective of
MADVISE_FREE or MADVISE_DONTNEED.
--=20
Regards
Nitesh


--Uxy1fcR5FM2Ozt00umK0ZxNrLwPctajkC--

--OUEyeRINyY9r7rkz8NWRKqrGFm2wLnu3L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyY5WIACgkQo4ZA3AYy
ozmVbxAAgmGMsb521ImWzCfauPnm+tep4pu3vb4EKBM+pSlbARwL25A2qTu+tXc7
tysKvC4U0OZ/oIPi4/q4NfpyvdRYXzS/SkQeK5paQHsxrjjzzsoEJyckbnjfqy5v
NXMDEEYm0rZiWeeUCrY4iyZ73sbLUQNXk9RAVybbvg3mHm6TgSSXQZsn05YAwCIs
Ue29RUIcmktloUObMxKekVQelu8txqpCLHBWq/wDkfxvAymkQKMj5ebGBBqkrSUW
pEl1BPl1nPHpwuiYpwp9GBVqaoGoycRTm/SHJ6zEqy7f5DvWr0Wo7y0DMdRiTyfI
xmTShn4gOfxKBy8sYAtr+gtdrqUjRaLd4JJnBzlGgEeTX9H3hOKL6vk2SHPO73Qd
RnCE+3YHdgON3sv2/K6XqvF700jiLbB+nDPAqbUjr/mkOC7IYFs55GlZKNnokTVq
OUaMSrBhNUFYkOZ86usN04EqNW8sFatNnHNhd8PhS0Rqcu0W0Q7X6rCSeI+mWf3z
cO3XYHqtewV1OLt+LHrEs4GTvHdZWR0h4DNy2N4Tdd4ymIpMwCOXj6ioK8Sdo8Nc
5XBi/5/uWCoGXzwcO1lTwWrSoFsZtYv3XRdyKCCBiGF1YlR9m1Dp4EJWLt6hply9
g2RpzFk/QzNiPthoBwSz03DpLaKrFCn7sngIPmtKXGcuAdOGXqI=
=hmRu
-----END PGP SIGNATURE-----

--OUEyeRINyY9r7rkz8NWRKqrGFm2wLnu3L--

