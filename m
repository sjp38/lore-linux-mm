Return-Path: <SRS0=vc3H=PU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD5A3C43444
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 02:38:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 851EE2184B
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 02:38:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="M0jEqp3y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 851EE2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F10868E0002; Fri, 11 Jan 2019 21:38:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBE6B8E0001; Fri, 11 Jan 2019 21:38:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB9B98E0002; Fri, 11 Jan 2019 21:38:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAAC18E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 21:38:49 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id e14so3608619ybf.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 18:38:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Cs6UTVT1m7o+6bOFBmASgtpU5xNAVif1KVmjIOVij+E=;
        b=IRG6hlqPL9ICJlBflyEbsm63BCirWDLTUqPuB2YX6fxdLbeyXoWqH/wGZIyfflb+G0
         zlgFyhwLt847bnxRwl1xQdhVa34vgm2QmHYOwCJOEAZrEmIaRKXRkbQ8bkBTuDk/E3vJ
         GTn4AHPyMalhdgnfqkz3R14i70K4j9UfoF4Qr2lBagnIouYGzqEgrHsj5kft86vC4K5N
         SiWuuaI8YQfonseZSq0cG4E+IaIM1R6d9xW5Pcd2v/yQF46VHlAxyvuyMjiHMkxFfcY1
         BJJmbX2AfxQaN83bXiaCYnPp82FNFfiOncZS+Hef5qR4LQwL4No9y/li9pKmr/lzzjT9
         5wLQ==
X-Gm-Message-State: AJcUukc3OourKhA5vZC7jzVZAdrzgOntnyDexNZRdOtHa0OapnOZ3TXI
	ox86pj7CQgAQFhFYYIealpXoHd4/A7iqHShEZiB+MwuFrmS6giYaxpJoRtJ/0U+bwUocuXXxi6u
	+JG0zETJ9Il+b/54MmCNY94AD+ZOFdEErIW9UU29F9/rZG4P3zXKKw4ygPahgdAaRDQ==
X-Received: by 2002:a25:dfc4:: with SMTP id w187mr4289193ybg.231.1547260728304;
        Fri, 11 Jan 2019 18:38:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Z3sx5TP0tGc4YcwzwyiGBA+KMB0NgNEVT4v/TYADyMELyjkDb+rSha+Wx9fJYIBCcaFPH
X-Received: by 2002:a25:dfc4:: with SMTP id w187mr4289168ybg.231.1547260727165;
        Fri, 11 Jan 2019 18:38:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547260727; cv=none;
        d=google.com; s=arc-20160816;
        b=pbI8NL1EHMBH7NaPMhGNLE5w4uY7tA5qCNzyQ8gC/o8B3HgsDekxqSy9PM2g5/QdkP
         Jutth8pVJUapylSBQZC0a7ye/CvIXozgYleq0rURqF2t5t8WEYzo+OkcaYERvrxTseo8
         ZeAbBNgIaFY3MfHjcmSmAX5uHW6JecmOEeiGOJJeTyd+hB9W+8hEYrtuDStRCF0zB2Ya
         N2cPteiBtka0+oLTZRmvkMVk7otGkbGcFYE2fA7wLGGFpDzlDepdQdQLQ3uPAtdYEHXD
         ox4cG1qQ8IIC/4nznSYIqhUc/jpwf1DxIlzNdQ+gRnlJjQ+IIH/cROz5N+L37RxlUKS9
         fxzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Cs6UTVT1m7o+6bOFBmASgtpU5xNAVif1KVmjIOVij+E=;
        b=An176FxwlmUMHrJD5uw0kxUra/9M9VIp8AcdB7S2ybPt0f6pF9cALRP54td/3t2TZJ
         /2e0ak0r9kMiDnCEkWomQNofBitR3XPOQ25LVDZyJmXCD8AyqDYqgdRDi4WoJoZCxved
         367xWqLR26kylQPx4SlFsCLBkaCIMRsJXYqePSfNmOax72YHsjbbCyUqCuBhLlaL8Jns
         pr6R3a11DYjXEIfysX98+r4r83OQNB8AI4maLUdiLbW9dOeiIbJtHw7aXdODtmEwARul
         BVKOsER8hs6pw72tdxDUQJCwokKCPEaDfJvQUgy+mYBKoQ33OdeOXEYd7q8gQzFB2mO0
         0Dbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=M0jEqp3y;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 203si48109564ywo.294.2019.01.11.18.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 18:38:47 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=M0jEqp3y;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c39531b0000>; Fri, 11 Jan 2019 18:38:19 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 11 Jan 2019 18:38:45 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 11 Jan 2019 18:38:45 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Sat, 12 Jan
 2019 02:38:45 +0000
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
References: <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com> <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com> <20190103092654.GA31370@quack2.suse.cz>
 <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
Date: Fri, 11 Jan 2019 18:38:44 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190112020228.GA5059@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547260699; bh=Cs6UTVT1m7o+6bOFBmASgtpU5xNAVif1KVmjIOVij+E=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=M0jEqp3y0XQVIuLsrOY2R9adxqLiVXXsRkWwD0AeQVpNllYKUC6XkUssO6HCZeKV1
	 0CyILvjaJJRZ/dioIg5DUQBJtrd0rmt6rmxfupIowOTqLNgMQXrjpVP0yosUqvcMXg
	 tA0j2u9SvZVZpeU902MyL5+0chDqoHbd3oQ92IFQaOXGaRZZ1hvjJg1l6rdkRQkwh3
	 g0KSOvf5VdUyCETv7paDAPhYQhAZtoP7r5O444kVutJ7Crn79JMHwxh6J2nzC+LBKM
	 Zn/RfDaDVoEKjrmXNRsMeQtWN6MFjSusgIx0VdEpQJeGIN1rnc8bSq3ws+iY/glzpL
	 R3j+EqjVw6uxA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190112023844.W2pw30A9914YHFhi3EsPalMaa-SYcuDIUcLo2WCCIdI@z>

On 1/11/19 6:02 PM, Jerome Glisse wrote:
> On Fri, Jan 11, 2019 at 05:04:05PM -0800, John Hubbard wrote:
>> On 1/11/19 8:51 AM, Jerome Glisse wrote:
>>> On Thu, Jan 10, 2019 at 06:59:31PM -0800, John Hubbard wrote:
>>>> On 1/3/19 6:44 AM, Jerome Glisse wrote:
>>>>> On Thu, Jan 03, 2019 at 10:26:54AM +0100, Jan Kara wrote:
>>>>>> On Wed 02-01-19 20:55:33, Jerome Glisse wrote:
>>>>>>> On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
>>>>>>>> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
>>>>>>>>> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
>>> [...]
>>
>> Hi Jerome,
>>
>> Looks good, in a conceptual sense. Let me do a brain dump of how I see it,
>> in case anyone spots a disastrous conceptual error (such as the lock_page
>> point), while I'm putting together the revised patchset.
>>
>> I've studied this carefully, and I agree that using mapcount in 
>> this way is viable, *as long* as we use a lock (or a construct that looks just 
>> like one: your "memory barrier, check, retry" is really just a lock) in
>> order to hold off gup() while page_mkclean() is in progress. In other words,
>> nothing that increments mapcount may proceed while page_mkclean() is running.
> 
> No, increment to page->_mapcount are fine while page_mkclean() is running.
> The above solution do work no matter what happens thanks to the memory
> barrier. By clearing the pin flag first and reading the page->_mapcount
> after (and doing the reverse in GUP) we know that a racing GUP will either
> have its pin page clear but the incremented mapcount taken into account by
> page_mkclean() or page_mkclean() will miss the incremented mapcount but
> it will also no clear the pin flag set concurrently by any GUP.
> 
> Here are all the possible time line:
> [T1]:
> GUP on CPU0                      | page_mkclean() on CPU1
>                                  |
> [G2] atomic_inc(&page->mapcount) |
> [G3] smp_wmb();                  |
> [G4] SetPagePin(page);           |
>                                 ...
>                                  | [C1] pined = TestClearPagePin(page);

It appears that you're using the "page pin is clear" to indicate that
page_mkclean() is running. The problem is, that approach leads to toggling
the PagePin flag, and so an observer (other than gup or page_mkclean) will
see intervals during which the PagePin flag is clear, when conceptually it
should be set.

Jan and other FS people, is it definitely the case that we only have to take
action (defer, wait, revoke, etc) for gup-pinned pages, in page_mkclean()?
Because I recall from earlier experiments that there were several places, not 
just page_mkclean().

One more quick question below...

>                                  | [C2] smp_mb();
>                                  | [C3] map_and_pin_count =
>                                  |        atomic_read(&page->mapcount)
> 
> It is fine because page_mkclean() will read the correct page->mapcount
> which include the GUP that happens before [C1]
> 
> 
> [T2]:
> GUP on CPU0                      | page_mkclean() on CPU1
>                                  |
>                                  | [C1] pined = TestClearPagePin(page);
>                                  | [C2] smp_mb();
>                                  | [C3] map_and_pin_count =
>                                  |        atomic_read(&page->mapcount)
>                                 ...
> [G2] atomic_inc(&page->mapcount) |
> [G3] smp_wmb();                  |
> [G4] SetPagePin(page);           |
> 
> It is fine because [G4] set the pin flag so it does not matter that [C3]
> did miss the mapcount increase from the GUP.
> 
> 
> [T3]:
> GUP on CPU0                      | page_mkclean() on CPU1
> [G4] SetPagePin(page);           | [C1] pined = TestClearPagePin(page);
> 
> No matter which CPU ordering we get ie either:
>     - [G4] is overwritten by [C1] in that case [C3] will see the mapcount
>       that was incremented by [G2] so we will map_count < map_and_pin_count
>       and we will set the pin flag again at the end of page_mkclean()
>     - [C1] is overwritten by [G4] in that case the pin flag is set and thus
>       it does not matter that [C3] also see the mapcount that was incremented
>       by [G2]
> 
> 
> This is totaly race free ie at the end of page_mkclean() the pin flag will
> be set for all page that are pin and for some page that are no longer pin.
> What matter is that they are no false negative.
> 
> 
>> I especially am intrigued by your idea about a fuzzy count that allows
>> false positives but no false negatives. To do that, we need to put a hard
>> lock protecting the increment operation, but we can be loose (no lock) on
>> decrement. That turns out to be a perfect match for the problem here, because
>> as I recall from my earlier efforts, put_user_page() must *not* take locks--
>> and that's where we just decrement. Sweet! See below.
> 
> You do not need lock, lock are easier to think with but they are not always
> necessary and in this case we do not need any lock. We can happily have any
> number of concurrent GUP, PUP or pte zapping. Worse case is false positive
> ie reporting a page as pin while it has just been unpin concurrently by a
> PUP.
> 
>> The other idea that you and Dan (and maybe others) pointed out was a debug
>> option, which we'll certainly need in order to safely convert all the call
>> sites. (Mirror the mappings at a different kernel offset, so that put_page()
>> and put_user_page() can verify that the right call was made.)  That will be
>> a separate patchset, as you recommended.
>>
>> I'll even go as far as recommending the page lock itself. I realize that this 
>> adds overhead to gup(), but we *must* hold off page_mkclean(), and I believe
>> that this (below) has similar overhead to the notes above--but is *much* easier
>> to verify correct. (If the page lock is unacceptable due to being so widely used,
>> then I'd recommend using another page bit to do the same thing.)
> 
> Please page lock is pointless and it will not work for GUP fast. The above
> scheme do work and is fine. I spend the day again thinking about all memory
> ordering and i do not see any issues.
> 

Why is it that page lock cannot be used for gup fast, btw?

> 
>> (Note that memory barriers will simply be built into the various Set|Clear|Read
>> operations, as is common with a few other page flags.)
>>
>> page_mkclean():
>> ===============
>> lock_page()
>>     page_mkclean()
>>         Count actual mappings
>>             if(mappings == atomic_read(&page->_mapcount))
>>                 ClearPageDmaPinned 
>>
>> gup_fast():
>> ===========
>> for each page {
>>     lock_page() /* gup MUST NOT proceed until page_mkclean and writeback finish */
>>
>>     atomic_inc(&page->_mapcount)
>>     SetPageDmaPinned()
>>
>>     /* details of gup vs gup_fast not shown here... */
>>
>>
>> put_user_page():
>> ================
>>     atomic_dec(&page->_mapcount); /* no locking! */
>>    
>>
>> try_to_unmap() and other consumers of the PageDmaPinned flag:
>> =============================================================
>> lock_page() /* not required, but already done by existing callers */
>>     if(PageDmaPinned) {
>>         ...take appropriate action /* future patchsets */
> 
> We can not block try_to_unmap() on pined page. What we want to block is
> fs using a different page for the same file offset the original pined
> page was pin (modulo truncate that we should not block). Everything else
> must keep working as if there was no pin. We can not fix that, driver
> doing long term GUP and not abiding to mmu notifier are hopelessly broken
> in front of many regular syscall (mremap, truncate, splice, ...) we can
> not block those syscall or failing them, doing so would mean breaking
> applications in a bad way.
> 
> The only thing we should do is avoid fs corruption and bug due to
> dirtying page after fs believe it has been clean.
> 
> 
>> page freeing:
>> ============
>> ClearPageDmaPinned() /* It may not have ever had page_mkclean() run on it */
> 
> Yeah this need to happen when we sanitize flags of free page.
> 


thanks,
-- 
John Hubbard
NVIDIA

