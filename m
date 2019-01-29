Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7340C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 06:41:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62CCC2147A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 06:41:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="SolxkOvm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62CCC2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAA908E0002; Tue, 29 Jan 2019 01:41:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E30EB8E0001; Tue, 29 Jan 2019 01:41:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD2398E0002; Tue, 29 Jan 2019 01:41:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 966DF8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:41:44 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id k1so9601839ybm.8
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 22:41:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:subject:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=gO8xtSlfltsMyHP+HxKsOoC/46e8mR5LyjQT1eimLrA=;
        b=TZFJedkz30nKoLZI8HEUncxL0jSv6ZMXWlgQNWnfo5edVYJMOs+rX9hnepNtu+h+0F
         k+42NkLfW3Fpp4mYMntrcuxV7TMo+0nCivllrj7eI4GI1QqhgW355P9j+ac1hnCUJ4do
         SnrU2Ea5EgHb/mZ6OxnQxlCfg4Pzkwhr4gMKAOjCvS5ZqDMHHC4eY3U9Dp+nGCrxjLhy
         xF2bir++rWZdGbPAeFnsB2nfwNlVt6eTHhATdprs8FeYBHwsb1sVh6AllJghwx9jlda2
         ejE8Ztoj7wG3TKwBFNFpnpmxDC6BBvltR5BfOPwFq1O7p2yC6g3clcZiMa6o6hu0vR+2
         YIHA==
X-Gm-Message-State: AJcUukePDVcX6zut76eRiwT97EhxyohlDc6oDUaXeAHZ1lxBLvPaVogQ
	31wgy5hMdnQwKJsF/jnt6pIXQ1Ca8SdSXVZudbD1Jh9riqBPLIUBKz4kHef3LgHbc8viTDDTPzU
	jcKsQYYrBhHnwwuhLW5V4qogwZggOCrBWqnu8H0tDBqTizhgVmYHnT0TykHsvbrU37A==
X-Received: by 2002:a25:881:: with SMTP id 123mr24747511ybi.319.1548744104094;
        Mon, 28 Jan 2019 22:41:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6GpBuVBm5MgDq8zbQ7M4tYgGReE1iUWXjj3MAFtKYLKQnBg2MZDlezxZGEW4tXIhAhEGav
X-Received: by 2002:a25:881:: with SMTP id 123mr24747471ybi.319.1548744102915;
        Mon, 28 Jan 2019 22:41:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548744102; cv=none;
        d=google.com; s=arc-20160816;
        b=hr3W8a+YSqAtOK1dhrUe5n5KRuAfV35eLnSgV29GGwQHYumrepS3J8ufbTP3NxSePp
         0Jr6fEAlqYqbDLh5n9Wydiw8oOJO+7hdPDMln7X8T8z+siIrQ28pz9oZIdh7B8ULcNFQ
         pLNX8wc9vdunnUEG/elZBLsZCikAzvfXjuYqlrVC7888ftgoQmH2Yz9BaIUnncV6u0Zx
         KF3W3TKgiMVn7LK5YfHgLJZVf6ksfKh1GwrzlAUYgl+Ls3ief05c7FWqQDM9q8Tlyl/o
         t07dnjqWOIZm6XPJvbzDups8YBCPNTgMCoiZtzsDo6ttdpwl21zrswmzxjLEaFCUTePi
         pQSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:subject:from;
        bh=gO8xtSlfltsMyHP+HxKsOoC/46e8mR5LyjQT1eimLrA=;
        b=V4Qo9bvRFtr7s8MJ9Y6bu0O0i1xUL/Cg5/a3w6cJOX/g/EWupLnakbmWahc+QGiR9D
         +WJqp2Yq7yG0TPPDG82z66JRWxjZAoAJ9Y+QHodcZfsYdSoTOGCv73AzFICF6JGgobeA
         r0ysxFfZx8BX33h3Ytui8cx8x7BYEIYQqP9g+1YzESsqoFJC4QntluznkFbtFCtDgebR
         T47FpOLHJK4G2Q5GIEhDuVc9OFqapUwJuTRnQh/0w1oUE5pwk1nj9IcVrqN0PCBaw4b3
         CDfKJbD24DyOzTCgoq746nG1GKLCx60xTkgOEWeH2yKBXOePfuxFV1iNHJE1sBYq6TzR
         gQvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SolxkOvm;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 124si20563263ybu.234.2019.01.28.22.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 22:41:42 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SolxkOvm;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c4ff57e0000>; Mon, 28 Jan 2019 22:41:02 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 28 Jan 2019 22:41:41 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 28 Jan 2019 22:41:41 -0800
Received: from [10.2.167.94] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Tue, 29 Jan
 2019 06:41:40 +0000
From: John Hubbard <jhubbard@nvidia.com>
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
References: <20190115080759.GC29524@quack2.suse.cz>
 <20190116113819.GD26069@quack2.suse.cz> <20190116130813.GA3617@redhat.com>
 <20190117093047.GB9378@quack2.suse.cz> <20190117151759.GA3550@redhat.com>
 <20190122152459.GG13149@quack2.suse.cz> <20190122164613.GA3188@redhat.com>
 <20190123180230.GN13149@quack2.suse.cz> <20190123190409.GF3097@redhat.com>
 <8492163b-8c50-6ea2-8bc9-8c445495ecb4@nvidia.com>
 <20190129012312.GB3359@redhat.com>
X-Nvconfidentiality: public
Message-ID: <3c3bb2a3-907b-819d-83ee-2b29802a5bda@nvidia.com>
Date: Mon, 28 Jan 2019 22:41:41 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129012312.GB3359@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548744062; bh=gO8xtSlfltsMyHP+HxKsOoC/46e8mR5LyjQT1eimLrA=;
	h=X-PGP-Universal:From:Subject:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=SolxkOvmoPa5b7qq4aqNiFw1GMNfaoK+DJaUnq4Z4SkU2ZFgbDxd6FA1W6UveW4dk
	 WowTMALhSGobvLzYos3Rj6ZWgtEeHTVkVckn0S0ETjiXb0bvEzBZGyLqy+dzTUZUVm
	 2AU3pfkjB4sX0b2M7CONqaDVpnrNQ2tKhdWF25Qg+micsC3WtFBf4+dqTgTNuvDlZf
	 9at4C9ZOXJe9s3R6dHPRngfL1V9dHodvDG1+c1pcq3VUpO2hhmYPrJD5XVj1kJy325
	 S4GpgAm0ou7XR2bgojC5Ig6D5rNCftkdo42Ygpp08DAGXttLpBX1l5lG7C9CqtGGY1
	 Dt4h54kq7w1Zg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/28/19 5:23 PM, Jerome Glisse wrote:
> On Mon, Jan 28, 2019 at 04:22:16PM -0800, John Hubbard wrote:
>> On 1/23/19 11:04 AM, Jerome Glisse wrote:
>>> On Wed, Jan 23, 2019 at 07:02:30PM +0100, Jan Kara wrote:
>>>> On Tue 22-01-19 11:46:13, Jerome Glisse wrote:
>>>>> On Tue, Jan 22, 2019 at 04:24:59PM +0100, Jan Kara wrote:
>>>>>> On Thu 17-01-19 10:17:59, Jerome Glisse wrote:
>>>>>>> On Thu, Jan 17, 2019 at 10:30:47AM +0100, Jan Kara wrote:
>>>>>>>> On Wed 16-01-19 08:08:14, Jerome Glisse wrote:
>>>>>>>>> On Wed, Jan 16, 2019 at 12:38:19PM +0100, Jan Kara wrote:
>>>>>>>>>> On Tue 15-01-19 09:07:59, Jan Kara wrote:
>>>>>>>>>>> Agreed. So with page lock it would actually look like:
>>>>>>>>>>>
>>>>>>>>>>> get_page_pin()
>>>>>>>>>>> 	lock_page(page);
>>>>>>>>>>> 	wait_for_stable_page();
>>>>>>>>>>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>>>>>>>>>> 	unlock_page(page);
>>>>>>>>>>>
>>>>>>>>>>> And if we perform page_pinned() check under page lock, then if
>>>>>>>>>>> page_pinned() returned false, we are sure page is not and will not be
>>>>>>>>>>> pinned until we drop the page lock (and also until page writeback is
>>>>>>>>>>> completed if needed).
>>>>>>>>>>
>>>>>>>>>> After some more though, why do we even need wait_for_stable_page() and
>>>>>>>>>> lock_page() in get_page_pin()?
>>>>>>>>>>
>>>>>>>>>> During writepage page_mkclean() will write protect all page tables. So
>>>>>>>>>> there can be no new writeable GUP pins until we unlock the page as all such
>>>>>>>>>> GUPs will have to first go through fault and ->page_mkwrite() handler. And
>>>>>>>>>> that will wait on page lock and do wait_for_stable_page() for us anyway.
>>>>>>>>>> Am I just confused?
>>>>>>>>>
>>>>>>>>> Yeah with page lock it should synchronize on the pte but you still
>>>>>>>>> need to check for writeback iirc the page is unlocked after file
>>>>>>>>> system has queue up the write and thus the page can be unlock with
>>>>>>>>> write back pending (and PageWriteback() == trye) and i am not sure
>>>>>>>>> that in that states we can safely let anyone write to that page. I
>>>>>>>>> am assuming that in some case the block device also expect stable
>>>>>>>>> page content (RAID stuff).
>>>>>>>>>
>>>>>>>>> So the PageWriteback() test is not only for racing page_mkclean()/
>>>>>>>>> test_set_page_writeback() and GUP but also for pending write back.
>>>>>>>>
>>>>>>>> But this is prevented by wait_for_stable_page() that is already present in
>>>>>>>> ->page_mkwrite() handlers. Look:
>>>>>>>>
>>>>>>>> ->writepage()
>>>>>>>>    /* Page is locked here */
>>>>>>>>    clear_page_dirty_for_io(page)
>>>>>>>>      page_mkclean(page)
>>>>>>>>        -> page tables get writeprotected
>>>>>>>>      /* The following line will be added by our patches */
>>>>>>>>      if (page_pinned(page)) -> bounce
>>>>>>>>      TestClearPageDirty(page)
>>>>>>>>    set_page_writeback(page);
>>>>>>>>    unlock_page(page);
>>>>>>>>    ...submit_io...
>>>>>>>>
>>>>>>>> IRQ
>>>>>>>>    - IO completion
>>>>>>>>    end_page_writeback()
>>>>>>>>
>>>>>>>> So if GUP happens before page_mkclean() writeprotects corresponding PTE
>>>>>>>> (and these two actions are synchronized on the PTE lock), page_pinned()
>>>>>>>> will see the increment and report the page as pinned.
>>>>>>>>
>>>>>>>> If GUP happens after page_mkclean() writeprotects corresponding PTE, it
>>>>>>>> will fault:
>>>>>>>>    handle_mm_fault()
>>>>>>>>      do_wp_page()
>>>>>>>>        wp_page_shared()
>>>>>>>>          do_page_mkwrite()
>>>>>>>>            ->page_mkwrite() - that is block_page_mkwrite() or
>>>>>>>> 	    iomap_page_mkwrite() or whatever filesystem provides
>>>>>>>> 	  lock_page(page)
>>>>>>>>            ... prepare page ...
>>>>>>>> 	  wait_for_stable_page(page) -> this blocks until IO completes
>>>>>>>> 	    if someone cares about pages not being modified while under IO.
>>>>>>>
>>>>>>> The case i am worried is GUP see pte with write flag set but has not
>>>>>>> lock the page yet (GUP is get pte first, then pte to page then lock
>>>>>>> page), then it locks the page but the lock page can make it wait for a
>>>>>>> racing page_mkclean()...write back that have not yet write protected
>>>>>>> the pte the GUP just read. So by the time GUP has the page locked the
>>>>>>> pte it read might no longer have the write flag set. Hence why you need
>>>>>>> to also check for write back after taking the page lock. Alternatively
>>>>>>> you could recheck the pte after a successful try_lock on the page.
>>>>>>
>>>>>> This isn't really possible. GUP does:
>>>>>>
>>>>>> get_user_pages()
>>>>>> ...
>>>>>>    follow_page_mask()
>>>>>>    ...
>>>>>>      follow_page_pte()
>>>>>>        ptep = pte_offset_map_lock()
>>>>>>        check permissions and page sanity
>>>>>>        if (flags & FOLL_GET)
>>>>>>          get_page(page); -> this would become
>>>>>> 	  atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>>>>>        pte_unmap_unlock(ptep, ptl);
>>>>>>
>>>>>> page_mkclean() on the other hand grabs the same pte lock to change the pte
>>>>>> to write-protected. So after page_mkclean() has modified the PTE we are
>>>>>> racing on for access, we are sure to either see increased _refcount or get
>>>>>> page fault from GUP.
>>>>>>
>>>>>> If we see increased _refcount, we bounce the page and are fine. If GUP
>>>>>> faults, we will wait for page lock (so wait until page is prepared for IO
>>>>>> and has PageWriteback set) while handling the fault, then enter
>>>>>> ->page_mkwrite, which will do wait_for_stable_page() -> wait for
>>>>>> outstanding writeback to complete.
>>>>>>
>>>>>> So I still conclude - no need for page lock in the GUP path at all AFAICT.
>>>>>> In fact we rely on the very same page fault vs page writeback synchronization
>>>>>> for normal user faults as well. And normal user mmap access is even nastier
>>>>>> than GUP access because the CPU reads page tables without taking PTE lock.
>>>>>
>>>>> For the "slow" GUP path you are right you do not need a lock as the
>>>>> page table lock give you the ordering. For the GUP fast path you
>>>>> would either need the lock or the memory barrier with the test for
>>>>> page write back.
>>>>>
>>>>> Maybe an easier thing is to convert GUP fast to try to take the page
>>>>> table lock if it fails taking the page table lock then we fall back
>>>>> to slow GUP path. Otherwise then we have the same garantee as the slow
>>>>> path.
>>>>
>>>> You're right I was looking at the wrong place for GUP_fast() path. But I
>>>> still don't think anything special (i.e. page lock or new barrier) is
>>>> necessary. GUP_fast() takes care already now that it cannot race with page
>>>> unmapping or write-protection (as there are other places in MM that rely on
>>>> this). Look, gup_pte_range() has:
>>>>
>>>>                  if (!page_cache_get_speculative(head))
>>>>                          goto pte_unmap;
>>>>
>>>>                  if (unlikely(pte_val(pte) != pte_val(*ptep))) {
>>>>                          put_page(head);
>>>>                          goto pte_unmap;
>>>>                  }
>>>>
>>>> So that page_cache_get_speculative() will become
>>>> page_cache_pin_speculative() to increment refcount by PAGE_PIN_BIAS instead
>>>> of 1. That is atomic ordered operation so it cannot be reordered with the
>>>> following check that PTE stayed same. So once page_mkclean() write-protects
>>>> PTE, there can be no new pins from GUP_fast() and we are sure all
>>>> succeeding pins are visible in page->_refcount after page_mkclean()
>>>> completes. Again this is nothing new, other mm code already relies on
>>>> either seeing page->_refcount incremented or GUP fast bailing out (e.g. DAX
>>>> relies on this). Although strictly speaking I'm not 100% sure what prevents
>>>> page->_refcount load to be speculatively reordered before PTE update even
>>>> in current places using this but there's so much stuff inbetween that
>>>> there's probably something ;). But we could add smp_rmb() after
>>>> page_mkclean() before changing page_pinned() for the peace of mind I guess.
>>>
>>> Yeah i think you are right, i missed the check on same pte value
>>> and the atomic inc in page_cache_get_speculative() is a barrier.
>>> I do not think the barrier would be necessary as page_mkclean is
>>> taking and dropping locks so those should have enough barriering.
>>>
>>
>> Hi Jan, Jerome,
>>
>> OK, this seems to be up and running locally, but while putting together
>> documentation and polishing up things, I noticed that there is one last piece
>> that I don't quite understand, after all. The page_cache_get_speculative()
>> existing documentation explains how refcount synchronizes these things, but I
>> don't see how that helps with synchronization page_mkclean and gup, in this
>> situation:
>>
>>      gup_fast gets the refcount and rechecks the pte hasn't changed
>>
>>      meanwhile, page_mkclean...wait, how does refcount come into play here?
>>      page_mkclean can remove the mapping and insert a write-protected pte,
>>      regardless of page refcount, correct?  Help? :)
> 
> Correct, page_mkclean() does not check the refcount and do not need to
> check it. We need to check for the page pin after the page_mkclean when
> code is done prepping the page for io (clear_page_dirty_for_io).
> 
> The race Jan and I were discussing was about wether we needed to lock
> the page or not and we do not. For slow path page_mkclean and GUP_slow
> will synchronize on the page table lock. For GUP_fast the fast code will
> back off if the pte is not the same and thus either we see the pin after
> page_mkclean() or GUP_fast back off. You will never have code that miss
> the pin after page_mkclean() and GUP_fast that did not back off.

Here is the case I'm wondering about:

thread A                             thread B
--------                             --------
                                      gup_fast
page_mkclean
     is page gup-pinned?(no)
                                          page_cache_get_speculative
                                              (gup-pins the page here)
                                          check pte_val unchanged (yes)
        set_pte_at()

...and now thread A has created a read-only PTE, after gup_fast walked
the page tables and found a writeable entry. And so far, thread A has
not seen that the page is pinned.

What am I missing here? The above seems like a problem even before we
change anything.

> 
> Now the page_cache_get_speculative() is for another race when a page is
> freed concurrently. page_cache_get_speculative() only inc the refcount
> if the page is not already freed ie refcount != 0. So GUP_fast has 2
> exclusions mechanisms, one for racing modification to the page table
> like page_mkclean (pte the same after incrementing the refcount) and one
> for racing put_page (only increment refcount if it is not 0). Here for
> what we want we just modify this second mechanisms to add the bias
> value not just 1 to the refcount. This keep both mechanisms intacts
> and give us the page pin test through refcount bias value.
> 
> Note that page_mkclean can not race with a put_page() as whoever calls
> page_mkclean already hold a reference on the page and thus no put_page
> can free the page.
> 
> Does that help ?

Yes...getting close... :)

thanks,
-- 
John Hubbard
NVIDIA

