Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE461C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 03:27:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BEEF2073F
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 03:27:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="j0O+6fuT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BEEF2073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 175C28E0058; Wed,  2 Jan 2019 22:27:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FD878E0002; Wed,  2 Jan 2019 22:27:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB7228E0058; Wed,  2 Jan 2019 22:27:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id B88CA8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 22:27:20 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id v6so9009333ybm.11
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 19:27:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=eqE4Z26zsNcQAJgC7bD2Jo1r09N+BCQVCnR1yuSDr4M=;
        b=Fb4xuxSrwWeN21k/bV0uWKj7yTnKPTjSPsnMmgiw6HHWVGW6JOH2S1YaHULjmse4kO
         xEMSczhhpDeq8g7jPF23fGHWogM5ummXVlUgPMkX1KdjaaNLKaTf+p0WwbaWxSC2URIT
         1xOIWVKeOugMOVwO0ozfHi1qTBhLCTf8r9azMI442F3RLPPB5uhck2yboDoauqxBb0M8
         4emKeSJTnGVmYd6WXENA74F2c7xXx5UVWe/vdDfHlFl67pY8kW2eaNYruFGd7LcT1pde
         RWIUpAswCyVXRoRtChJH+bGyLGqfNYtHlobOKZz7O2u1WfHWj1QOKHOf9FKcpBs8yibv
         wtPw==
X-Gm-Message-State: AJcUukcHE2qGUECc2PEWWb2YVKot3RrRSGcOuHQs2dG+bYtqFXMjeSqp
	Y9M6bZ6NNasvQamWTdnHhZlzFA2LWGF98vS6wqOjyDxs98ZggS0KgfGvzlkLny4vVmfXLgswdGd
	UFdTvlbpkCQ7DS8xyqxNhtQNXiHcYI4QfRa90Z9SudnctQAgM7YgIiMQWF99q99CifQ==
X-Received: by 2002:a25:7797:: with SMTP id s145mr43382370ybc.477.1546486040460;
        Wed, 02 Jan 2019 19:27:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7cczJFgTYhk5vvdE+3gjF9gVUr4ddcelJozER74HR/8Z61EC3vXmp4S7HpDadhp2HVetX0
X-Received: by 2002:a25:7797:: with SMTP id s145mr43382337ybc.477.1546486039497;
        Wed, 02 Jan 2019 19:27:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546486039; cv=none;
        d=google.com; s=arc-20160816;
        b=KTcYT2iEpDpcvxrCQHlklPolIkpIaw/sW1M0u/9DydRhWum8pTS1lwvTlGUdk87PZs
         G9wQazgPlCwoxkEhqmS2H1xS4wmci70/kfcBLW384gZI95pUVhWi4Dl2FiKMNcMrkU2S
         5vieQYvZFeF8HKXc1HBng2uJdOFJNMRM7dZcZL7EeecDujceJOJsOexMcx/QYj7LjNYj
         BVSkMSDGuyj4DJGQfbg28ek5nj1qXx823idoq3GmGMm3ql0ITXBhuwG13fTw3MYFVmXx
         rE2f/rycKSh2jCtxXaKxgAf3RrsAEtM5YlU3Z5ma2Zq0dDidET7fpQ2CqsuA5PUYBm0+
         gK5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=eqE4Z26zsNcQAJgC7bD2Jo1r09N+BCQVCnR1yuSDr4M=;
        b=aN3tMzQTjRkOQTiRY/+HQHU0rVrqIaXGFiaoO4y69ViMBQ3uXy7slBta1gTEi7wz3a
         j1Hi4HyW67VKWmGAb7A3j+A40RuzbqHjuQSODrG5V4LiXNpl/nx6PH+aUn0mUmC8mtrC
         HX1mw1BHpit1DjOSMjjqLJoiG+oa02j/dqFWfY2hITKocm6bT3sdhOTzXuyG+PKmb489
         biVvtp7naqmAnn1HDSe+26mLGnW6bRvsHeUFk2nirT+cIVkgBeq9hBO1/MOVw494+Fa9
         qCODEfI728zuQbQXZ5ASGYx7jZdAU3tYNHlU8ubWdVmwdra2U8ODXNaktR3/Wk34x7ef
         pSaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=j0O+6fuT;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id x126si14659096ybx.360.2019.01.02.19.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 19:27:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=j0O+6fuT;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c2d81080000>; Wed, 02 Jan 2019 19:27:04 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 02 Jan 2019 19:27:18 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 02 Jan 2019 19:27:18 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 3 Jan
 2019 03:27:18 +0000
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Jerome Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>
CC: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>,
	Dan Williams <dan.j.williams@intel.com>, John Hubbard
	<john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM
	<linux-mm@kvack.org>, <tom@talpey.com>, Al Viro <viro@zeniv.linux.org.uk>,
	<benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Christopher Lameter
	<cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug
 Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko
	<mhocko@kernel.org>, <mike.marciniszyn@intel.com>, <rcampbell@nvidia.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>
References: <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard> <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard> <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com> <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <8ea4ebe9-bb4f-67e2-c7cb-7404598b7c7e@nvidia.com>
Date: Wed, 2 Jan 2019 19:27:17 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190103015533.GA15619@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1546486025; bh=eqE4Z26zsNcQAJgC7bD2Jo1r09N+BCQVCnR1yuSDr4M=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=j0O+6fuTPoDzwrxY0DZeiwLr1x/T/S8vi6gCBA/gvq7Qhs5wk6hsXzaJw2Vz4DGmP
	 jJVhpmBtiPWpJovLDMc+OBWmrauRSZfb9X8FqYIM8NYVHaNTr9GfukcugOjz3bO7+z
	 sMGVpjAGj3nfhXQSADF+fnLOGwo7TMp4T23GTCCMv8T/qKqMsvq4DqzlCvm1UGztt4
	 Ni0xH7bY89+5O/o7X8y3TSUiNj8ryuiEaSNVlXfPYxBGb6sD10yTlzr2GxOV1iUHBA
	 Ttwt1Pwv8p2/VGl58AA3ssVvRPxUTtntntmBKptG+maTIo49oTogfniplNSwrK3gPh
	 glGaQxOqpYOoQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103032717.9KXZcLORhQ97qwEYcoQpqcCCz0XCZ-U1kRquk-vn34A@z>

On 1/2/19 5:55 PM, Jerome Glisse wrote:
> On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
>> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
>>> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
>>>> OK, so let's take another look at Jerome's _mapcount idea all by itsel=
f (using
>>>> *only* the tracking pinned pages aspect), given that it is the lightes=
t weight
>>>> solution for that. =20
>>>>
>>>> So as I understand it, this would use page->_mapcount to store both th=
e real
>>>> mapcount, and the dma pinned count (simply added together), but only d=
o so for
>>>> file-backed (non-anonymous) pages:
>>>>
>>>>
>>>> __get_user_pages()
>>>> {
>>>> 	...
>>>> 	get_page(page);
>>>>
>>>> 	if (!PageAnon)
>>>> 		atomic_inc(page->_mapcount);
>>>> 	...
>>>> }
>>>>
>>>> put_user_page(struct page *page)
>>>> {
>>>> 	...
>>>> 	if (!PageAnon)
>>>> 		atomic_dec(&page->_mapcount);
>>>>
>>>> 	put_page(page);
>>>> 	...
>>>> }
>>>>
>>>> ...and then in the various consumers of the DMA pinned count, we use p=
age_mapped(page)
>>>> to see if any mapcount remains, and if so, we treat it as DMA pinned. =
Is that what you=20
>>>> had in mind?
>>>
>>> Mostly, with the extra two observations:
>>>     [1] We only need to know the pin count when a write back kicks in
>>>     [2] We need to protect GUP code with wait_for_write_back() in case
>>>         GUP is racing with a write back that might not the see the
>>>         elevated mapcount in time.
>>>
>>> So for [2]
>>>
>>> __get_user_pages()
>>> {
>>>     get_page(page);
>>>
>>>     if (!PageAnon) {
>>>         atomic_inc(page->_mapcount);
>>> +       if (PageWriteback(page)) {
>>> +           // Assume we are racing and curent write back will not see
>>> +           // the elevated mapcount so wait for current write back and
>>> +           // force page fault
>>> +           wait_on_page_writeback(page);
>>> +           // force slow path that will fault again
>>> +       }
>>>     }
>>> }
>>
>> This is not needed AFAICT. __get_user_pages() gets page reference (and i=
t
>> should also increment page->_mapcount) under PTE lock. So at that point =
we
>> are sure we have writeable PTE nobody can change. So page_mkclean() has =
to
>> block on PTE lock to make PTE read-only and only after going through all
>> PTEs like this, it can check page->_mapcount. So the PTE lock provides
>> enough synchronization.
>>
>>> For [1] only needing pin count during write back turns page_mkclean int=
o
>>> the perfect spot to check for that so:
>>>
>>> int page_mkclean(struct page *page)
>>> {
>>>     int cleaned =3D 0;
>>> +   int real_mapcount =3D 0;
>>>     struct address_space *mapping;
>>>     struct rmap_walk_control rwc =3D {
>>>         .arg =3D (void *)&cleaned,
>>>         .rmap_one =3D page_mkclean_one,
>>>         .invalid_vma =3D invalid_mkclean_vma,
>>> +       .mapcount =3D &real_mapcount,
>>>     };
>>>
>>>     BUG_ON(!PageLocked(page));
>>>
>>>     if (!page_mapped(page))
>>>         return 0;
>>>
>>>     mapping =3D page_mapping(page);
>>>     if (!mapping)
>>>         return 0;
>>>
>>>     // rmap_walk need to change to count mapping and return value
>>>     // in .mapcount easy one
>>>     rmap_walk(page, &rwc);
>>>
>>>     // Big fat comment to explain what is going on
>>> +   if ((page_mapcount(page) - real_mapcount) > 0) {
>>> +       SetPageDMAPined(page);
>>> +   } else {
>>> +       ClearPageDMAPined(page);
>>> +   }
>>
>> This is the detail I'm not sure about: Why cannot rmap_walk_file() race
>> with e.g. zap_pte_range() which decrements page->_mapcount and thus the
>> check we do in page_mkclean() is wrong?
>>
>=20
> Ok so i found a solution for that. First GUP must wait for racing
> write back. If GUP see a valid write-able PTE and the page has
> write back flag set then it must back of as if the PTE was not
> valid to force fault. It is just a race with page_mkclean and we
> want ordering between the two. Note this is not strictly needed
> so we can relax that but i believe this ordering is better to do
> in GUP rather then having each single user of GUP test for this
> to avoid the race.
>=20
> GUP increase mapcount only after checking that it is not racing
> with writeback it also set a page flag (SetPageDMAPined(page)).
>=20
> When clearing a write-able pte we set a special entry inside the
> page table (might need a new special swap type for this) and change
> page_mkclean_one() to clear to 0 those special entry.
>=20
>=20
> Now page_mkclean:
>=20
> int page_mkclean(struct page *page)
> {
>     int cleaned =3D 0;
> +   int real_mapcount =3D 0;
>     struct address_space *mapping;
>     struct rmap_walk_control rwc =3D {
>         .arg =3D (void *)&cleaned,
>         .rmap_one =3D page_mkclean_one,
>         .invalid_vma =3D invalid_mkclean_vma,
> +       .mapcount =3D &real_mapcount,
>     };
> +   int mapcount1, mapcount2;
>=20
>     BUG_ON(!PageLocked(page));
>=20
>     if (!page_mapped(page))
>         return 0;
>=20
>     mapping =3D page_mapping(page);
>     if (!mapping)
>         return 0;
>=20
> +   mapcount1 =3D page_mapcount(page);
>=20
>     // rmap_walk need to change to count mapping and return value
>     // in .mapcount easy one
>     rmap_walk(page, &rwc);
>=20
> +   if (PageDMAPined(page)) {
> +       int rc2;
> +
> +       if (mapcount1 =3D=3D real_count) {
> +           /* Page is no longer pin, no zap pte race */
> +           ClearPageDMAPined(page);
> +           goto out;
> +       }
> +       /* No new mapping of the page so mp1 < rc is illegal. */
> +       VM_BUG_ON(mapcount1 < real_count);
> +       /* Page might be pin. */
> +       mapcount2 =3D page_mapcount(page);
> +       if (mapcount2 > real_count) {
> +           /* Page is pin for sure. */
> +           goto out;
> +       }
> +       /* We had a race with zap pte we need to rewalk again. */
> +       rc2 =3D real_mapcount;
> +       real_mapcount =3D 0;
> +       rwc.rmap_one =3D page_pin_one;
> +       rmap_walk(page, &rwc);
> +       if (mapcount2 <=3D (real_count + rc2)) {
> +           /* Page is no longer pin */
> +           ClearPageDMAPined(page);
> +       }
> +       /* At this point the page pin flag reflect pin status of the page=
 */

Until...what? In other words, what is providing synchronization here?

thanks,
--=20
John Hubbard
NVIDIA

> +   }
> +
> +out:
>     ...
> }
>=20
> The page_pin_one() function count the number of special PTE entry so
> which match the count of pte that have been zapped since the first
> reverse map walk.
>=20
> So worst case a page that was pin by a GUP would need 2 reverse map
> walk during page_mkclean(). Moreover this is only needed if we race
> with something that clear pte. I believe this is an acceptable worst
> case. I will work on some RFC patchset next week (once i am down with
> email catch up).
>=20
>=20
> I do not think i made mistake here, i have been torturing my mind
> trying to think of any race scenario and i believe it holds to any
> racing zap and page_mkclean()
>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20

