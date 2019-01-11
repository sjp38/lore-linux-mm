Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DBF6C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:59:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC93920872
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:59:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="MS6kIQAs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC93920872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 332F08E0003; Thu, 10 Jan 2019 21:59:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BAD28E0001; Thu, 10 Jan 2019 21:59:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 184188E0003; Thu, 10 Jan 2019 21:59:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id E03198E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:59:34 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id r191so6614895ybr.12
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:59:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=8T7sWNsDeGtmRKP2KvNypFF/LerYK2UzqASBF7f1s24=;
        b=O5KwuRI51SB7wWAGxTAh9IKAb9W70CyIZvk6VWq7YWiwMNSEnSxQ/2k13NZGNVmlRH
         jENwrnGaRR71y5vtLuepbCEh4gwocJKaxG0DyrRb2Omr8CJB+w1Ace7C+v+1354n7J/8
         M/XLZs2w5NluHhcs4AZXj3Pw9l1yyoRxpdTcYyYUjlZWQCriUxo8hp+/2TzdYul+Ut8u
         H4bstHF0ksa9MU/5G6qB1OAPe7q2SWtXBHa9E6iTPof+SOSnbqZHAum+PjqN55ONL5he
         vHCdPRffOzxv0Bl4s88OjZbnZ223Q2KpI7E4NWwIRl+GdPL/tddYAT1Xlm7pjUXmRskd
         urzw==
X-Gm-Message-State: AJcUukdKk7DZwAUcBxhJKQyv4lToHR5tK8UVrGejE0oSK8hLPVmi3s1C
	uLuvg09eeQN72WtE/Avc2jcpfTiL12BjE3YJVNtUZEdhbkO2m0HzTP6Fei1fe6olsRlSWg410YL
	f4gN5p9GiybCpSEnYAUruBb4Wy6Nvq5aqeyj1HfbF9uq6XuJsOBn4ZmqbwyQulWuwCQ==
X-Received: by 2002:a81:3454:: with SMTP id b81mr12566880ywa.191.1547175574475;
        Thu, 10 Jan 2019 18:59:34 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4C/98bIVpFEI6BSbDG3ochDzCV3WuezVErk2k0PPyGayqI8iFY1IpY9FImQijJDkhLlAQ8
X-Received: by 2002:a81:3454:: with SMTP id b81mr12566852ywa.191.1547175573570;
        Thu, 10 Jan 2019 18:59:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547175573; cv=none;
        d=google.com; s=arc-20160816;
        b=vDzUYCpoi/n5Mc9/jIWRJGhFpr2bHxRLasOAJvIJkrPvNvNN4Jvm29b8hzn3k9kttL
         uHzgyeFgDr4YuqKaMRky3fDeVGJCziBOts/hUiFR81Sqi3jhjVIJL/NF2JT507F+Ad9H
         yUBgdBRU5bHyrgNsYC7od8DMiewkF6F2E1X9kOWQw7ABK/6vyCXDSf71KDskqgq2zSZA
         t0D0Vn/mLJoiXpPNXPim3tXmvTqJ2e4S4tQKbi31pyrM1iNho6agKfEEm4cXGl3NqZWD
         SngtJ37hHC6QjZR6ulFbalhB+iaJR+PSqMudwAupt5EHF2u49G+brvGeKrxxJozIaHeu
         +dcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=8T7sWNsDeGtmRKP2KvNypFF/LerYK2UzqASBF7f1s24=;
        b=gsADF2VYkMKILAOqW7XK76TJa28ku8pxY9cLGc5L39AUuxAqlDn3LP+KYLUFY9gfw/
         1MHn2e3MVLC9Y2mX0OiF1TbPNWKzHsGO8SP8g1Te0QSJORlQP6BFhnm3wMXRwLsniL2j
         EDnKJvr0ZtIxTeIuuB8PVtmdHNIssKiXuhj6EO8pe9B9/+gsVgXZslNy8frG6FVTsaZw
         oIJaR3syW5stMVmzi8n+kmXjIFxUBXnBjXpRs2YdvI6A/mTZsCssXgsmidiYa7O8uVdT
         qqHsui0amEWIsl54BnYEPC5o64HnZVoLH+gjcuLGPQV9O39HJc/5V5KCH32xCOVxM8jR
         tqyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=MS6kIQAs;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id y62si14476274yba.94.2019.01.10.18.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 18:59:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=MS6kIQAs;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c3806820001>; Thu, 10 Jan 2019 18:59:14 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 10 Jan 2019 18:59:32 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 10 Jan 2019 18:59:32 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 11 Jan
 2019 02:59:31 +0000
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
References: <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard> <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com> <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com> <20190103092654.GA31370@quack2.suse.cz>
 <20190103144405.GC3395@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
Date: Thu, 10 Jan 2019 18:59:31 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190103144405.GC3395@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547175554; bh=8T7sWNsDeGtmRKP2KvNypFF/LerYK2UzqASBF7f1s24=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=MS6kIQAsnALSdgIUSgQ14qtpQ1F413ka8tuh9Tdgyayy0/22RF2Pu20W9SddvVkIy
	 PsAMHm5eMVjWGM0EOd0g6Ep1dMBq8yHaY3V7ka1126LtF1H/n0pjLCJPXjxiqLbUeA
	 JVDP34jTz3taqXoFwsuOL0dkGBjBVYRqlpGBvwxGbv41BGL9pNFC6UCGfy8E1IT4q2
	 bl4gyvCLvHU3yvgxMCKwtZiwewLuNirmAdBnl2fLjdkfSG0o3TapCvvJrJ6WZBG3+Z
	 tSY5k5W2FSSY2Ws9wIUhw7ZxOMMDFVFn7q2/n6YX6fudbZPxlJ12rTueXDCDko2gMC
	 FKWEgTnggJFMA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111025931.us5OziCGAYIUAi3BkMqNFuttf5KWp0htrOWaIYFNhGc@z>

On 1/3/19 6:44 AM, Jerome Glisse wrote:
> On Thu, Jan 03, 2019 at 10:26:54AM +0100, Jan Kara wrote:
>> On Wed 02-01-19 20:55:33, Jerome Glisse wrote:
>>> On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
>>>> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
>>>>> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
>>>>>> OK, so let's take another look at Jerome's _mapcount idea all by itself (using
>>>>>> *only* the tracking pinned pages aspect), given that it is the lightest weight
>>>>>> solution for that.  
>>>>>>
>>>>>> So as I understand it, this would use page->_mapcount to store both the real
>>>>>> mapcount, and the dma pinned count (simply added together), but only do so for
>>>>>> file-backed (non-anonymous) pages:
>>>>>>
>>>>>>
>>>>>> __get_user_pages()
>>>>>> {
>>>>>> 	...
>>>>>> 	get_page(page);
>>>>>>
>>>>>> 	if (!PageAnon)
>>>>>> 		atomic_inc(page->_mapcount);
>>>>>> 	...
>>>>>> }
>>>>>>
>>>>>> put_user_page(struct page *page)
>>>>>> {
>>>>>> 	...
>>>>>> 	if (!PageAnon)
>>>>>> 		atomic_dec(&page->_mapcount);
>>>>>>
>>>>>> 	put_page(page);
>>>>>> 	...
>>>>>> }
>>>>>>
>>>>>> ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
>>>>>> to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
>>>>>> had in mind?
>>>>>
>>>>> Mostly, with the extra two observations:
>>>>>     [1] We only need to know the pin count when a write back kicks in
>>>>>     [2] We need to protect GUP code with wait_for_write_back() in case
>>>>>         GUP is racing with a write back that might not the see the
>>>>>         elevated mapcount in time.
>>>>>
>>>>> So for [2]
>>>>>
>>>>> __get_user_pages()
>>>>> {
>>>>>     get_page(page);
>>>>>
>>>>>     if (!PageAnon) {
>>>>>         atomic_inc(page->_mapcount);
>>>>> +       if (PageWriteback(page)) {
>>>>> +           // Assume we are racing and curent write back will not see
>>>>> +           // the elevated mapcount so wait for current write back and
>>>>> +           // force page fault
>>>>> +           wait_on_page_writeback(page);
>>>>> +           // force slow path that will fault again
>>>>> +       }
>>>>>     }
>>>>> }
>>>>
>>>> This is not needed AFAICT. __get_user_pages() gets page reference (and it
>>>> should also increment page->_mapcount) under PTE lock. So at that point we
>>>> are sure we have writeable PTE nobody can change. So page_mkclean() has to
>>>> block on PTE lock to make PTE read-only and only after going through all
>>>> PTEs like this, it can check page->_mapcount. So the PTE lock provides
>>>> enough synchronization.
>>>>
>>>>> For [1] only needing pin count during write back turns page_mkclean into
>>>>> the perfect spot to check for that so:
>>>>>
>>>>> int page_mkclean(struct page *page)
>>>>> {
>>>>>     int cleaned = 0;
>>>>> +   int real_mapcount = 0;
>>>>>     struct address_space *mapping;
>>>>>     struct rmap_walk_control rwc = {
>>>>>         .arg = (void *)&cleaned,
>>>>>         .rmap_one = page_mkclean_one,
>>>>>         .invalid_vma = invalid_mkclean_vma,
>>>>> +       .mapcount = &real_mapcount,
>>>>>     };
>>>>>
>>>>>     BUG_ON(!PageLocked(page));
>>>>>
>>>>>     if (!page_mapped(page))
>>>>>         return 0;
>>>>>
>>>>>     mapping = page_mapping(page);
>>>>>     if (!mapping)
>>>>>         return 0;
>>>>>
>>>>>     // rmap_walk need to change to count mapping and return value
>>>>>     // in .mapcount easy one
>>>>>     rmap_walk(page, &rwc);
>>>>>
>>>>>     // Big fat comment to explain what is going on
>>>>> +   if ((page_mapcount(page) - real_mapcount) > 0) {
>>>>> +       SetPageDMAPined(page);
>>>>> +   } else {
>>>>> +       ClearPageDMAPined(page);
>>>>> +   }
>>>>
>>>> This is the detail I'm not sure about: Why cannot rmap_walk_file() race
>>>> with e.g. zap_pte_range() which decrements page->_mapcount and thus the
>>>> check we do in page_mkclean() is wrong?
>>>>
>>>
>>> Ok so i found a solution for that. First GUP must wait for racing
>>> write back. If GUP see a valid write-able PTE and the page has
>>> write back flag set then it must back of as if the PTE was not
>>> valid to force fault. It is just a race with page_mkclean and we
>>> want ordering between the two. Note this is not strictly needed
>>> so we can relax that but i believe this ordering is better to do
>>> in GUP rather then having each single user of GUP test for this
>>> to avoid the race.
>>>
>>> GUP increase mapcount only after checking that it is not racing
>>> with writeback it also set a page flag (SetPageDMAPined(page)).
>>>
>>> When clearing a write-able pte we set a special entry inside the
>>> page table (might need a new special swap type for this) and change
>>> page_mkclean_one() to clear to 0 those special entry.
>>>
>>>
>>> Now page_mkclean:
>>>
>>> int page_mkclean(struct page *page)
>>> {
>>>     int cleaned = 0;
>>> +   int real_mapcount = 0;
>>>     struct address_space *mapping;
>>>     struct rmap_walk_control rwc = {
>>>         .arg = (void *)&cleaned,
>>>         .rmap_one = page_mkclean_one,
>>>         .invalid_vma = invalid_mkclean_vma,
>>> +       .mapcount = &real_mapcount,
>>>     };
>>> +   int mapcount1, mapcount2;
>>>
>>>     BUG_ON(!PageLocked(page));
>>>
>>>     if (!page_mapped(page))
>>>         return 0;
>>>
>>>     mapping = page_mapping(page);
>>>     if (!mapping)
>>>         return 0;
>>>
>>> +   mapcount1 = page_mapcount(page);
>>>     // rmap_walk need to change to count mapping and return value
>>>     // in .mapcount easy one
>>>     rmap_walk(page, &rwc);
>>
>> So what prevents GUP_fast() to grab reference here and the test below would
>> think the page is not pinned? Or do you assume that every page_mkclean()
>> call will be protected by PageWriteback (currently it is not) so that
>> GUP_fast() blocks / bails out?

Continuing this thread, still focusing only on the "how to maintain a PageDmaPinned
for each page" question (ignoring, for now, what to actually *do* in response to 
that flag being set):

1. Jan's point above is still a problem: PageWriteback != "page_mkclean is happening".
This is probably less troubling than the next point, but it does undermine all the 
complicated schemes involving PageWriteback, that try to synchronize gup() with
page_mkclean().

2. Also, the mapcount approach here still does not reliably avoid false negatives
(that is, a page may have been gup'd, but page_mkclean could miss that): gup()
can always jump in and increment the mapcount, while page_mkclean is in the middle
of making (wrong) decisions based on that mapcount. There's no lock to prevent that.

Again: mapcount can go up *or* down, so I'm not seeing a true solution yet.

> 
> So GUP_fast() becomes:
> 
> GUP_fast_existing() { ... }
> GUP_fast()
> {
>     GUP_fast_existing();
> 
>     for (i = 0; i < npages; ++i) {
>         if (PageWriteback(pages[i])) {
>             // need to force slow path for this page
>         } else {
>             SetPageDmaPinned(pages[i]);
>             atomic_inc(pages[i]->mapcount);
>         }
>     }
> }
> 
> This is a minor slow down for GUP fast and it takes care of a
> write back race on behalf of caller. This means that page_mkclean
> can not see a mapcount value that increase. This simplify thing
> we can relax that. Note that what this is doing is making sure
> that GUP_fast never get lucky :) ie never GUP a page that is in
> the process of being write back but has not yet had its pte
> updated to reflect that.
> 
> 
>> But I think that detecting pinned pages with small false positive rate is
>> OK. The extra page bouncing will cost some performance but if it is rare,
>> then we are OK. So I think we can go for the simple version of detecting
>> pinned pages as you mentioned in some earlier email. We just have to be
>> sure there are no false negatives.
> 

Agree with that sentiment, but there are still false negatives and I'm not
yet seeing any solutions for that.

thanks,
-- 
John Hubbard
NVIDIA

