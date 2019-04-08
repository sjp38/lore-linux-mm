Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44200C10F14
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 12:24:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAE0B21473
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 12:24:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAE0B21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B3866B0003; Mon,  8 Apr 2019 08:24:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 239F16B0005; Mon,  8 Apr 2019 08:24:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B37B6B0006; Mon,  8 Apr 2019 08:24:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D5FC96B0003
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 08:24:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c67so11458484qkg.5
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 05:24:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=GQgASu60MkLmXGsb2I4ZL3OGFp2X4s3FczXxfjBFql4=;
        b=qTt93HIv6DjGvi6NZ89cP1XocY3VS1D3oOoOMwsIgSSvssAq03CioOT4zjgx1npLhh
         dDv3WkC4JUJ2ZkKkv76vLunCDWMKcvGrepxGkgBj6l/iPVFqVGYthYXrZmMRCd1HExCV
         sY+888FuRsHGdMQ0TQWAQzouzQ0L8oA3A8FNGz6PiOY8vCl1F9rjdeuJZ5liVdw9DqkS
         XdNi/gGYGm55a9wiaybOmuXQGrrcsbCX6xJs0QIbI2g81GHmu+gaDPTVCs8Y2usOIDHG
         +Z0/+pWhUY1BaW+/cfJYTAmtNKcExaTLpgo062JIXOGZ3WncpzCRCUFcQWjdeXK5S6oe
         91DQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX/BE+DfOWCPOOsNw241ZMSegwpYkEZhmudxrkhmvGHiOTws0uR
	Jgb2eE4clz/95q1e+00JiVKGvF8fnGHI5eg2Ik2WcXTkrCn/yAswCOsbSXAbVnOTnX7juJEgkKK
	DDQIqJxNnuEJ4r5JDHdAnHpIT3ET21Fg/keqIWw+9ch5kWopPEspZ+nR8mP9FfPtOVg==
X-Received: by 2002:a37:a5d8:: with SMTP id o207mr22668872qke.0.1554726296559;
        Mon, 08 Apr 2019 05:24:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfikAVcdz8u47lrCqskBP2YsDqR1rDmDoDuqtlmGMCEkiqHlVoat4/HVNhlbnSzFXiKY5t
X-Received: by 2002:a37:a5d8:: with SMTP id o207mr22668804qke.0.1554726295647;
        Mon, 08 Apr 2019 05:24:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554726295; cv=none;
        d=google.com; s=arc-20160816;
        b=smYyHKdVrmJeGPs0FUafFFMdoVKyTzU9d92xR1NSi4H+bPBWZdSz9uCbePF6yo44Bo
         nf2JU0rAM1dtjq+n6M6S2sHwp5fz2DXjx4Gq58LG73pbGZi+O5Wz+1srseHnUA5R136m
         oQ8U7X97YSI9Nru23DsxZEyek529szd98PDaRLSPO8RDvTT7ORLwb0m+ecdv694+hTFW
         9z83TrICakaubfSjr0Zj+IBYf/fb4YUXR2vUNk3ahN8P4z5H4Kj8/VVnLvc6AeO2ZfGq
         m4cdvNb024mMgklQZolBfgceA/CcEDAbzwmSJynEJqvOjKRCD4Ps5pIg7c5G2KMOdwL2
         QSxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=GQgASu60MkLmXGsb2I4ZL3OGFp2X4s3FczXxfjBFql4=;
        b=pmxZL35auWLMy5U5Qz3OSULCMZNpYgYdFJWRqKPNb0KbM++Dgm4ivjNawcHWzYryeU
         KG99kAbyH8LReEzOWK4WouuiSBdiFRmVDfASakV8pCXpF40EXnl6v+kw7wV5rePoYh08
         FcRCHNw/BWpJeLlkZDFZFuat22tskLyGQU/D3XgNLMUiqNHBKuQc4AZaiyRVEOFn1D+k
         tctnHmPHZ9UXx/bZu1bF/4IIfsrmq5fSfzuIxrec9AXtE+J5sLVUL6L9A+e0OxyBmV5q
         e1zyZ6FCBloFU4nkNShqB29s+5wNwDnGJyL9j46fyo3iPEIPPEjfqtmYSG/IwENeAXNY
         ssoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w2si9235086qvc.80.2019.04.08.05.24.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 05:24:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7BDE0883CA;
	Mon,  8 Apr 2019 12:24:54 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5804B665C4;
	Mon,  8 Apr 2019 12:24:45 +0000 (UTC)
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <ef0c542a-ded5-f063-e6e2-8e84d1c12c85@redhat.com>
Date: Mon, 8 Apr 2019 08:24:43 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="njUWTaoJWBqh1lxfc3zrAPUOXJa2c60xB"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 08 Apr 2019 12:24:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--njUWTaoJWBqh1lxfc3zrAPUOXJa2c60xB
Content-Type: multipart/mixed; boundary="pt3BIrnFE3FYH1MLYjSIxqGd4MxszPRyq";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <ef0c542a-ded5-f063-e6e2-8e84d1c12c85@redhat.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
In-Reply-To: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>

--pt3BIrnFE3FYH1MLYjSIxqGd4MxszPRyq
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 4/5/19 8:09 PM, Alexander Duyck wrote:
> So I am starting this thread as a spot to collect my thoughts on the
> current guest free page hinting design as well as point out a few
> possible things we could do to improve upon it.
>
> 1. The current design isn't likely going to scale well to multiple
> VCPUs. The issue specifically is that the zone lock must be held to
> pull pages off of the free list and to place them back there once they
> have been hinted upon. As a result it would likely make sense to try
> to limit ourselves to only having one thread performing the actual
> hinting so that we can avoid running into issues with lock contention
> between threads.
>
> 2. There are currently concerns about the hinting triggering false OOM
> situations if too much memory is isolated while it is being hinted. My
> thought on this is to simply avoid the issue by only hint on a limited
> amount of memory at a time. Something like 64MB should be a workable
> limit without introducing much in the way of regressions. However as a
> result of this we can easily be overrun while waiting on the host to
> process the hinting request. As such we will probably need a way to
> walk the free list and free pages after they have been freed instead
> of trying to do it as they are freed.
>
> 3. Even with the current buffering which is still on the larger side
> it is possible to overrun the hinting limits if something causes the
> host to stall and a large swath of memory is released. As such we are
> still going to need some sort of scanning mechanism or will have to
> live with not providing accurate hints.
>
> 4. In my opinion, the code overall is likely more complex then it
> needs to be. We currently have 2 allocations that have to occur every
> time we provide a hint all the way to the host, ideally we should not
> need to allocate more memory to provide hints. We should be able to
> hold the memory use for a memory hint device constant and simply map
> the page address and size to the descriptors of the virtio-ring.
>
> With that said I have a few ideas that may help to address the 4
> issues called out above. The basic idea is simple. We use a high water
> mark based on zone->free_area[order].nr_free to determine when to wake
> up a thread to start hinting memory out of a given free area. From
> there we allocate non-"Offline" pages from the free area and assign
> them to the hinting queue up to 64MB at a time. Once the hinting is
> completed we mark them "Offline" and add them to the tail of the
> free_area. Doing this we should cycle the non-"Offline" pages slowly
> out of the free_area.=20
any ideas about how are you planning to control this?
> In addition the search cost should be minimal
> since all of the "Offline" pages should be aggregated to the tail of
> the free_area so all pages allocated off of the free_area will be the
> non-"Offline" pages until we shift over to them all being "Offline".
> This should be effective for MAX_ORDER - 1 and MAX_ORDER - 2 pages
> since the only real consumer of add_to_free_area_tail is
> __free_one_page which uses it to place a page with an order less than
> MAX_ORDER - 2 on the tail of a free_area assuming that it should be
> freeing the buddy of that page shortly. The only other issue with
> adding to tail would be the memory shuffling which was recently added,
> but I don't see that as being something that will be enabled in most
> cases so we could probably just make the features mutually exclusive,
> at least for now.
>
> So if I am not mistaken this would essentially require a couple
> changes to the mm infrastructure in order for this to work.
>
> First we would need to split nr_free into two counters, something like
> nr_freed and nr_bound. You could use nr_freed - nr_bound to get the
> value currently used for nr_free. When we pulled the pages for hinting
> we would reduce the nr_freed value and then add back to it when the
> pages are returned. When pages are allocated they would increment the
> nr_bound value. The idea behind this is that we can record nr_free
> when we collect the pages and save it to some local value. This value
> could then tell us how many new pages have been added that have not
> been hinted upon.
>
> In addition we will need some way to identify which pages have been
> hinted on and which have not. The way I believe easiest to do this
> would be to overload the PageType value so that we could essentially
> have two values for "Buddy" pages. We would have our standard "Buddy"
> pages, and "Buddy" pages that also have the "Offline" value set in the
> PageType field. Tracking the Online vs Offline pages this way would
> actually allow us to do this with almost no overhead as the mapcount
> value is already being reset to clear the "Buddy" flag so adding a
> "Offline" flag to this clearing should come at no additional cost.
>
> Lastly we would need to create a specialized function for allocating
> the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
> "Offline" pages. I'm thinking the alloc function it would look
> something like __rmqueue_smallest but without the "expand" and needing
> to modify the !page check to also include a check to verify the page
> is not "Offline". As far as the changes to __free_one_page it would be
> a 2 line change to test for the PageType being offline, and if it is
> to call add_to_free_area_tail instead of add_to_free_area.
Is it possible that once the pages are offline, there is a large
allocation request in the guest needing those offline pages as well?
>
> Anyway this email ended up being pretty massive by the time I was
> done. Feel free to reply to parts of it and we can break it out into
> separate threads of discussion as necessary. I will start working on
> coding some parts of this next week.
>
> Thanks.
>
> - Alex
--=20
Regards
Nitesh


--pt3BIrnFE3FYH1MLYjSIxqGd4MxszPRyq--

--njUWTaoJWBqh1lxfc3zrAPUOXJa2c60xB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyrPYwACgkQo4ZA3AYy
oznpSA//axsfJiWt0W5AbdGPm5Veo7CmnDLt6jlDH0lM7uji3BnfL9mxcHruoLIC
62iRfMZ+ank2gZzyGyhhy7gYfIeQtbzBkYJAsUBV7NBu5WTwI03C3e4ipWZd3d1G
1W/vSU4kavSfIMcxjdDwD0uaJhJhvybz6cPs/Mmwe+UmgYKBloP4jntx9Wadmx+J
CMTwuDl8RViz/VobReQiIg5PdgebFqDojcPSQVV8jLxj0PP9F4YznN2x9zzQg9Yq
eHgaXqii6EW7DN5M/hxPXBwXtO636LtJrXWSZTDsF/qnLX+tc8PzRv+pNTYyo1WV
4vbg/wzknckDQhWsEz2jeqNRr3x+/e7L/YQGP+JCeVihDZnms6uut/T7c7mAvuCq
kFPSJEx5xnYs2yxwJCKU3enqe8j6rZ+zYToHRNFwnbo6I1Q24LTVi/XIklyp9Rug
Z7twHWJ35R3WwAbDA9YEROHSjG4qKor4MKMxrWzQdK5bFD1tJ0eLqBCK9lczQZBb
DjBRyXWQ+S3c1Qs8sWhgDAM1q2wyyQYjpUzg7OgLvmAn7U4y/pxZb5M3kxFfx7Js
AP+/mKQRoALp/+D1ZPElH6LQ2IOxcoM6Y/6aHcMVYNRNQJHBTIjtTplqLA1sbaxV
sc7bDt1Gs7ivLwV3wNE3Lw3dtg40cVjTkYKSNy9KsMD6kERADnk=
=2pVJ
-----END PGP SIGNATURE-----

--njUWTaoJWBqh1lxfc3zrAPUOXJa2c60xB--

