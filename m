Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB6E4C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:10:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E9D72084C
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:10:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E9D72084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 530286B026B; Mon,  8 Apr 2019 14:10:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DFE86B026C; Mon,  8 Apr 2019 14:10:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CFF46B026D; Mon,  8 Apr 2019 14:10:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15E586B026B
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 14:10:28 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id a188so12421631qkf.0
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 11:10:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=n0lVXDNrTjZ5rpCjuHlgnei0yoPhAKhDWCBuBoBt0iM=;
        b=hPAmZ7eDdQQgbK1DLNJRs+UtfpdJNSYKAUJPv5zbIMphpjoWRDIwoOqvU3DdqODVvm
         qCSCQDgq5bXiUmI664i2jOtJH5pOPY3lo10SlH6bKUnXcnhFLWpEEn9uImL0r+7itzsS
         ph/VGHDame9BUbaq8TTyg3T8k0RgMOif4s0DPGN1FqcAu0+i+viBxQhIVruwGoQBoohx
         z5TCN0QvQXj3RuZVdNG/ohlQnSc3304+c5r2yBe8yL4CqwIM9ypz0i5Y7Li85pBPLR4w
         mb9JPoykmfKj9vV42IyiCR+Pkq1qZ0SEm8Do/cZU/JP4JVVRAVgagMfYH4rP2mo/JySz
         pKDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVmWtUzEFBsfg6SEsskygGid3yy0c8F3stZYLMRu0viJQkuaSn3
	zAZSUUHiK8/pcPU9+dK4Qcr8Sw+uDCbRndN4G5kGPfKL3hlaWfd8w9NdH17QZJj9GB0RF4bpKjs
	vm5RFtH03GlCzwSrpDwOw8IkFqbfIBStsIwkg8K4NDZ177Gy+2z7WZ1LTwc5GCJ/CRw==
X-Received: by 2002:ac8:cf:: with SMTP id d15mr25549849qtg.243.1554747027792;
        Mon, 08 Apr 2019 11:10:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnWM8EQc6jvIX5VLVc/wguW5bUkxdeOeAnWQ8jpxVroW7TCW/2M8uvevgOZnQ7XhbksZ/K
X-Received: by 2002:ac8:cf:: with SMTP id d15mr25549745qtg.243.1554747026710;
        Mon, 08 Apr 2019 11:10:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554747026; cv=none;
        d=google.com; s=arc-20160816;
        b=RWv0vcgHx1pegBr9PpJIzQrRt7CWRvBIPCYrAMW/+taRk5l/zNk2BKTOPpu3rfdbwl
         Y2T40XARC9U61jniP+Aysyi+Rc+V3ivfoFP4wPzgR+UtSIrAca2UJC4n2JWoUSnyNP6+
         Z4aZuR4MefFIHxYR6T56cKlsDJBwfqYtDjue0f5rJE3mzpyT4qBwsp/amhYflEUjD7tP
         8SxdqphoVjqbATh9TpIggEiiiicnW6JQOUXXNJehlR4fSfNL+IGpqXiwoBCKvRYYymbP
         jgGKPw3ql1yn1Ikn2xaE/IbUQj+U7QOZp2KykF43LRGz7jNyT4zREZq7/AVl/M3wdYyL
         Dx2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=n0lVXDNrTjZ5rpCjuHlgnei0yoPhAKhDWCBuBoBt0iM=;
        b=jKfWUtj4P8zx1jmY289DdG8XIzK4STD/aEMr/F5izcgPd5LINfJZnh2wJQ3POGH9vs
         IgrPBDuCKqJkQkpDqvNsBLO8dQpa5QSHkp7Zoa4TPpdvFqd0ByohWyZRaB8yLOZhsQTJ
         1p8VaBddqrnHML9pnGy/UR3i8wm0aNtBqFRdj7Lq4diRZf2+i2S3yz2IS7sw7MsHfZsi
         XwBFBDrcjPcU961Tlj7SRkSZGH4QlSSc5CcjOgniOfrFmE6eaeQ/0sCH6WUXpvJJHumN
         OP+nazE6r9CNttnQVQQK//TCzoFgUr91gFRVM+tS6kihvz6yAm0yc7ehZJCdwiwASk2M
         wXCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e15si5826436qvs.19.2019.04.08.11.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 11:10:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3815C308213A;
	Mon,  8 Apr 2019 18:10:18 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1770510840F6;
	Mon,  8 Apr 2019 18:10:00 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com>
Organization: Red Hat Inc,
Message-ID: <6f097f31-abc7-f56c-199c-dc167331f6b9@redhat.com>
Date: Mon, 8 Apr 2019 14:09:59 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="mdbx8CNhwKb8an8U4XHwDkrH1z8tLY3OM"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 08 Apr 2019 18:10:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mdbx8CNhwKb8an8U4XHwDkrH1z8tLY3OM
Content-Type: multipart/mixed; boundary="5fZC5GMXaj0k5NirwiN5RdVTqRMeAlFbe";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Message-ID: <6f097f31-abc7-f56c-199c-dc167331f6b9@redhat.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting

--5fZC5GMXaj0k5NirwiN5RdVTqRMeAlFbe
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 4/8/19 12:36 PM, David Hildenbrand wrote:
> On 06.04.19 02:09, Alexander Duyck wrote:
>> So I am starting this thread as a spot to collect my thoughts on the
>> current guest free page hinting design as well as point out a few
>> possible things we could do to improve upon it.
>>
>> 1. The current design isn't likely going to scale well to multiple
>> VCPUs. The issue specifically is that the zone lock must be held to
>> pull pages off of the free list and to place them back there once they=

>> have been hinted upon. As a result it would likely make sense to try
>> to limit ourselves to only having one thread performing the actual
>> hinting so that we can avoid running into issues with lock contention
>> between threads.
> Makes sense.
>
>> 2. There are currently concerns about the hinting triggering false OOM=

>> situations if too much memory is isolated while it is being hinted. My=

>> thought on this is to simply avoid the issue by only hint on a limited=

>> amount of memory at a time. Something like 64MB should be a workable
>> limit without introducing much in the way of regressions. However as a=

>> result of this we can easily be overrun while waiting on the host to
>> process the hinting request. As such we will probably need a way to
>> walk the free list and free pages after they have been freed instead
>> of trying to do it as they are freed.
> We will need such a way in case we care about dropped hinting requests,=
 yes.
>
>> 3. Even with the current buffering which is still on the larger side
>> it is possible to overrun the hinting limits if something causes the
>> host to stall and a large swath of memory is released. As such we are
>> still going to need some sort of scanning mechanism or will have to
>> live with not providing accurate hints.
> Yes, usually if there is a lot of guest activity, you could however
> assume that free pages might get reused either way soon. Of course,
> special cases are "freeing XGB and being idle afterwards".
>
>> 4. In my opinion, the code overall is likely more complex then it
>> needs to be. We currently have 2 allocations that have to occur every
>> time we provide a hint all the way to the host, ideally we should not
>> need to allocate more memory to provide hints. We should be able to
>> hold the memory use for a memory hint device constant and simply map
>> the page address and size to the descriptors of the virtio-ring.
> I don't think the two allocations are that complex. The only thing I
> consider complex is isolation a lot of pages from different zones etc.
> Two allocations, nobody really cares about that. Of course, the fact
> that we have to allocate memory from the VCPUs where we currently freed=

> a page is not optimal. I consider that rather a problem/complex.
>
> Especially you have a point regarding scalability and multiple VCPUs.
>
>> With that said I have a few ideas that may help to address the 4
>> issues called out above. The basic idea is simple. We use a high water=

>> mark based on zone->free_area[order].nr_free to determine when to wake=

>> up a thread to start hinting memory out of a given free area. From
>> there we allocate non-"Offline" pages from the free area and assign
>> them to the hinting queue up to 64MB at a time. Once the hinting is
>> completed we mark them "Offline" and add them to the tail of the
>> free_area. Doing this we should cycle the non-"Offline" pages slowly
>> out of the free_area. In addition the search cost should be minimal
>> since all of the "Offline" pages should be aggregated to the tail of
>> the free_area so all pages allocated off of the free_area will be the
>> non-"Offline" pages until we shift over to them all being "Offline".
>> This should be effective for MAX_ORDER - 1 and MAX_ORDER - 2 pages
>> since the only real consumer of add_to_free_area_tail is
>> __free_one_page which uses it to place a page with an order less than
>> MAX_ORDER - 2 on the tail of a free_area assuming that it should be
>> freeing the buddy of that page shortly. The only other issue with
>> adding to tail would be the memory shuffling which was recently added,=

>> but I don't see that as being something that will be enabled in most
>> cases so we could probably just make the features mutually exclusive,
>> at least for now.
>>
>> So if I am not mistaken this would essentially require a couple
>> changes to the mm infrastructure in order for this to work.
>>
>> First we would need to split nr_free into two counters, something like=

>> nr_freed and nr_bound. You could use nr_freed - nr_bound to get the
>> value currently used for nr_free. When we pulled the pages for hinting=

>> we would reduce the nr_freed value and then add back to it when the
>> pages are returned. When pages are allocated they would increment the
>> nr_bound value. The idea behind this is that we can record nr_free
>> when we collect the pages and save it to some local value. This value
>> could then tell us how many new pages have been added that have not
>> been hinted upon.
> I can imagine that quite some people will have problems with such
> "virtualization specific changes" splattered around core memory
> management. Would there be a way to manage this data at a different
> place, out of core-mm and somehow work on it via callbacks?
>
>> In addition we will need some way to identify which pages have been
>> hinted on and which have not. The way I believe easiest to do this
>> would be to overload the PageType value so that we could essentially
>> have two values for "Buddy" pages. We would have our standard "Buddy"
>> pages, and "Buddy" pages that also have the "Offline" value set in the=

>> PageType field. Tracking the Online vs Offline pages this way would
>> actually allow us to do this with almost no overhead as the mapcount
>> value is already being reset to clear the "Buddy" flag so adding a
>> "Offline" flag to this clearing should come at no additional cost.
> Just nothing here that this will require modifications to kdump
> (makedumpfile to be precise and the vmcore information exposed from the=

> kernel), as kdump only checks for the the actual mapcount value to
> detect buddy and offline pages (to exclude them from dumps), they are
> not treated as flags.
>
> For now, any mapcount values are really only separate values, meaning
> not the separate bits are of interest, like flags would be. Reusing
> other flags would make our life a lot easier. E.g. PG_young or so. But
> clearing of these is then the problematic part.
>
> Of course we could use in the kernel two values, Buddy and BuddyOffline=
=2E
> But then we have to check for two different values whenever we want to
> identify a buddy page in the kernel.
>
>> Lastly we would need to create a specialized function for allocating
>> the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
>> "Offline" pages. I'm thinking the alloc function it would look
>> something like __rmqueue_smallest but without the "expand" and needing=

>> to modify the !page check to also include a check to verify the page
>> is not "Offline". As far as the changes to __free_one_page it would be=

>> a 2 line change to test for the PageType being offline, and if it is
>> to call add_to_free_area_tail instead of add_to_free_area.
> As already mentioned, there might be scenarios where the additional
> hinting thread might consume too much CPU cycles, especially if there i=
s
> little guest activity any you mostly spend time scanning a handful of
> free pages and reporting them. I wonder if we can somehow limit the
> amount of wakeups/scans for a given period to mitigate this issue.
>
> One main issue I see with your approach is that we need quite a lot of
> core memory management changes. This is a problem. I wonder if we can
> factor out most parts into callbacks.
>
> E.g. in order to detect where to queue a certain page (front/tail), cal=
l
> a callback if one is registered, mark/check pages in a core-mm unknown
> way as offline etc.
>
> I still wonder if there could be an easier way to combine recording of
> hints and one hinting thread, essentially avoiding scanning and some of=

> the required core-mm changes.
In order to resolve the scalability issues associated with my
patch-series without compromising with free memory hints, I may explore
the idea described below:
- Use xbitmap (if possible - earlier suggested by Rik and Wei)
corresponding to each zone on a granularity of MAX_ORDER - 2, to track
the freed PFN's.
- Define and use counters corresponding to each zone to monitor the
amount of memory freed.
- As soon as the 64MB free memory threshold is hit wake up the kernel
thread which will scan this xbitmap and try to isolate the pages and
clear the corresponding bits. (We still have to acquire zone lock to
protect the respective xbitmap)
- Report the isolated pages back to the host in a synchronous manner.
I still have to work on several details of this idea including xbitmap,
but first would like to hear any suggestions/thoughts.
>
--=20
Regards
Nitesh


--5fZC5GMXaj0k5NirwiN5RdVTqRMeAlFbe--

--mdbx8CNhwKb8an8U4XHwDkrH1z8tLY3OM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyrjncACgkQo4ZA3AYy
ozm5UA/+NUc8mik8by3AmBCIpzqQaCvpKhtWYGgq8hQZdFnOsOMJY1VUo40rbkdy
ewGT8/0MbWu3BXmO0EOh8y8QlLw/Q3gtQgf0GTeNh3MBZ+CO+dZQ2YgLw9N59Jq9
MiSEbvtM3drQpYUwhuZ1lMiTHt3YiCLcM1rn4C18hPCteS6nrwsua33jglZVpmUO
Ms2y1/fKsEf8JZUX87I49mguam2He+/asXYbxNJojf/PAysEpuQ7ri7pW0Et98Wp
akSYngefyFBcPUXcq4jaNh2R+MrTC///y4Dikhsg9pK/2mLlGoHaauTPPLMouiYA
svDxcpdD9JPxAyCUjLBXY4L6JN5g8Isb/VTXs9gf88hGAzMrNpgNAljffQxjuZGV
/vd1Cfs1KWlzHj0HsxcG0TSAcB8RCq8jCgUfmtCmfduMnIavCaDgS+JxDSmDCzcx
0xvJzAgf9mR5ntLjp+DxvQAY3hTig0tOl6EIbTs/qrzw30v/ekQsO/SKgoSiUA5v
sq3I2HL/5nX+52BN2g/l0mOkqsXFR4ahG6v2TEGqrBA+/BCtyPHzGpQfZTrwP4Vm
FKNctoJjDZFT+ODmPo7pppfTVuDL1d5pZ+au/KjxnukNpZmJ8rMZMadJP/Dh8X1Q
ZPeguhED4fo2T5JfDXgwiL/MjIbq4zpFzG6M1s0Pyk/NdAVdGok=
=dq43
-----END PGP SIGNATURE-----

--mdbx8CNhwKb8an8U4XHwDkrH1z8tLY3OM--

