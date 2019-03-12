Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ED84C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:46:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE64C2087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:46:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE64C2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E5E58E0004; Tue, 12 Mar 2019 15:46:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56B928E0002; Tue, 12 Mar 2019 15:46:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4340C8E0004; Tue, 12 Mar 2019 15:46:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE488E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:46:33 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id e25so3157454qkj.12
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:46:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=x/vgSIxrwZmnJzxr/QKnAsGFBNJzTJdilmPRj/kT+E8=;
        b=nMvw7CxZvPIEy+4odk4/PdKAzgPXnJeZRhhwPYHleGGGUMHVBBe/WOcSHKgWeBKybI
         sUbpXRGLNKELS/kgq/whpDhG77SLiixr2A5PCfHb5/moY7s+9VSvjFeCbwKjInNuuKlj
         tqsnE97HxJNmCiGZQBtEHdVuIm6VmcntZgCKndeQt/psFLU0SG2h8kj0W5FAVexKaaU6
         k66oIDkYZqfPwQTguoU2XsrqzxEl0tMDYNz5gK1yJboEJMkAoXZs4wOJHQMb2KGP9aSU
         IHJxqSI+0P0fvzTh1UH/up3fkVPyl3ua4biif3FF7mskiJTNFbEVMfmIO1DLr3bTOfJl
         le4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGJJOviq340zKJsnGxvCMFDLl6ROQXhtM4xdbq7QudXG2qETKO
	QiNwsihvdYowYWZ73PvK0zYXY0xaPH73BFTAH9n7QlMOvJWoxXn/YWah54pF40he9Pg9HvFTxCs
	2C85Uv2y/xwwGBR+I7QWBIUz6W5z4STpYeKhQnjSRAeXbsZJeAMZ4BlN+PHR5Jp2DJw==
X-Received: by 2002:ac8:1884:: with SMTP id s4mr5260826qtj.339.1552419992878;
        Tue, 12 Mar 2019 12:46:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJ51x7rC282oDNQ7jD8KsTabbmB+gTBY67rL7pjKMzarEAhPKo1KHOtYM5XEtnLcJ+AGDj
X-Received: by 2002:ac8:1884:: with SMTP id s4mr5260781qtj.339.1552419991974;
        Tue, 12 Mar 2019 12:46:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552419991; cv=none;
        d=google.com; s=arc-20160816;
        b=vnlj6UEcwxXQOKIb/KxNqaD8IMfg7PV2/DAdHHBgdjrroSaHaSRZJp8xyaDaH0xiSo
         /RRd3Kb41uFIOyFfOM6fpCeu8AQflA/yesn9VNCMfk1G7MbEdy18dfhw1/ErhKdRBzkM
         gPW5nFwR482DlwHr52i7mqe8RhbmZHHcOLPH5tDm6246x7CabLq13cor7kWtRyQOFWb2
         MbJkbLhP5x26qAh/1Nv+ttWbbo21eL3/tELQ8WKeOhTiOcHUTOn0WTY7e5vULD1mHal3
         Tpdtvf1l5pyxFSBvEAUS07AMRr5S84+OEFEanQlnAr8/FNHbNHrUuNLKYnxuenTdi+0M
         RKcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=x/vgSIxrwZmnJzxr/QKnAsGFBNJzTJdilmPRj/kT+E8=;
        b=gBTo6s7gJJXlW0EdGfIGigjOPYFBI7zQ3Q6IqqwsTuclabAkvyNnhFtbsc/a1za9/P
         njq6LpSO9wvgz5ggXYdf0y/kbBbF9N6YUiicJdx3KBWvhQY6q03cNOmoyosM7zsY5DEd
         tXQcE43N3vTn0ryu7pUSNBO6gflg2vqXWaVor4/81CteGPwxu8NF2VVF1oEISj8XOoS1
         trbvq0/M9j+R2K+ECxIXODaSR/NVnW/SSC5G0MN2WkjbYpA4fKBjs+ZWwA8fSIosJclC
         e7FWXJF+zhrqG/UHB+3MWwM9Tvr/7HFHp5wMBfmCrm8MlZONpjoTwMScKoTwMtbbXJ0M
         pOMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f5si408731qtb.56.2019.03.12.12.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 12:46:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0C1EA8F860;
	Tue, 12 Mar 2019 19:46:31 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5E22660BF7;
	Tue, 12 Mar 2019 19:46:19 +0000 (UTC)
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
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org>
 <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com>
 <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
 <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com>
 <CAKgT0UddT9CKg1uZo6ZODs9ARti-6XGm9Zvo+8QRZKUPSwzWMQ@mail.gmail.com>
Organization: Red Hat Inc,
Message-ID: <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com>
Date: Tue, 12 Mar 2019 15:46:15 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UddT9CKg1uZo6ZODs9ARti-6XGm9Zvo+8QRZKUPSwzWMQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="OxKmVXZle8XZPHQokqhweRMEdqZsPL0jS"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 12 Mar 2019 19:46:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OxKmVXZle8XZPHQokqhweRMEdqZsPL0jS
Content-Type: multipart/mixed; boundary="Q2ysSGlqobWbBDV2hKjOD9Aas8wcksB0W";
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
Message-ID: <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages

--Q2ysSGlqobWbBDV2hKjOD9Aas8wcksB0W
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/8/19 4:39 PM, Alexander Duyck wrote:
> On Fri, Mar 8, 2019 at 11:39 AM Nitesh Narayan Lal <nitesh@redhat.com> =
wrote:
>> On 3/8/19 2:25 PM, Alexander Duyck wrote:
>>> On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat.com=
> wrote:
>>>> On 3/8/19 1:06 PM, Alexander Duyck wrote:
>>>>> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> =
wrote:
>>>>>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
>>>>>>> The only other thing I still want to try and see if I can do is t=
o add
>>>>>>> a jiffies value to the page private data in the case of the buddy=

>>>>>>> pages.
>>>>>> Actually there's one extra thing I think we should do, and that is=
 make
>>>>>> sure we do not leave less than X% off the free memory at a time.
>>>>>> This way chances of triggering an OOM are lower.
>>>>> If nothing else we could probably look at doing a watermark of some=

>>>>> sort so we have to have X amount of memory free but not hinted befo=
re
>>>>> we will start providing the hints. It would just be a matter of
>>>>> tracking how much memory we have hinted on versus the amount of mem=
ory
>>>>> that has been pulled from that pool.
>>>> This is to avoid false OOM in the guest?
>>> Partially, though it would still be possible. Basically it would just=

>>> be a way of determining when we have hinted "enough". Basically it
>>> doesn't do us much good to be hinting on free memory if the guest is
>>> already constrained and just going to reallocate the memory shortly
>>> after we hinted on it. The idea is with a watermark we can avoid
>>> hinting until we start having pages that are actually going to stay
>>> free for a while.
>>>
>>>>>  It is another reason why we
>>>>> probably want a bit in the buddy pages somewhere to indicate if a p=
age
>>>>> has been hinted or not as we can then use that to determine if we h=
ave
>>>>> to account for it in the statistics.
>>>> The one benefit which I can see of having an explicit bit is that it=

>>>> will help us to have a single hook away from the hot path within bud=
dy
>>>> merging code (just like your arch_merge_page) and still avoid duplic=
ate
>>>> hints while releasing pages.
>>>>
>>>> I still have to check PG_idle and PG_young which you mentioned but I=

>>>> don't think we can reuse any existing bits.
>>> Those are bits that are already there for 64b. I think those exist in=

>>> the page extension for 32b systems. If I am not mistaken they are onl=
y
>>> used in VMA mapped memory. What I was getting at is that those are th=
e
>>> bits we could think about reusing.
>>>
>>>> If we really want to have something like a watermark, then can't we =
use
>>>> zone->free_pages before isolating to see how many free pages are the=
re
>>>> and put a threshold on it? (__isolate_free_page() does a similar thi=
ng
>>>> but it does that on per request basis).
>>> Right. That is only part of it though since that tells you how many
>>> free pages are there. But how many of those free pages are hinted?
>>> That is the part we would need to track separately and then then
>>> compare to free_pages to determine if we need to start hinting on mor=
e
>>> memory or not.
>> Only pages which are isolated will be hinted, and once a page is
>> isolated it will not be counted in the zone free pages.
>> Feel free to correct me if I am wrong.
> You are correct up to here. When we isolate the page it isn't counted
> against the free pages. However after we complete the hint we end up
> taking it out of isolation and returning it to the "free" state, so it
> will be counted against the free pages.
>
>> If I am understanding it correctly you only want to hint the idle page=
s,
>> is that right?
> Getting back to the ideas from our earlier discussion, we had 3 stages
> for things. Free but not hinted, isolated due to hinting, and free and
> hinted. So what we would need to do is identify the size of the first
> pool that is free and not hinted by knowing the total number of free
> pages, and then subtract the size of the pages that are hinted and
> still free.
To summarize, for now, I think it makes sense to stick with the current
approach as this way we can avoid any locking in the allocation path and
reduce the number of hypercalls for a bunch of MAX_ORDER - 1 page.
For the next step other than the comments received in the code and what
I mentioned in the cover email, I would like to do the following:
1. Explore the watermark idea suggested by Alex and bring down memhog
execution time if possible.
2. Benchmark hinting v/s non-hinting more extensively.
Let me know if you have any specific suggestions in terms of the tools I
can run to do the same. (I am planning to run atleast netperf, hackbench
and stress for this).

>
>>>>>>> With that we could track the age of the page so it becomes
>>>>>>> easier to only target pages that are truly going cold rather than=

>>>>>>> trying to grab pages that were added to the freelist recently.
>>>>>> I like that but I have a vague memory of discussing this with Rik =
van
>>>>>> Riel and him saying it's actually better to take away recently use=
d
>>>>>> ones. Can't see why would that be but maybe I remember wrong. Rik =
- am I
>>>>>> just confused?
>>>>> It is probably to cut down on the need for disk writes in the case =
of
>>>>> swap. If that is the case it ends up being a trade off.
>>>>>
>>>>> The sooner we hint the less likely it is that we will need to write=
 a
>>>>> given page to disk. However the sooner we hint, the more likely it =
is
>>>>> we will need to trigger a page fault and pull back in a zero page t=
o
>>>>> populate the last page we were working on. The sweet spot will be t=
hat
>>>>> period of time that is somewhere in between so we don't trigger
>>>>> unnecessary page faults and we don't need to perform additional swa=
p
>>>>> reads/writes.
>>>> --
>>>> Regards
>>>> Nitesh
>>>>
>> --
>> Regards
>> Nitesh
>>
--=20
Regards
Nitesh


--Q2ysSGlqobWbBDV2hKjOD9Aas8wcksB0W--

--OxKmVXZle8XZPHQokqhweRMEdqZsPL0jS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyIDIgACgkQo4ZA3AYy
ozl16w/+MPhJBHsfQs21XCb5Af8Ndn4Co95IeNoLaEbrqQlD+MovTAQhDLvOOltv
eym/pc5iyzw1Uhma1LVjzVpRFH5Y9t+6VWRG0/hPNtNKNifzLC8jGAaxDVXZoJBW
b47h1nFMImOaiE2OdFPyEPAxIAGMD4TGmHOUzZOAmD2181Q0lbjdleczK6anBhap
cLpyUwZ9OlCAQlcJh6dQrZCHa/JG9ux6LP3mGMQMV3kndvw/OkWuB1MCN2T32NTS
WmIdDBW3slioJX+YlIAlpaCVaZnIQRVR/b0gqboX8xAEIhMakh42DUZ8wDfRpHjC
Y9pFLo8nTSUQ6oNTkHDlrfpmKOnUp8Qet8WhSGkyZLQdGA1NpLzngi8FPzlsq6ue
kbUP1EkRP9UB0bCt47kat/C4ZSfgvR94Nh4aE0oU71iCcPM/lcHSI8F67nqKtphP
/26tZoawnVIHPggNCY/kj2q/t5EIrqUdgY3wg0xoQnHigj75d3NM7sNq3vPcAexN
DikwWwpaivcEt5Ff8CxsK41vqPRJ+X4XFizViYlUSjc0hQxMTLeqAkK68HtJ8b03
gOW6wshrcobFN2I/f7YIKGW5aJVEu6EGhxyyLVZo1KW46PGHPWSIrk9eVfpRvAb0
wREMTYRi/4u3/vT9CScZIh0I8aH/mI/pPX4iQHUpUbS29FfyvAI=
=c52/
-----END PGP SIGNATURE-----

--OxKmVXZle8XZPHQokqhweRMEdqZsPL0jS--

