Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16ECEC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC3F520989
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:00:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC3F520989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D64B6B0003; Mon, 18 Mar 2019 12:00:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 585A56B0006; Mon, 18 Mar 2019 12:00:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44D8F6B0007; Mon, 18 Mar 2019 12:00:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 161F36B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:00:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id j22so16670299qtq.21
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:00:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=try7BWwPhfJk8urEquLNcFg4gY0awL19W67XNflfLLQ=;
        b=t3fs4MbD8+rGSHUChqyheDkItP3vPiP2HcTt5yoMS8ytoMatvx+L3w2hM2HYTdIAvL
         1RqvqJXSmQy2ir9WDhxKjo7K8El0MFByjHEHQfZbmqNHYd6M9/uHvOdorWH915uDMVRE
         9y+p2z6f+6ODWgJDFpTNrKLlsvzrNCG3ID0TjTC6L4xRS069utJvF7DlB2ruy+UtFUqL
         9P/oZeOCgG2PlYg83vR0dNRGiIqRhbutVu7IBd0EioyHhN3cttpCrA5nlpBYxwDWo6gN
         HjwTdPihOiI7L/lnOrHwNqwx5tlvHdJF+ah3TUXuR75cmZ4PDqc+hFbok2nPrBav/Tdq
         mB/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXjHC0vUYr8z6CmMrl2Hra2FPy6+ZHju2iBodGb9xCd58OvYbNA
	caHEgsLJGrE/591wMrA72MNdsS3Q4VWfSF1Tcr5ZzCuugGaCHkg8j38Iu0+eJloRQJAK8bGA68t
	3xe/TLKjOdBR/sd24itAxbU5vsYV5TmNHab4iwIMjuja+wx4XqxCVAJAMB0Ejkbc4ZQ==
X-Received: by 2002:a0c:e703:: with SMTP id d3mr13708508qvn.47.1552924833823;
        Mon, 18 Mar 2019 09:00:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+bG7I0Ipk3lmYEHBhhQOGqg5DT0SaCvVIn/VUNgI+/I1vCWPUcNpEjt8C2XnRUoAYima1
X-Received: by 2002:a0c:e703:: with SMTP id d3mr13708415qvn.47.1552924832590;
        Mon, 18 Mar 2019 09:00:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552924832; cv=none;
        d=google.com; s=arc-20160816;
        b=JnhfwHdpO6sVOYNrnCVDvfGfBAGp0g53hU32PrzZDh3Baa4iQbZxqIlx5qDQPC4VbB
         11p1c00aywPNvcZpjABPYG7zfBNTmAovqfAbm0f2KrxTXV5mF7GauBHgAxRlcf5oDRdP
         s99QaO9d/GOq/GoRtKOxIa2Xwy9JNIDfdIUzb33u8+IO4TRo+m2oFZ0IyClA+Jd0Ejwi
         1YyO5DJ1t0weOWw/jX6MirMFrJRK356F8C84R2g+ouFQTK2jl4zSe1Py+Nlnye0m+3d4
         iEkdt5C2pG7QqeP+8U5F150qPdua/h0ytsxe5hRIKUJaLL3sOz1CpheiJW8nRGJDf0FC
         ZWAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=try7BWwPhfJk8urEquLNcFg4gY0awL19W67XNflfLLQ=;
        b=J2nCuizFNeVGLrvgAVigehrT9rw0jj8Yg/3odEZfwW3ikEZLMTPPKRQZypY0n3kVcj
         DTOdTGD+ZTJeZNaUB5o9io6wvvMOeMjF64IyxyXkZYNu4HmlDPLOSMfeLUc80zIXmQMQ
         pjzW3V1N7ATu5bH24tSsTQjckhHCHr3wWOvJnmUodn0JoAWAJxBNl2urMY12j/KnbMwO
         DShMxFAfeDt27aX2hdICTdQPKgNzHDZUWGmhGvVIMlhc9bIu6azdOh59WyZecPSE0CYB
         2+SeI1095+PMKGONnXTbFblglt+AiYGI+F8m0GnaKej1GfQS7n4RWV7reBjLUc8e7OcM
         sSNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n2si52398qtc.174.2019.03.18.09.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 09:00:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A8584307D924;
	Mon, 18 Mar 2019 16:00:31 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 30CBF65937;
	Mon, 18 Mar 2019 15:57:56 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, dodgen@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
 <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
Organization: Red Hat Inc,
Message-ID: <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
Date: Mon, 18 Mar 2019 11:57:36 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="QgbaQ4lppI6BXRwNtGzYRYDLSXMaz7nNp"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 18 Mar 2019 16:00:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QgbaQ4lppI6BXRwNtGzYRYDLSXMaz7nNp
Content-Type: multipart/mixed; boundary="E1LMHVMde3o9gs1ZYzDopeTWgLh5rWpyH";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, dodgen@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--E1LMHVMde3o9gs1ZYzDopeTWgLh5rWpyH
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/14/19 12:58 PM, Alexander Duyck wrote:
> On Thu, Mar 14, 2019 at 9:43 AM Nitesh Narayan Lal <nitesh@redhat.com> =
wrote:
>>
>> On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
>>> On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wrote:
>>>> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
>>>>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrote:=

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
>>>>>>    * Guest free page hinting hook is now invoked after a page has =
been merged in the buddy.
>>>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(c=
urrently defined as MAX_ORDER - 1) are captured.
>>>>>>    * Removed kthread which was earlier used to perform the scannin=
g, isolation & reporting of free pages.
>>>>>>    * Pages, captured in the per cpu array are sorted based on the =
zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>>>         * Dynamically allocated space is used to hold the isolated=
 guest free pages.
>>>>>>         * All the pages are reported asynchronously to the host vi=
a virtio driver.
>>>>>>         * Pages are returned back to the guest buddy free list onl=
y when the host response is received.
>>>>>>
>>>>>> Pending items:
>>>>>>         * Make sure that the guest free page hinting's current imp=
lementation doesn't break hugepages or device assigned guests.
>>>>>>    * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side suppo=
rt. (It is currently missing)
>>>>>>         * Compare reporting free pages via vring with vhost.
>>>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>>>>    * Analyze overall performance impact due to guest free page hin=
ting.
>>>>>>    * Come up with proper/traceable error-message/logs.
>>>>>>
>>>>>> Tests:
>>>>>> 1. Use-case - Number of guests we can launch
>>>>>>
>>>>>>    NUMA Nodes =3D 1 with 15 GB memory
>>>>>>    Guest Memory =3D 5 GB
>>>>>>    Number of cores in guest =3D 1
>>>>>>    Workload =3D test allocation program allocates 4GB memory, touc=
hes it via memset and exits.
>>>>>>    Procedure =3D
>>>>>>    The first guest is launched and once its console is up, the tes=
t allocation program is executed with 4 GB memory request (Due to this th=
e guest occupies almost 4-5 GB of memory in the host in a system without =
page hinting). Once this program exits at that time another guest is laun=
ched in the host and the same process is followed. We continue launching =
the guests until a guest gets killed due to low memory condition in the h=
ost.
>>>>>>
>>>>>>    Results:
>>>>>>    Without hinting =3D 3
>>>>>>    With hinting =3D 5
>>>>>>
>>>>>> 2. Hackbench
>>>>>>    Guest Memory =3D 5 GB
>>>>>>    Number of cores =3D 4
>>>>>>    Number of tasks         Time with Hinting       Time without Hi=
nting
>>>>>>    4000                    19.540                  17.818
>>>>>>
>>>>> How about memhog btw?
>>>>> Alex reported:
>>>>>
>>>>>     My testing up till now has consisted of setting up 4 8GB VMs on=
 a system
>>>>>     with 32GB of memory and 4GB of swap. To stress the memory on th=
e system I
>>>>>     would run "memhog 8G" sequentially on each of the guests and ob=
serve how
>>>>>     long it took to complete the run. The observed behavior is that=
 on the
>>>>>     systems with these patches applied in both the guest and on the=
 host I was
>>>>>     able to complete the test with a time of 5 to 7 seconds per gue=
st. On a
>>>>>     system without these patches the time ranged from 7 to 49 secon=
ds per
>>>>>     guest. I am assuming the variability is due to time being spent=
 writing
>>>>>     pages out to disk in order to free up space for the guest.
>>>>>
>>>> Here are the results:
>>>>
>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node wi=
th
>>>> total memory of 15GB and no swap. In each of the guest, memhog is ru=
n
>>>> with 5GB. Post-execution of memhog, Host memory usage is monitored b=
y
>>>> using Free command.
>>>>
>>>> Without Hinting:
>>>>                  Time of execution    Host used memory
>>>> Guest 1:        45 seconds            5.4 GB
>>>> Guest 2:        45 seconds            10 GB
>>>> Guest 3:        1  minute               15 GB
>>>>
>>>> With Hinting:
>>>>                 Time of execution     Host used memory
>>>> Guest 1:        49 seconds            2.4 GB
>>>> Guest 2:        40 seconds            4.3 GB
>>>> Guest 3:        50 seconds            6.3 GB
>>> OK so no improvement. OTOH Alex's patches cut time down to 5-7 second=
s
>>> which seems better. Want to try testing Alex's patches for comparison=
?
>>>
>> I realized that the last time I reported the memhog numbers, I didn't
>> enable the swap due to which the actual benefits of the series were no=
t
>> shown.
>> I have re-run the test by including some of the changes suggested by
>> Alexander and David:
>>     * Reduced the size of the per-cpu array to 32 and minimum hinting
>> threshold to 16.
>>     * Reported length of isolated pages along with start pfn, instead =
of
>> the order from the guest.
>>     * Used the reported length to madvise the entire length of address=

>> instead of a single 4K page.
>>     * Replaced MADV_DONTNEED with MADV_FREE.
>>
>> Setup for the test:
>> NUMA node:1
>> Memory: 15GB
>> Swap: 4GB
>> Guest memory: 6GB
>> Number of core: 1
>>
>> Process: A guest is launched and memhog is run with 6GB. As its
>> execution is over next guest is launched. Everytime memhog execution
>> time is monitored.
>> Results:
>>     Without Hinting:
>>                  Time of execution
>>     Guest1:    22s
>>     Guest2:    24s
>>     Guest3: 1m29s
>>
>>     With Hinting:
>>                 Time of execution
>>     Guest1:    24s
>>     Guest2:    25s
>>     Guest3:    28s
>>
>> When hinting is enabled swap space is not used until memhog with 6GB i=
s
>> ran in 6th guest.
> So one change you may want to make to your test setup would be to
> launch the tests sequentially after all the guests all up, instead of
> combining the test and guest bring-up. In addition you could run
> through the guests more than once to determine a more-or-less steady
> state in terms of the performance as you move between the guests after
> they have hit the point of having to either swap or pull MADV_FREE
> pages.
I tried running memhog as you suggested, here are the results:
Setup for the test:
NUMA node:1
Memory: 15GB
Swap: 4GB
Guest memory: 6GB
Number of core: 1

Process: 3 guests are launched and memhog is run with 6GB. Results are
monitored after 1st-time execution of memhog. Memhog is launched
sequentially in each of the guests and time is observed after the
execution of all 3 memhog is over.

Results:
Without Hinting
=C2=A0=C2=A0=C2=A0 Time of Execution=C2=A0=C2=A0=C2=A0
1.=C2=A0=C2=A0=C2=A0 6m48s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
2.=C2=A0=C2=A0=C2=A0 6m9s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=
=C2=A0 =C2=A0=C2=A0=C2=A0

With Hinting
Array size:16 Minimum Threshold:8
1.=C2=A0=C2=A0=C2=A0 2m57s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0
2.=C2=A0=C2=A0=C2=A0 2m20s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0

The memhog execution time in the case of hinting is still not that low
as we would have expected. This is due to the usage of swap space.
Although wrt to non-hinting when swap used space is around 3.5G, with
hinting it remains to around 1.1-1.5G.
I did try using a zone free page barrier which prevented hinting when
free pages of order HINTING_ORDER goes below 256. This further brings
down the swap usage to 100-150 MB. The tricky part of this approach is
to configure this barrier condition for different guests.

Array size:16 Minimum Threshold:8
1.=C2=A0=C2=A0=C2=A0 1m16s=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0
2.=C2=A0=C2=A0=C2=A0 1m41s

Note: Memhog time does seem to vary a little bit on every boot with or
without hinting.

--=20
Regards
Nitesh


--E1LMHVMde3o9gs1ZYzDopeTWgLh5rWpyH--

--QgbaQ4lppI6BXRwNtGzYRYDLSXMaz7nNp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyPv/EACgkQo4ZA3AYy
ozmzVRAAvpsYm1Dp878O9luUU/w6pEc5Q9hsdVKP4cwtnhznnZ7p/vhgSQky4XPs
/sAusVdWv/Sd5RZ3uobXT22RjyNDeM12WW7R9YKRdSjtSJ1ly0oo3rdJhBU6ilJy
JM/V92FWmVqskNW3ThbLFxtiBuia3pU0xyVXvDRRtt15IcFbeXmaDov6T6gBB9Rg
xvq1Zo6XX62UuBE/rObbLAG9Mg2JZIfil4VdEIV8pKwH7xdFUujgodeu9J4+Rlaf
OH00nsF9vhC9Q9Z16nc45ahFJ4eo+7Pz6M2H7W4xcnJXp2nQxlgc2fRs+xqQ9Dko
tlk3aCXGaSN1DELFiQK0vMiP41TQrgC/Nd8RJCneDyT3z/D/YlKhvrGFPq3DFHtE
jLHEiwmblTNBcj1lhHLY0JDZrctAb5y7cyPU5jM47suLNGNVfHOH+f1hcxXBxviw
LNAwLkWfWOkfzaBMUqdGxFoZLVB7JARoYFn06S0Q2TUe8OoQMxAY0Dbi3RiJ/nyf
FyIxpdYWT+ZzGtewzxrsF13xdLZNPPdo2UwSbUYC09HInYWbHTovzNIji6016tfv
2vOVO2XnvOqKo6tLVWTiF8NnQ3togNhAbHctcMRcVZrm+4GQD31n4tVLx3JICwKc
GVEvzved8otGZYIhb5W+yIESOgREu9TvoFPJVuqek2UsvXQBQsI=
=i7/q
-----END PGP SIGNATURE-----

--QgbaQ4lppI6BXRwNtGzYRYDLSXMaz7nNp--

