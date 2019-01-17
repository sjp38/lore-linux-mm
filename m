Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 362D2C43444
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 05:42:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3B7F205C9
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 05:42:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="IAz39Aah"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3B7F205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DE9E8E0003; Thu, 17 Jan 2019 00:42:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 663DE8E0002; Thu, 17 Jan 2019 00:42:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 504768E0003; Thu, 17 Jan 2019 00:42:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE4B8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 00:42:29 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id x14so4603524ywg.18
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 21:42:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jH/ZGeaaJ5XJcRXyximypMM2MYauuEjkZL8HoWgkj+s=;
        b=IXNlR5oWqDxcFjZejhw98KIzLI/5Kph1WdVOUUV4PTWPvpEf8zCQJeWwD7E2k5yEc4
         7lw0p+tStUlVRS2sH9mqYmUi5QbkrhlqO+SZ/16lkr5Xjpv3R6CWY9PnrVyHw8+GDqQs
         5RhnaFGCIfSHKukw77F1onX+uUaxTI83DazYbgSJB8Drb3VeyHLNFPANR4Vih3Jdjvme
         vuySO5US8fj/m6gZqaZmxgkjPT7mqHQjVNCFCNDP/TxogBwy7M9zEdGSllY9DRL7h6dg
         CY9Quy2v/YzZGkd2qKI+X3PltjcNbcfTvaFIGrIdKQYwPAwcpxoO3PbiPIIwfxFWrERr
         AgqQ==
X-Gm-Message-State: AJcUukdaKLkFVSFkqma0cUrfXq0m3WvnZY5BGiWcJ3iU/N50K4S00Yph
	tZgdGxbW9rDokpdye0SlmKHFGUhYIJR2janFMGKu8BjGmCzQz6xx6+9A1m/6CPhf8qt6FnQfsXB
	qrX/3dM9r10lCKhgczUsPW3/LGaCnCD0aKL01OfB/RrUxkis8NSeHhVupt/rW/vn7Aw==
X-Received: by 2002:a81:6c90:: with SMTP id h138mr11741978ywc.379.1547703748709;
        Wed, 16 Jan 2019 21:42:28 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4KrqeNuGfvl79WD5ySmnsiAYujxQarGrnhFtiR/Z3wiTgZOJrB/hbBrwHb639r1Www2J6X
X-Received: by 2002:a81:6c90:: with SMTP id h138mr11741918ywc.379.1547703747676;
        Wed, 16 Jan 2019 21:42:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547703747; cv=none;
        d=google.com; s=arc-20160816;
        b=MmdwWi3O6uXZiVpcjLjtCLvB0sR6MP9j2ZHwGew8YnP+kMIV5fkVb+PwiLv1e22lhR
         3gsqBcQtIFlroN7K5BkYGpePSz+DcDtI8OZJEBwpMy8eoamY3swrGlIU1oodBmdDY1F0
         CdPsSNW5+qtl95IejxA/vz9tqczPwChuJsA86Rbglk4fKIZi1EmQ1A4VOMWM/YIOkMgq
         hgee66rrSwF2sXXxYJRJ0EMJ4+8lbkCkzy7Ate5rKcS6o7L+KqLjGySWTwKWebK4X6sG
         HBiKq7tOTIPukzuMs53Y4jPnHFmJVCw2Qau9Bah58lnuwdcwIx+XhyJ0XIK5tOE+8DXX
         g/cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jH/ZGeaaJ5XJcRXyximypMM2MYauuEjkZL8HoWgkj+s=;
        b=Dgrot/xkXR7j199FTv/sTEwFfFRjjnJjtELprfJkvZsKFK4PI+985nNABi9LfkaWYn
         mAtUwkzzo9mfRjOWROL5q8E6dVSxRJO/pxWMd6COxIGr5Fhtd8um8AaiOCr9P9+0r9fg
         BjwZp03LKePf0I9AuaareZM8j2+wz8/eA2R7MdccUVuZnjDkwEgngmr1UkNAAheGdPNG
         RhBl5GtWJ7cTIExtzCQ8qutyiB0tVRoDDrYhIGoM3tbnIMu0r2qDh6O9vI7sxhmMBBrR
         T+1Gy/NrTS+iRKtN1A+VqBl9+k+0GfAe+yrinVKwhQsf1/vmSoPxQd6JdeiQC+QA/rC8
         flMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IAz39Aah;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id y1si696855ywe.310.2019.01.16.21.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 21:42:27 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IAz39Aah;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c4015b30000>; Wed, 16 Jan 2019 21:42:11 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 16 Jan 2019 21:42:26 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 16 Jan 2019 21:42:26 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 17 Jan
 2019 05:42:26 +0000
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
References: <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
 <20190116113819.GD26069@quack2.suse.cz> <20190116130813.GA3617@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <5c6dc6ed-4c8d-bce7-df02-ee8b7785b265@nvidia.com>
Date: Wed, 16 Jan 2019 21:42:25 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190116130813.GA3617@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547703731; bh=jH/ZGeaaJ5XJcRXyximypMM2MYauuEjkZL8HoWgkj+s=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=IAz39AahdVndTLswehanCPLtg27jr5a/mEiXImIIMtCDMj7otnpd8Ph8dQ6mSfyGl
	 dYNy3lnBcH+ip9WsiWHfZlE1TVBW6oiPCp/Sdy+2UEqLwOlMscmEbtBec6jBvU+aT2
	 uUkkCA4bIfcxwmbhFud8yVoF6x1mQDbbL6hqHHgsulGQ33ZLzT7NB4dAX5J4d72KZo
	 3Zm12c0kmP0W1lVQHHK6N8ixjdyy77aXfydqvBYcPK+v020VBvuG5+y6wNw2dlzawP
	 ZrHKQyIGfzr0CIjoi3EubednUc0Rxwb1tZelDVepZjFpD47rW8ZQ1bQ/+5lT3ZAyO+
	 mHoc0hh68v1Bw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117054225.E3tc3aiB0Yd9GkHCBuGrpLvqvoIvZ9sJHjI1WDu3iIY@z>

On 1/16/19 5:08 AM, Jerome Glisse wrote:
> On Wed, Jan 16, 2019 at 12:38:19PM +0100, Jan Kara wrote:
>> On Tue 15-01-19 09:07:59, Jan Kara wrote:
>>> Agreed. So with page lock it would actually look like:
>>>
>>> get_page_pin()
>>> 	lock_page(page);
>>> 	wait_for_stable_page();
>>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>> 	unlock_page(page);
>>>
>>> And if we perform page_pinned() check under page lock, then if
>>> page_pinned() returned false, we are sure page is not and will not be
>>> pinned until we drop the page lock (and also until page writeback is
>>> completed if needed).
>>
>> After some more though, why do we even need wait_for_stable_page() and
>> lock_page() in get_page_pin()?
>>
>> During writepage page_mkclean() will write protect all page tables. So
>> there can be no new writeable GUP pins until we unlock the page as all such
>> GUPs will have to first go through fault and ->page_mkwrite() handler. And
>> that will wait on page lock and do wait_for_stable_page() for us anyway.
>> Am I just confused?
> 
> Yeah with page lock it should synchronize on the pte but you still
> need to check for writeback iirc the page is unlocked after file
> system has queue up the write and thus the page can be unlock with
> write back pending (and PageWriteback() == trye) and i am not sure
> that in that states we can safely let anyone write to that page. I
> am assuming that in some case the block device also expect stable
> page content (RAID stuff).
> 
> So the PageWriteback() test is not only for racing page_mkclean()/
> test_set_page_writeback() and GUP but also for pending write back.


That was how I thought it worked too: page_mkclean and a few other things
like page migration take the page lock, but writeback takes the lock, 
queues it up, then drops the lock, and writeback actually happens outside
that lock. 

So on the GUP end, some combination of taking the page lock, and 
wait_on_page_writeback(), is required in order to flush out the writebacks.
I think I just rephrased what Jerome said, actually. :)


> 
> 
>> That actually touches on another question I wanted to get opinions on. GUP
>> can be for read and GUP can be for write (that is one of GUP flags).
>> Filesystems with page cache generally have issues only with GUP for write
>> as it can currently corrupt data, unexpectedly dirty page etc.. DAX & memory
>> hotplug have issues with both (DAX cannot truncate page pinned in any way,
>> memory hotplug will just loop in kernel until the page gets unpinned). So
>> we probably want to track both types of GUP pins and page-cache based
>> filesystems will take the hit even if they don't have to for read-pins?
> 
> Yes the distinction between read and write would be nice. With the map
> count solution you can only increment the mapcount for GUP(write=true).
> With pin bias the issue is that a big number of read pin can trigger
> false positive ie you would do:
>     GUP(vaddr, write)
>         ...
>         if (write)
>             atomic_add(page->refcount, PAGE_PIN_BIAS)
>         else
>             atomic_inc(page->refcount)
> 
>     PUP(page, write)
>         if (write)
>             atomic_add(page->refcount, -PAGE_PIN_BIAS)
>         else
>             atomic_dec(page->refcount)
> 
> I am guessing false positive because of too many read GUP is ok as
> it should be unlikely and when it happens then we take the hit.
> 

I'm also intrigued by the point that read-only GUP is harmless, and we 
could just focus on the writeable case.

However, I'm rather worried about actually attempting it, because remember
that so far, each call site does no special tracking of each struct page. 
It just remembers that it needs to do a put_page(), not whether or
not that particular page was set up with writeable or read-only GUP. I mean,
sure, they often call set_page_dirty before put_page, indicating that it might
have been a writeable GUP call, but it seems sketchy to rely on that.

So actually doing this could go from merely lots of work, to K*(lots_of_work)...


thanks,
-- 
John Hubbard
NVIDIA

