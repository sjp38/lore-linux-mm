Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78C11C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 00:44:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DB2C2082F
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 00:44:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="VFl25ER1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DB2C2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B08CF8E0003; Tue, 15 Jan 2019 19:44:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB8078E0002; Tue, 15 Jan 2019 19:44:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A6C98E0003; Tue, 15 Jan 2019 19:44:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62A888E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 19:44:45 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id k1so2186499ybm.8
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 16:44:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=EBsIyufukS8xf4IW03O1jaBj01hrHS9LnbIc19sfp3M=;
        b=igCfvOgVm2OMfz+DpFWKBzbVoK5hkK/mupgzIgN44lB0zjVEsld6gRrCy4DrePxEU8
         zTy56DX++Lr3MSR4PwB2PhvN2lxAUy72Z+lJI684X3N/Sbca5L36adploYxKyyPbp1MB
         VdHzRcJGZ8ai7ATIpBUKHAICagtF/mptNKXACeNR2ioLUGXu0A1XVNq0OTxKNkSv/3dk
         7m1MAg5sa8FGm8hIfbg8BxPsONiBr2/b/QdRzC5Ojcdgm/W5/BHg0SAqQ/b4h5qx9ZSH
         9GokzWDBPOp8itRg0LrEt4OgAEzTe9Ao+FQamUBfH6kA5l5QEquBU6rRxljpC+Z7bKW/
         FMeQ==
X-Gm-Message-State: AJcUukew1RmjLryJUcLSDVFd398GrfVIgTrOITm0BQmc2w8FJT73oDEt
	Py04lok0jnDnlWV7bIHYgjLOt/amSDgfq9xxvhkNdMx7pLZPOHokdJFsqDbbR3bDrwVtBo65RHv
	3wXXqRirJjWqRdmZYdeRqLKCurTkfcvG6QGeEKxexr/kf3mXtdqDLCbQE8BwhJAdt6w==
X-Received: by 2002:a25:3b82:: with SMTP id i124mr5480595yba.183.1547599484960;
        Tue, 15 Jan 2019 16:44:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5I5fhyseoMI7mdF6Iiz5gSMj89YzYg3rEjTn4EetcCMvA6j4QVntGv7N2Usrs8rWUcA3IO
X-Received: by 2002:a25:3b82:: with SMTP id i124mr5480546yba.183.1547599483546;
        Tue, 15 Jan 2019 16:44:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547599483; cv=none;
        d=google.com; s=arc-20160816;
        b=M5h+W8eWFFvLZI6RGggOlEJe/qjAvqL67it6PAt9VNqVh28GKVuHQZcIriyhn+caOO
         YXO8JsoXaote9exBZldckY29QH+YYQAnrDWIZbfj4kI6aQrvB0EEGYIQ3TMPBhoknG76
         m3gTEeRJqSoT4A0en0rdVQGLLmcWWdbCsPj469qrM0srdG3gOUI9/HtnOBE4fO4ZMN5q
         YrIaqdsQonvQ8Gr4+XN8f0EuWNqhTZelHHbavLAQGKIhe7DP2nx9J99GR1pE3iAJ3Hf2
         mnXxq1oIDn+rB+3CLxVp0ALyQQTawpod3vSTsfekD96Jv2O6nwRMwJDCKn5OYOfTPNKG
         h4+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=EBsIyufukS8xf4IW03O1jaBj01hrHS9LnbIc19sfp3M=;
        b=Q6BPFtrAkuGc76/P9zGok/DFa/e0PabmwOpiS0MqaKq2+NwKuezqYGfLwmqTIb8LTm
         gCpqp0ACpsxDTEh02bNuhwKORxgKu/TtvSjRH9VKCr1a+e7Fd8jbihGXnWUgLtWvp0QV
         Bg0oaegjjpiLZdWn/UnbSG7HiHkOkoMxkAKmbNUA8xtfTNN8QANykh57rbb5ywW0xLfs
         Vr2rM+DWWMsVxmfzPlxqrGe5uzqhQeccttW/7zd+SyHFC5e4UxG8z8mWUkVTmAsat7Xn
         DJMk6KzUK7TpvM+0h64urJvOojzEIpIMI7l4TfAjXiP6qRxumLXqD95SSnwP5TyT68IM
         Si2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=VFl25ER1;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id q203si3167084ywc.246.2019.01.15.16.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 16:44:43 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=VFl25ER1;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c3e7e6b0001>; Tue, 15 Jan 2019 16:44:27 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 15 Jan 2019 16:44:42 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 15 Jan 2019 16:44:42 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 16 Jan
 2019 00:44:42 +0000
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Jerome Glisse <jglisse@redhat.com>
CC: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave
 Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John
 Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, <tom@talpey.com>, Al Viro
	<viro@zeniv.linux.org.uk>, <benve@cisco.com>, Christoph Hellwig
	<hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>,
	<mike.marciniszyn@intel.com>, <rcampbell@nvidia.com>, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>
References: <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz> <20190115171557.GB3696@redhat.com>
 <752839e6-6cb3-a6aa-94cb-63d3d4265934@nvidia.com>
 <20190115221205.GD3696@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <99110c19-3168-f6a9-fbde-0a0e57f67279@nvidia.com>
Date: Tue, 15 Jan 2019 16:44:41 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190115221205.GD3696@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547599467; bh=EBsIyufukS8xf4IW03O1jaBj01hrHS9LnbIc19sfp3M=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=VFl25ER1ahDYHXEqGShHfWtV7Ef23yg2WmLLQTUzKfejYxH381s38N8PRi5IRUAIb
	 2SiKRAJqOwqMcHNHJBQqAIVhfpYtUXvurpyTmF1E/W31uLW09oSZwl/g/R+INt1jdZ
	 uRsIwcfkOXX9QM5Wj0GT+J22iVx/iX+wS0xs7A7aDutzvtEGQ/DMuov1TlQ0GZnDD2
	 MPGTUvLY2WCflHpJeev2pVNAwXWq0Ou7Q0FSXGH1UEvjkcETzqW31kvFtw3Oj3o/MY
	 7Qh6hSPmjFzTXxGQRAoJJAMa02IWt0jTBxE/7QRkCiodcVKSsPgMf5Vpys4+t4CZAt
	 wpbYJ9Pcyp32A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116004441.FpX8HXeaLoyXJEc5397u7RJlInETDLVXkIVmWINw91g@z>

On 1/15/19 2:12 PM, Jerome Glisse wrote:
> On Tue, Jan 15, 2019 at 01:56:51PM -0800, John Hubbard wrote:
>> On 1/15/19 9:15 AM, Jerome Glisse wrote:
>>> On Tue, Jan 15, 2019 at 09:07:59AM +0100, Jan Kara wrote:
>>>> On Mon 14-01-19 12:21:25, Jerome Glisse wrote:
>>>>> On Mon, Jan 14, 2019 at 03:54:47PM +0100, Jan Kara wrote:
>>>>>> On Fri 11-01-19 19:06:08, John Hubbard wrote:
>>>>>>> On 1/11/19 6:46 PM, Jerome Glisse wrote:
>>>>>>>> On Fri, Jan 11, 2019 at 06:38:44PM -0800, John Hubbard wrote:
>>>>>>>> [...]
>>>>>>>>
>>>>>>>>>>> The other idea that you and Dan (and maybe others) pointed out was a debug
>>>>>>>>>>> option, which we'll certainly need in order to safely convert all the call
>>>>>>>>>>> sites. (Mirror the mappings at a different kernel offset, so that put_page()
>>>>>>>>>>> and put_user_page() can verify that the right call was made.)  That will be
>>>>>>>>>>> a separate patchset, as you recommended.
>>>>>>>>>>>
>>>>>>>>>>> I'll even go as far as recommending the page lock itself. I realize that this 
>>>>>>>>>>> adds overhead to gup(), but we *must* hold off page_mkclean(), and I believe
>>>>>>>>>>> that this (below) has similar overhead to the notes above--but is *much* easier
>>>>>>>>>>> to verify correct. (If the page lock is unacceptable due to being so widely used,
>>>>>>>>>>> then I'd recommend using another page bit to do the same thing.)
>>>>>>>>>>
>>>>>>>>>> Please page lock is pointless and it will not work for GUP fast. The above
>>>>>>>>>> scheme do work and is fine. I spend the day again thinking about all memory
>>>>>>>>>> ordering and i do not see any issues.
>>>>>>>>>>
>>>>>>>>>
>>>>>>>>> Why is it that page lock cannot be used for gup fast, btw?
>>>>>>>>
>>>>>>>> Well it can not happen within the preempt disable section. But after
>>>>>>>> as a post pass before GUP_fast return and after reenabling preempt then
>>>>>>>> it is fine like it would be for regular GUP. But locking page for GUP
>>>>>>>> is also likely to slow down some workload (with direct-IO).
>>>>>>>>
>>>>>>>
>>>>>>> Right, and so to crux of the matter: taking an uncontended page lock
>>>>>>> involves pretty much the same set of operations that your approach does.
>>>>>>> (If gup ends up contended with the page lock for other reasons than these
>>>>>>> paths, that seems surprising.) I'd expect very similar performance.
>>>>>>>
>>>>>>> But the page lock approach leads to really dramatically simpler code (and
>>>>>>> code reviews, let's not forget). Any objection to my going that
>>>>>>> direction, and keeping this idea as a Plan B? I think the next step will
>>>>>>> be, once again, to gather some performance metrics, so maybe that will
>>>>>>> help us decide.
>>>>>>
>>>>>> FWIW I agree that using page lock for protecting page pinning (and thus
>>>>>> avoid races with page_mkclean()) looks simpler to me as well and I'm not
>>>>>> convinced there will be measurable difference to the more complex scheme
>>>>>> with barriers Jerome suggests unless that page lock contended. Jerome is
>>>>>> right that you cannot just do lock_page() in gup_fast() path. There you
>>>>>> have to do trylock_page() and if that fails just bail out to the slow gup
>>>>>> path.
>>>>>>
>>>>>> Regarding places other than page_mkclean() that need to check pinned state:
>>>>>> Definitely page migration will want to check whether the page is pinned or
>>>>>> not so that it can deal differently with short-term page references vs
>>>>>> longer-term pins.
>>>>>>
>>>>>> Also there is one more idea I had how to record number of pins in the page:
>>>>>>
>>>>>> #define PAGE_PIN_BIAS	1024
>>>>>>
>>>>>> get_page_pin()
>>>>>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>>>>>
>>>>>> put_page_pin();
>>>>>> 	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>>>>>>
>>>>>> page_pinned(page)
>>>>>> 	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS
>>>>>>
>>>>>> This is pretty trivial scheme. It still gives us 22-bits for page pins
>>>>>> which should be plenty (but we should check for that and bail with error if
>>>>>> it would overflow). Also there will be no false negatives and false
>>>>>> positives only if there are more than 1024 non-page-table references to the
>>>>>> page which I expect to be rare (we might want to also subtract
>>>>>> hpage_nr_pages() for radix tree references to avoid excessive false
>>>>>> positives for huge pages although at this point I don't think they would
>>>>>> matter). Thoughts?
>>>>>
>>>>> Racing PUP are as likely to cause issues:
>>>>>
>>>>> CPU0                        | CPU1       | CPU2
>>>>>                             |            |
>>>>>                             | PUP()      |
>>>>>     page_pinned(page)       |            |
>>>>>       (page_count(page) -   |            |
>>>>>        page_mapcount(page)) |            |
>>>>>                             |            | GUP()
>>>>>
>>>>> So here the refcount snap-shot does not include the second GUP and
>>>>> we can have a false negative ie the page_pinned() will return false
>>>>> because of the PUP happening just before on CPU1 despite the racing
>>>>> GUP on CPU2 just after.
>>>>>
>>>>> I believe only either lock or memory ordering with barrier can
>>>>> guarantee that we do not miss GUP ie no false negative. Still the
>>>>> bias idea might be usefull as with it we should not need a flag.
>>>>
>>>> Right. We need similar synchronization (i.e., page lock or careful checks
>>>> with memory barriers) if we want to get a reliable page pin information.
>>>>
>>>>> So to make the above safe it would still need the page write back
>>>>> double check that i described so that GUP back-off if it raced with
>>>>> page_mkclean,clear_page_dirty_for_io and the fs write page call back
>>>>> which call test_set_page_writeback() (yes it is very unlikely but
>>>>> might still happen).
>>>>
>>>> Agreed. So with page lock it would actually look like:
>>>>
>>>> get_page_pin()
>>>> 	lock_page(page);
>>>> 	wait_for_stable_page();
>>>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>>> 	unlock_page(page);
>>>>
>>>> And if we perform page_pinned() check under page lock, then if
>>>> page_pinned() returned false, we are sure page is not and will not be
>>>> pinned until we drop the page lock (and also until page writeback is
>>>> completed if needed).
>>>>
>>
>> OK. Avoiding a new page flag, *and* avoiding the _mapcount auditing and
>> compensation steps, is a pretty major selling point. And if we do the above
>> locking, that does look correct to me. I wasn't able to visualize the
>> locking you had in mind, until just now (above), but now it is clear, 
>> thanks for spelling it out.
>>
>>>
>>> So i still can't see anything wrong with that idea, i had similar
>>> one in the past and diss-missed and i can't remember why :( But
>>> thinking over and over i do not see any issue beside refcount wrap
>>> around. Which is something that can happens today thought i don't
>>> think it can be use in an evil way and we can catch it and be
>>> loud about it.
>>>
>>> So i think the following would be bullet proof:
>>>
>>>
>>> get_page_pin()
>>>     atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>>     smp_wmb();
>>>     if (PageWriteback(page)) {
>>>         // back off
>>>         atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>>>         // re-enable preempt if in fast
>>>         wait_on_page_writeback(page);
>>>         goto retry;
>>>     }
>>>
>>> put_page_pin();
>>> 	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>>>
>>> page_pinned(page)
>>> 	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS
>>>
>>> test_set_page_writeback()
>>>     ...
>>>     wb = TestSetPageWriteback(page)
>>
>> Minor point, but using PageWriteback for synchronization may rule out using
>> wait_for_stable_page(), because wait_for_stable_page() might not actually 
>> wait_on_page_writeback. Jan pointed out in the other thread, that we should
>> prefer wait_for_stable_page(). 
> 
> Yes, but wait_for_stable_page() has no page flag so nothing we can
> synchronize against. So my advice would be:
>     if (PageWriteback(page)) {
>         wait_for_stable_page(page);
>         if (PageWriteback(page))
>             wait_for_write_back(page);
>     }
> 
> wait_for_stable_page() can optimize out the wait_for_write_back()
> if it is safe to do so. So we can improve the above slightly too.
> 
>>
>>>     smp_mb();
>>>     if (page_pinned(page)) {
>>>         // report page as pinned to caller of test_set_page_writeback()
>>>     }
>>>     ...
>>>
>>> This is text book memory barrier. Either get_page_pin() see racing
>>> test_set_page_writeback() or test_set_page_writeback() see racing GUP
>>>
>>>
>>
>> This approach is probably workable, but again, it's more complex and comes
>> without any lockdep support. Maybe it's faster, maybe not. Therefore, I want 
>> to use it as either "do this after everything is up and running and stable", 
>> or else as Plan B, if there is some performance implication from the page lock.
>>
>> Simple and correct first, then performance optimization, *if* necessary.
> 
> I do not like taking page lock while they are no good reasons to do so.

There actually are very good reasons to do so! These include:

1) Simpler code that is less likely to have subtle bugs in the initial 
   implementations.

2) Pre-existing, known locking constructs that include instrumentation and
   visibility.

3) ...and all of the other goodness that comes from smaller and simpler code.

I'm not saying that those reasons necessarily prevail here, but it's not
fair to say "there are no good reasons". Less code is still worth something,
even in the kernel.

> The above is textbook memory barrier as explain in Documentations/
> Forcing page lock for GUP will inevitably slow down some workload and

Such as?

Here's the thing: if a workload is taking the page lock for some
reason, and also competing with GUP, that's actually something that I worry
about: what is changing in page state, while we're setting up GUP? Either
we audit for that, or we let runtime locking rules (taking the page lock)
keep us out of trouble in the first place.

In other words, if there is a performance hit, it might very likely be
due to a required synchronization that is taking place.

> report for such can takes time to trickle down to mailing list and it
> can takes time for people to actualy figure out that this are the GUP
> changes that introduce such regression.
> 
> So if we could minimize performance regression with something like
> memory barrier we should definitly do that.

We do not yet know that the more complex memory barrier approach is actually
faster. That's worth repeating.

> 
> Also i do not think that page lock has lock dep (as it is not using
> any of the usual locking function) but that's just my memory of that
> code.
> 

Lock page is pretty thoroughly instrumented. It uses wait_on_page_bit_common(),
which in turn uses spin locks and more.

The more I think about this, the more I want actual performance data to 
justify anything involving the more complicated custom locking. So I think
it's best to build the page lock based version, do some benchmarks, and see
where we stand.


thanks,
-- 
John Hubbard
NVIDIA

