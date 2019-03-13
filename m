Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABE15C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 13:08:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E4492177E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 13:08:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E4492177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C41C8E0003; Wed, 13 Mar 2019 09:08:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 873FD8E0001; Wed, 13 Mar 2019 09:08:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73C4E8E0003; Wed, 13 Mar 2019 09:08:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE838E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:08:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id e25so1449609qkj.12
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 06:08:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=QbHYGA22enxWxnRHpXTyoifqDvhN2jRDm+t7i68PVL0=;
        b=hOpVnXKyFvvJieMlq33qGuBAaCrEUStxtpgPd659kimPwytjaVGpgP3ACfTEUU/9Qc
         662w+jv7TrNr0O0tlwVTYVTqTW0b8mrpn8bS4koeKjgC91huma8g8d8IjbbiO0La5Oeb
         MFed3OOaOQelu/0NebFXQjrklE1hoRalpsRB0egFz3hB1AHZn2qrANxp7N5RbUzRwlH+
         sheqHhwZsy/auiQfkeb7NVA21gCn2T+ojydMsFZtkNkrxRlseq71aiatJHShyVvH+nck
         UmyG0RAiEz23CfC0hNhLuLVvmbZczAQ8l0ZogsqkqPkfHK7H7mUvdRyGTZsz1qWfZplf
         yP+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUGK7q39M7tluzqr14vBW9+p8kA22rWJkI8+gfwC/3ce2hBDE2P
	lGDswOLEEFWLuHhc8chf6fmcCDsnmZTqPNk26ak7A/X5QHMTwjUQd/35xojlVHa1CAMTXyqBjld
	GhIGIJRBlvjNrPh3BV21NIeaBgSuaL1u+8Pw+iu55xIkVNvCua1lgAFQ0MSAqsFmTOw==
X-Received: by 2002:ac8:1282:: with SMTP id y2mr14731734qti.179.1552482528038;
        Wed, 13 Mar 2019 06:08:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkeing0UAYF9+Cxhporuvr8gACeKpj1mMzcO8/5E8k0H5a7yvl6s7CWhm8vS2T4tIzkQTF
X-Received: by 2002:ac8:1282:: with SMTP id y2mr14731594qti.179.1552482526535;
        Wed, 13 Mar 2019 06:08:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552482526; cv=none;
        d=google.com; s=arc-20160816;
        b=uizM6I/t2KnQsgU4/lA3Df5aGAfy1gTrXWKD+XgbTm3pPEgmrbqxIViGhKMW++uxV3
         +tTqmkOBpLJ9lIo70e4P4SFNnPwp1j8AkBgqbSzKRo5yJDO6eKUf5uUOM00sc0e13B0z
         1qcNOkT8a3ZOF8suhDvjYn18q3GYcBZnehmaKZM/EVwQLVc0EJgM6pgAGfZF17u1kmj3
         xA6pjAjh2ZkjOpQ1D2g+KwSVZ1LXN+jRqkeDJBEm5d+N7VjPWlZsI6AXTCJ1TMjozOxx
         o3VKX37xAxGfen9WRdZvRN0JyiZtgzomQJAMrnTwDtHcBVhPxBbDZgvFSDYrax3WR1Et
         Lm7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=QbHYGA22enxWxnRHpXTyoifqDvhN2jRDm+t7i68PVL0=;
        b=l0hZ9GRM/lhGYL8ZLPwpDmRuhEcFNljkE5JnilE84k02FeOgn5f+tVVnB+MJehIRX2
         WW29wEtT9e9ydwiVaMB9M7SA1MhFNLH1pyFdnJm4tqa3xFQSOwCrDlPHGX4Zft+IA+QU
         u4KuawgKNTw9jRSmagX/gMZivIxDPWKZpp9BGKaUnqvG8VHqCOxamnA2hl2l7bPgX5MC
         Z9nDpDZLGsE8iHa6HkQ1bbzvg3W+6WlLE3cRuFIF3wIfJqghUlDO6JfACRKSplJiiBex
         3Mc4ndZpu/qpfKBPL0pdZbrQFbrNIdmJa48NQdnBb/5bj6uawgAqFdoh3SqbjO/hdpMr
         8jjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f124si3140586qkc.236.2019.03.13.06.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 06:08:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 93C6640F45;
	Wed, 13 Mar 2019 13:08:45 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 17D346B8D5;
	Wed, 13 Mar 2019 13:08:34 +0000 (UTC)
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
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
References: <20190306155048.12868-1-nitesh@redhat.com>
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
 <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com>
 <CAKgT0Uftff+JVRW-sQ6u8DeVg4Fq9b-pgE6Ojr+XqQFn13JmGw@mail.gmail.com>
 <1ae522f1-1e98-9eef-324c-29585fe574d6@redhat.com>
 <8826829a-973d-8117-3fe3-8e33170acfb8@redhat.com>
Organization: Red Hat Inc,
Message-ID: <01a7e65a-fd17-3bfa-8350-c44065761bd5@redhat.com>
Date: Wed, 13 Mar 2019 09:08:30 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <8826829a-973d-8117-3fe3-8e33170acfb8@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Ek4TzUhYxEXa0KQk26odtDuW1poCxLMMZ"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 13 Mar 2019 13:08:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Ek4TzUhYxEXa0KQk26odtDuW1poCxLMMZ
Content-Type: multipart/mixed; boundary="3Ig4s7Qeq3zXTtE58FZepklsBVvKXQ91F";
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
Message-ID: <01a7e65a-fd17-3bfa-8350-c44065761bd5@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages

--3Ig4s7Qeq3zXTtE58FZepklsBVvKXQ91F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/13/19 8:17 AM, David Hildenbrand wrote:
> On 13.03.19 12:54, Nitesh Narayan Lal wrote:
>> On 3/12/19 5:13 PM, Alexander Duyck wrote:
>>> On Tue, Mar 12, 2019 at 12:46 PM Nitesh Narayan Lal <nitesh@redhat.co=
m> wrote:
>>>> On 3/8/19 4:39 PM, Alexander Duyck wrote:
>>>>> On Fri, Mar 8, 2019 at 11:39 AM Nitesh Narayan Lal <nitesh@redhat.c=
om> wrote:
>>>>>> On 3/8/19 2:25 PM, Alexander Duyck wrote:
>>>>>>> On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat=
=2Ecom> wrote:
>>>>>>>> On 3/8/19 1:06 PM, Alexander Duyck wrote:
>>>>>>>>> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.c=
om> wrote:
>>>>>>>>>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrot=
e:
>>>>>>>>>>> The only other thing I still want to try and see if I can do =
is to add
>>>>>>>>>>> a jiffies value to the page private data in the case of the b=
uddy
>>>>>>>>>>> pages.
>>>>>>>>>> Actually there's one extra thing I think we should do, and tha=
t is make
>>>>>>>>>> sure we do not leave less than X% off the free memory at a tim=
e.
>>>>>>>>>> This way chances of triggering an OOM are lower.
>>>>>>>>> If nothing else we could probably look at doing a watermark of =
some
>>>>>>>>> sort so we have to have X amount of memory free but not hinted =
before
>>>>>>>>> we will start providing the hints. It would just be a matter of=

>>>>>>>>> tracking how much memory we have hinted on versus the amount of=
 memory
>>>>>>>>> that has been pulled from that pool.
>>>>>>>> This is to avoid false OOM in the guest?
>>>>>>> Partially, though it would still be possible. Basically it would =
just
>>>>>>> be a way of determining when we have hinted "enough". Basically i=
t
>>>>>>> doesn't do us much good to be hinting on free memory if the guest=
 is
>>>>>>> already constrained and just going to reallocate the memory short=
ly
>>>>>>> after we hinted on it. The idea is with a watermark we can avoid
>>>>>>> hinting until we start having pages that are actually going to st=
ay
>>>>>>> free for a while.
>>>>>>>
>>>>>>>>>  It is another reason why we
>>>>>>>>> probably want a bit in the buddy pages somewhere to indicate if=
 a page
>>>>>>>>> has been hinted or not as we can then use that to determine if =
we have
>>>>>>>>> to account for it in the statistics.
>>>>>>>> The one benefit which I can see of having an explicit bit is tha=
t it
>>>>>>>> will help us to have a single hook away from the hot path within=
 buddy
>>>>>>>> merging code (just like your arch_merge_page) and still avoid du=
plicate
>>>>>>>> hints while releasing pages.
>>>>>>>>
>>>>>>>> I still have to check PG_idle and PG_young which you mentioned b=
ut I
>>>>>>>> don't think we can reuse any existing bits.
>>>>>>> Those are bits that are already there for 64b. I think those exis=
t in
>>>>>>> the page extension for 32b systems. If I am not mistaken they are=
 only
>>>>>>> used in VMA mapped memory. What I was getting at is that those ar=
e the
>>>>>>> bits we could think about reusing.
>>>>>>>
>>>>>>>> If we really want to have something like a watermark, then can't=
 we use
>>>>>>>> zone->free_pages before isolating to see how many free pages are=
 there
>>>>>>>> and put a threshold on it? (__isolate_free_page() does a similar=
 thing
>>>>>>>> but it does that on per request basis).
>>>>>>> Right. That is only part of it though since that tells you how ma=
ny
>>>>>>> free pages are there. But how many of those free pages are hinted=
?
>>>>>>> That is the part we would need to track separately and then then
>>>>>>> compare to free_pages to determine if we need to start hinting on=
 more
>>>>>>> memory or not.
>>>>>> Only pages which are isolated will be hinted, and once a page is
>>>>>> isolated it will not be counted in the zone free pages.
>>>>>> Feel free to correct me if I am wrong.
>>>>> You are correct up to here. When we isolate the page it isn't count=
ed
>>>>> against the free pages. However after we complete the hint we end u=
p
>>>>> taking it out of isolation and returning it to the "free" state, so=
 it
>>>>> will be counted against the free pages.
>>>>>
>>>>>> If I am understanding it correctly you only want to hint the idle =
pages,
>>>>>> is that right?
>>>>> Getting back to the ideas from our earlier discussion, we had 3 sta=
ges
>>>>> for things. Free but not hinted, isolated due to hinting, and free =
and
>>>>> hinted. So what we would need to do is identify the size of the fir=
st
>>>>> pool that is free and not hinted by knowing the total number of fre=
e
>>>>> pages, and then subtract the size of the pages that are hinted and
>>>>> still free.
>>>> To summarize, for now, I think it makes sense to stick with the curr=
ent
>>>> approach as this way we can avoid any locking in the allocation path=
 and
>>>> reduce the number of hypercalls for a bunch of MAX_ORDER - 1 page.
>>> I'm not sure what you are talking about by "avoid any locking in the
>>> allocation path". Are you talking about the spin on idle bit, if so
>>> then yes.=20
>> Yeap!
>>> However I have been testing your patches and I was correct
>>> in the assumption that you forgot to handle the zone lock when you
>>> were freeing __free_one_page.
>> Yes, these are the steps other than the comments you provided in the
>> code. (One of them is to fix release_buddy_page())
>>>  I just did a quick copy/paste from your
>>> zone lock handling from the guest_free_page_hinting function into the=

>>> release_buddy_pages function and then I was able to enable multiple
>>> CPUs without any issues.
>>>
>>>> For the next step other than the comments received in the code and w=
hat
>>>> I mentioned in the cover email, I would like to do the following:
>>>> 1. Explore the watermark idea suggested by Alex and bring down memho=
g
>>>> execution time if possible.
>>> So there are a few things that are hurting us on the memhog test:
>>> 1. The current QEMU patch is only madvising 4K pages at a time, this
>>> is disabling THP and hurts the test.
>> Makes sense, thanks for pointing this out.
>>> 2. The fact that we madvise the pages away makes it so that we have t=
o
>>> fault the page back in in order to use it for the memhog test. In
>>> order to avoid that penalty we may want to see if we can introduce
>>> some sort of "timeout" on the pages so that we are only hinting away
>>> old pages that have not been used for some period of time.
>> Possibly using MADVISE_FREE should also help in this, I will try this =
as
>> well.
> I was asking myself some time ago how MADVISE_FREE will be handled in
> case of THP. Please let me know your findings :)
I will do that.
If we don't end up finding any appropriate page flag to track the age of
free page. I am wondering if I can somehow use bitmap to track the free
count for each PFN.
>
--=20
Regards
Nitesh


--3Ig4s7Qeq3zXTtE58FZepklsBVvKXQ91F--

--Ek4TzUhYxEXa0KQk26odtDuW1poCxLMMZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyJAM8ACgkQo4ZA3AYy
oznKeg//TzdsmVxg5nia+SpRaUxiEGYJEJkeHKnVLqz+oRShWZQkEFBYumUh2mBH
SP+bsvOVtptdVOyg9KLh6KQl7vmXkmXrkK/xv78zzFGgmgNnQdTbZN5KAwCDbQJK
fuj0kzsJTwI2mdktQsQhJ2CLjNJ//HLYbVHDxO18Ysggf55ubnpJkzyXYjyykW6K
JQPrpO8++tMwrS6SN8xG8yK9jafVfoppSM9PaoBLrtlZpdGa/QoAwVkjEA0FlGHs
WmipLp5B3vKdJoM7/4C5iY0OQ3oZrzKdXxkjdulNVK2j6QgzDs2GV7g6Q/N3euIe
WG3Tuvx0uOPmU9EQNk5iIKswlh3GBM5lImxrAQdXw2I4OfIwUsiSdej30cmEy/iI
zWcvz+RnXy3tBYpjX02rxZECz/ITlA6MSs2u4UkOcXSJo6O0y+3AJXY+vIwiNfIv
69485p2J1pXUBr8+p+sI/LAdTpBtVL+NUmTPyF70dezPKU/gFlawydYFV/yLICj5
7tDp2CW/Xg3a/ro8mjVwt6gZDp6MeA4XDKK2uAFkKIT16mWvB53EqsrlusUOfAgE
6nyHIZiu31sqmoW+LmOvLCcuDyJyptv1oHySAX4xDn99ifTQl8QQm4B4Sd0fV6Gf
DlveoktVR/uffbHVPxdUEmgQR9KsR7kKDu0lRQd3rekYONy1QQg=
=ULLn
-----END PGP SIGNATURE-----

--Ek4TzUhYxEXa0KQk26odtDuW1poCxLMMZ--

