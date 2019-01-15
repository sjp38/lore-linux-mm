Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27858C43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 21:56:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F585208E4
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 21:56:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="QmLKa2Am"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F585208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D8128E0003; Tue, 15 Jan 2019 16:56:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08A3C8E0002; Tue, 15 Jan 2019 16:56:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E92208E0003; Tue, 15 Jan 2019 16:56:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEB358E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 16:56:54 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id j187so1961161ybj.23
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:56:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=nvD2RfiKJKJ03Xs9kl+DEKuYIHbV6UiLKCm0Y+MYgV0=;
        b=QokjcVEg5hLCODa3vP2nTjg9xHMdv4zIx/oQKldPP/0h//uCSlm9VKyVwIxM/V2usl
         iZQoTtcZFUedXopMA6/xXIOiparFhIUt3lMvU2nzf+5wufvqqHUg47YgyRndwOvCWG7C
         /3NXPlj5anDONrtxONtAReGc379LwBn1zoskHOnuTD+KCBmXKoWifzUggMEscd66ZF2Y
         Acwz51HIsidevtRXdYpDA26/hM+x8y8NlDTRVS9a47qaFBNc1RAG1cP4nuYeEzhRpoS6
         4uXNSZ0YDD+Ii0UaqtDFt8MXKpeVm/u9leDrPBZ5vZBHlYt4SAB7nudTurxLd7xF/5Py
         F2hQ==
X-Gm-Message-State: AJcUukcfTAgDnpRlHc9tLVdB1ViqAEspQbJr1Y1TzLeVfqWYVWGfkl4y
	Nqb8dSU4Rz3CqwWfKV4U3Hz3C3OmmAUXi9qrAoYfInPhwLxaLC1HYmVcW8c/acvxDAY+mf0ncdc
	k9Pjw6XFYm2R6njtmRDylgfytGElLQIcxCS56u9KHUZ/0Wdks/6Ns+qvT1ugkN6U7Hg==
X-Received: by 2002:a81:2e0d:: with SMTP id u13mr5050345ywu.45.1547589414321;
        Tue, 15 Jan 2019 13:56:54 -0800 (PST)
X-Google-Smtp-Source: ALg8bN70EuU9VwyyeP/7Vm2OHSHPDRdzC5TCf+u7KrEm8UbryEOJ/B93d3OEqF5cGDTCzlsQDrYx
X-Received: by 2002:a81:2e0d:: with SMTP id u13mr5050296ywu.45.1547589413200;
        Tue, 15 Jan 2019 13:56:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547589413; cv=none;
        d=google.com; s=arc-20160816;
        b=iL6ZQxN2HBp72l1oHMeo+7qYKSX4D8GHvCikxOtu2b/vi+7SulIxGzl09UCv4nvQss
         sikYcDN2H+nptsH8MUkmJMaq/0Kn5uK034yOg+fzU2/na5Nd3N4uARnjy9pz7GLHrs41
         HNLSw3slQJaCBobi+x+s9xCejRJ21YJoLVgKwBV9PTvnWdIwiSmBiQqBaiyxF9kKrnI9
         ee8SgvxheM8pICupSKcNZyhrI9T09C9rdjRMIQyqkmwApEeovbgVwtvP/wsJFTCxNczD
         MDacjdogwa7f8HEdaP/XkH8jeSomtTbHsTnGTe6qXqNgkT2XJ3xKqc4tyYlPS/abkxY3
         m8Zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=nvD2RfiKJKJ03Xs9kl+DEKuYIHbV6UiLKCm0Y+MYgV0=;
        b=WVfFVku5ETa03hHiEeyNBOh61yvWYgaNawIJqdtQNtMIQyE0WBESyznGn+FILbHJ4I
         LxMqls3vVBQuicbDqENmj9kUGaJ1/5EoaVKZ+UM9tNtZnsPqmoYK64mSA0xH28muBseg
         DBkHVXxo3v3sKd9SjCF12MMJCCdorXekBzrkOjWoBhAso+zb2hO2Gd0u/w1YCQKa/Ldy
         fSu6B2IJL/0I7Xy1XygnVOHl5pTYH7Z3SiZS9Qtqza+N0l74ZgWtcWU1FQ4u1u8WjwH+
         nOPxrgV/x+ExpoP9IQqlWquqdHjYuZGc8fiZLCyVV9lGSRcV9ui/51Udc2eXbBjoshz+
         bDaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=QmLKa2Am;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 69si2906900ybn.382.2019.01.15.13.56.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 13:56:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=QmLKa2Am;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c3e57060001>; Tue, 15 Jan 2019 13:56:22 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 15 Jan 2019 13:56:51 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 15 Jan 2019 13:56:51 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Tue, 15 Jan
 2019 21:56:51 +0000
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
References: <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz> <20190115171557.GB3696@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <752839e6-6cb3-a6aa-94cb-63d3d4265934@nvidia.com>
Date: Tue, 15 Jan 2019 13:56:51 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190115171557.GB3696@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547589382; bh=nvD2RfiKJKJ03Xs9kl+DEKuYIHbV6UiLKCm0Y+MYgV0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=QmLKa2AmV8ZhyHBydqM5y4RaZ7Fdu7YW4baiR/P8jBj/il3Z7GAcuLak8DlSIXNqE
	 scyHHEH3kQ94PYEPXtAwSssiG2WJR24ZVzmUPfvObgp5z51MX5tScnJajae7NKbUU1
	 j63yAnY+gqkNOFSKm8wRlOXOD7eFrs3Nwa8k6GGvypk4Bfq1oD6tlQYYXrTh9lt2x5
	 m2bLT7rOeCywQUS7jQlhuoHZVVL2uERbFkwaP3ZH8Ts+zkCx5DJ1lcigaZKzTHWy7c
	 NYGJdml3xtCLrZJpUhDZHFxasmX3eiAfHZ5MBRTWt+aApryxhxcmYgo+3DH84Q0ADL
	 waARcyP+HNMqA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115215651.tq4g8oCbSslnIHLBjDzR_7H22mVD2nFI-2GN3PlQtwQ@z>

On 1/15/19 9:15 AM, Jerome Glisse wrote:
> On Tue, Jan 15, 2019 at 09:07:59AM +0100, Jan Kara wrote:
>> On Mon 14-01-19 12:21:25, Jerome Glisse wrote:
>>> On Mon, Jan 14, 2019 at 03:54:47PM +0100, Jan Kara wrote:
>>>> On Fri 11-01-19 19:06:08, John Hubbard wrote:
>>>>> On 1/11/19 6:46 PM, Jerome Glisse wrote:
>>>>>> On Fri, Jan 11, 2019 at 06:38:44PM -0800, John Hubbard wrote:
>>>>>> [...]
>>>>>>
>>>>>>>>> The other idea that you and Dan (and maybe others) pointed out was a debug
>>>>>>>>> option, which we'll certainly need in order to safely convert all the call
>>>>>>>>> sites. (Mirror the mappings at a different kernel offset, so that put_page()
>>>>>>>>> and put_user_page() can verify that the right call was made.)  That will be
>>>>>>>>> a separate patchset, as you recommended.
>>>>>>>>>
>>>>>>>>> I'll even go as far as recommending the page lock itself. I realize that this 
>>>>>>>>> adds overhead to gup(), but we *must* hold off page_mkclean(), and I believe
>>>>>>>>> that this (below) has similar overhead to the notes above--but is *much* easier
>>>>>>>>> to verify correct. (If the page lock is unacceptable due to being so widely used,
>>>>>>>>> then I'd recommend using another page bit to do the same thing.)
>>>>>>>>
>>>>>>>> Please page lock is pointless and it will not work for GUP fast. The above
>>>>>>>> scheme do work and is fine. I spend the day again thinking about all memory
>>>>>>>> ordering and i do not see any issues.
>>>>>>>>
>>>>>>>
>>>>>>> Why is it that page lock cannot be used for gup fast, btw?
>>>>>>
>>>>>> Well it can not happen within the preempt disable section. But after
>>>>>> as a post pass before GUP_fast return and after reenabling preempt then
>>>>>> it is fine like it would be for regular GUP. But locking page for GUP
>>>>>> is also likely to slow down some workload (with direct-IO).
>>>>>>
>>>>>
>>>>> Right, and so to crux of the matter: taking an uncontended page lock
>>>>> involves pretty much the same set of operations that your approach does.
>>>>> (If gup ends up contended with the page lock for other reasons than these
>>>>> paths, that seems surprising.) I'd expect very similar performance.
>>>>>
>>>>> But the page lock approach leads to really dramatically simpler code (and
>>>>> code reviews, let's not forget). Any objection to my going that
>>>>> direction, and keeping this idea as a Plan B? I think the next step will
>>>>> be, once again, to gather some performance metrics, so maybe that will
>>>>> help us decide.
>>>>
>>>> FWIW I agree that using page lock for protecting page pinning (and thus
>>>> avoid races with page_mkclean()) looks simpler to me as well and I'm not
>>>> convinced there will be measurable difference to the more complex scheme
>>>> with barriers Jerome suggests unless that page lock contended. Jerome is
>>>> right that you cannot just do lock_page() in gup_fast() path. There you
>>>> have to do trylock_page() and if that fails just bail out to the slow gup
>>>> path.
>>>>
>>>> Regarding places other than page_mkclean() that need to check pinned state:
>>>> Definitely page migration will want to check whether the page is pinned or
>>>> not so that it can deal differently with short-term page references vs
>>>> longer-term pins.
>>>>
>>>> Also there is one more idea I had how to record number of pins in the page:
>>>>
>>>> #define PAGE_PIN_BIAS	1024
>>>>
>>>> get_page_pin()
>>>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>>>
>>>> put_page_pin();
>>>> 	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>>>>
>>>> page_pinned(page)
>>>> 	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS
>>>>
>>>> This is pretty trivial scheme. It still gives us 22-bits for page pins
>>>> which should be plenty (but we should check for that and bail with error if
>>>> it would overflow). Also there will be no false negatives and false
>>>> positives only if there are more than 1024 non-page-table references to the
>>>> page which I expect to be rare (we might want to also subtract
>>>> hpage_nr_pages() for radix tree references to avoid excessive false
>>>> positives for huge pages although at this point I don't think they would
>>>> matter). Thoughts?
>>>
>>> Racing PUP are as likely to cause issues:
>>>
>>> CPU0                        | CPU1       | CPU2
>>>                             |            |
>>>                             | PUP()      |
>>>     page_pinned(page)       |            |
>>>       (page_count(page) -   |            |
>>>        page_mapcount(page)) |            |
>>>                             |            | GUP()
>>>
>>> So here the refcount snap-shot does not include the second GUP and
>>> we can have a false negative ie the page_pinned() will return false
>>> because of the PUP happening just before on CPU1 despite the racing
>>> GUP on CPU2 just after.
>>>
>>> I believe only either lock or memory ordering with barrier can
>>> guarantee that we do not miss GUP ie no false negative. Still the
>>> bias idea might be usefull as with it we should not need a flag.
>>
>> Right. We need similar synchronization (i.e., page lock or careful checks
>> with memory barriers) if we want to get a reliable page pin information.
>>
>>> So to make the above safe it would still need the page write back
>>> double check that i described so that GUP back-off if it raced with
>>> page_mkclean,clear_page_dirty_for_io and the fs write page call back
>>> which call test_set_page_writeback() (yes it is very unlikely but
>>> might still happen).
>>
>> Agreed. So with page lock it would actually look like:
>>
>> get_page_pin()
>> 	lock_page(page);
>> 	wait_for_stable_page();
>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>> 	unlock_page(page);
>>
>> And if we perform page_pinned() check under page lock, then if
>> page_pinned() returned false, we are sure page is not and will not be
>> pinned until we drop the page lock (and also until page writeback is
>> completed if needed).
>>

OK. Avoiding a new page flag, *and* avoiding the _mapcount auditing and
compensation steps, is a pretty major selling point. And if we do the above
locking, that does look correct to me. I wasn't able to visualize the
locking you had in mind, until just now (above), but now it is clear, 
thanks for spelling it out.

> 
> So i still can't see anything wrong with that idea, i had similar
> one in the past and diss-missed and i can't remember why :( But
> thinking over and over i do not see any issue beside refcount wrap
> around. Which is something that can happens today thought i don't
> think it can be use in an evil way and we can catch it and be
> loud about it.
> 
> So i think the following would be bullet proof:
> 
> 
> get_page_pin()
>     atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>     smp_wmb();
>     if (PageWriteback(page)) {
>         // back off
>         atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>         // re-enable preempt if in fast
>         wait_on_page_writeback(page);
>         goto retry;
>     }
> 
> put_page_pin();
> 	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
> 
> page_pinned(page)
> 	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS
> 
> test_set_page_writeback()
>     ...
>     wb = TestSetPageWriteback(page)

Minor point, but using PageWriteback for synchronization may rule out using
wait_for_stable_page(), because wait_for_stable_page() might not actually 
wait_on_page_writeback. Jan pointed out in the other thread, that we should
prefer wait_for_stable_page(). 


>     smp_mb();
>     if (page_pinned(page)) {
>         // report page as pinned to caller of test_set_page_writeback()
>     }
>     ...
> 
> This is text book memory barrier. Either get_page_pin() see racing
> test_set_page_writeback() or test_set_page_writeback() see racing GUP
> 
> 

This approach is probably workable, but again, it's more complex and comes
without any lockdep support. Maybe it's faster, maybe not. Therefore, I want 
to use it as either "do this after everything is up and running and stable", 
or else as Plan B, if there is some performance implication from the page lock.

Simple and correct first, then performance optimization, *if* necessary.


> An optimization for GUP:
> get_page_pin()
>     pwp = PageWriteback(page);
>     smp_rmb();
>     waspinned = page_pinned(page);
>     if (!waspinned && pwp) {
>         // backoff
>     }
> 
>     atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>     smp_wmb();
>     if (PageWriteback(page)) {
>         // back off
>         atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>         // re-enable preempt if in fast
>         wait_on_page_writeback(page);
>         goto retry;
>     }
> 
> If page was not pin prior to this GUP than we can back off early.
> 
> 
> Anyway i think this is better than mapcount. I started an analysis
> of all places that were looking at mapcount a few of them would have
> need an update if we were to increment mapcount with GUP.
> 
> I will go take a look at THP and hugetlbfs in respect to this just
> to check for way to mitigate false positive.
> 

Awesome. I still have a hard time with the details of THP and hugetlbfs,
so it's good to have someone who understands it, taking a closer look.

thanks,
-- 
John Hubbard
NVIDIA

