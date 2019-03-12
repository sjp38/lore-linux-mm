Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94FEBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:40:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65AD52087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:40:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65AD52087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 001768E0003; Tue, 12 Mar 2019 13:40:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF3A88E0002; Tue, 12 Mar 2019 13:39:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE3458E0003; Tue, 12 Mar 2019 13:39:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 869528E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:39:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r7so1394769eds.18
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:39:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=tSxKfNlWGCn6xcsP5p+m1IoaY49tWAw1gqOGSpzlLZk=;
        b=SF5m/tf02x8/tRJgh/MZQIqjqJinxjzU1cPUTdmN85yvgHbXEzrS8JXhKT3orPEFkl
         lGIhyD+kXyXOksobpBOyeTnJUa5E7no7+dPb0D2RvG8xDdK+1RblfuYtLnfqv9ZpSbYD
         yAkMy/I2xKGcuBn4UejUYd5PK3CS/YeA3Bny0CaHhIwR+x5ITr0+vIX4r+u66joiPQA8
         p/rqneQlr8PIr/eU1n7kyy7KwrVna41yOCU/qS17BOPPNr8E9nzSw5Gcq+0ALzn1jykv
         zm2S7Wrb+uD3LTLFM6zILOSPDg7z1Moj9xo6tQYNbduXJGeGz4xXo8wxak1AZ8wNadjK
         po1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of julien.grall@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.grall@arm.com
X-Gm-Message-State: APjAAAXneHyizsWSk2jGFQNg/9EdZK4zlhWXWx4KUytrvIuWEFmREEeW
	jlzuYJeaOFBf3Rrpf/7tIRHdyjb0Bnn03bC/PiSa3G7oIMwFXSgdEVfVYx7KKPbd1UNsJvrODDX
	IwGhoMdKwkyF4oUxdEZ2+0K+/uKxgo+EPIihX3naGyVC2i6ILk7A6YSUezR6HG804Lg==
X-Received: by 2002:a05:6402:164e:: with SMTP id s14mr4453009edx.151.1552412399103;
        Tue, 12 Mar 2019 10:39:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyu45/gV3ZSPKbGtgvay6YlTDmMURDKK+jzMF1pNt57h7RC1lJNnJOgGDV/zM2Vcz+Roxqm
X-Received: by 2002:a05:6402:164e:: with SMTP id s14mr4452969edx.151.1552412398224;
        Tue, 12 Mar 2019 10:39:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552412398; cv=none;
        d=google.com; s=arc-20160816;
        b=vbbrDPuFdQvqa2ALNB2diIzrYTvCC3GlZ2UoeqUH0sihas349XPhaNDxDd+cAqZ7cc
         LJ4gaOsku2y2VLz8c+fTHOjc881jupC06QPYd8QOZCZzBvTiqfvU8kYsqDGRLdoThpy7
         dEor2xv0a3kGQkeD6NYqR/UgGIGGUH+ranxjJ90B59Wkh5sVbCL1NCOOVncehz/QSGnl
         hlbco+61Z5UTIR4yZsb+r1FAp+fxXVI8KVV777abV/M4xTyh+Z68efTNXEBlFPwvTe7z
         u1OEBtw/2GVfWDv/AXTnxAvhlrRNrZDPEpGlPIF7I3gmLqr6wVY6ybnVh2c+dyP3djEI
         Navw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=tSxKfNlWGCn6xcsP5p+m1IoaY49tWAw1gqOGSpzlLZk=;
        b=ziQB7PFEWPxWvDncwwEUM0ETbPLR1LmLmL1kjoPVlmHeXEQ7HvDKdu7aHU3v0jf/Z1
         BuyWNULqrmoDgAWa/expc4JWgMzno1JWBauP6zfBC5AZhCercsV/mJTg/5n0kcr4DE6E
         YedWoKLHhEmpSN160q2spZECKvck1g4EG1bvIT+L9+iD0Es8ph0OEGcfpYZVdgzg9cpU
         MN9M2SlrBSsLkYtqB/nqV6m6Zq4P65Ql3zQpQuoW7SY68LsAy/P9tN2zG4dwhLczlW2k
         3F1hCna7BhNsqgsO0FGznz2DSD7GyC5qkVS9andAgDR6i27VNiAHP0npVe5h9sI8sM3O
         VcUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of julien.grall@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.grall@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u47si555614edm.14.2019.03.12.10.39.57
        for <linux-mm@kvack.org>;
        Tue, 12 Mar 2019 10:39:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of julien.grall@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of julien.grall@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=julien.grall@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F2EDDA78;
	Tue, 12 Mar 2019 10:39:56 -0700 (PDT)
Received: from [10.37.10.23] (unknown [10.37.10.23])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5C7C93F59C;
	Tue, 12 Mar 2019 10:39:52 -0700 (PDT)
Subject: Re: xen: Can't insert balloon page into VM userspace (WAS Re:
 [Xen-devel] [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: David Hildenbrand <david@redhat.com>, Matthew Wilcox <willy@infradead.org>
Cc: osstest service owner <osstest-admin@xenproject.org>,
 xen-devel@lists.xenproject.org, Juergen Gross <jgross@suse.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 Stefano Stabellini <sstabellini@kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Kees Cook <keescook@chromium.org>, k.khlebnikov@samsung.com,
 Julien Freche <jfreche@vmware.com>, Nadav Amit <namit@vmware.com>,
 "VMware, Inc." <pv-drivers@vmware.com>, linux-mm@kvack.org
References: <E1h3Uiq-0002L6-Ij@osstest.test-lab.xenproject.org>
 <80211e70-5f54-9421-8e8f-2a4fc758ce39@arm.com>
 <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
 <20190312171421.GJ19508@bombadil.infradead.org>
 <e0b64793-260d-5e70-0544-e7290509b605@redhat.com>
From: Julien Grall <julien.grall@arm.com>
Message-ID: <180a9edf-855e-6a29-5724-cc0f929de71c@arm.com>
Date: Tue, 12 Mar 2019 17:39:50 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <e0b64793-260d-5e70-0544-e7290509b605@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

On 3/12/19 5:18 PM, David Hildenbrand wrote:
> On 12.03.19 18:14, Matthew Wilcox wrote:
>> On Tue, Mar 12, 2019 at 05:05:39PM +0000, Julien Grall wrote:
>>> On 3/12/19 3:59 PM, Julien Grall wrote:
>>>> It looks like all the arm test for linus [1] and next [2] tree
>>>> are now failing. x86 seems to be mostly ok.
>>>>
>>>> The bisector fingered the following commit:
>>>>
>>>> commit 0ee930e6cafa048c1925893d0ca89918b2814f2c
>>>> Author: Matthew Wilcox <willy@infradead.org>
>>>> Date:   Tue Mar 5 15:46:06 2019 -0800
>>>>
>>>>       mm/memory.c: prevent mapping typed pages to userspace
>>>>       Pages which use page_type must never be mapped to userspace as it would
>>>>       destroy their page type.  Add an explicit check for this instead of
>>>>       assuming that kernel drivers always get this right.
>>
>> Oh good, it found a real problem.
>>
>>> It turns out the problem is because the balloon driver will call
>>> __SetPageOffline() on allocated page. Therefore the page has a type and
>>> vm_insert_pages will deny the insertion.
>>>
>>> My knowledge is quite limited in this area. So I am not sure how we can
>>> solve the problem.
>>>
>>> I would appreciate if someone could provide input of to fix the mapping.
>>
>> I don't know the balloon driver, so I don't know why it was doing this,
>> but what it was doing was Wrong and has been since 2014 with:
>>
>> commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
>> Author: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
>> Date:   Thu Oct 9 15:29:27 2014 -0700
>>
>>      mm/balloon_compaction: redesign ballooned pages management
>>
>> If ballooned pages are supposed to be mapped into userspace, you can't mark
>> them as ballooned pages using the mapcount field.
>>
> 
> Asking myself why anybody would want to map balloon inflated pages into
> user space (this just sounds plain wrong but my understanding to what
> XEN balloon driver does might be limited), but I assume the easy fix
> would be to revert

Balloon pages are used to map foreign guest pages. As backend PV drivers 
may live in userspace (e.g QEMU, Xenconsoled...) we need to be able to
to insert balloon pages in the VM.

> 
> 
> commit 2f085ff37d08ecbc7849d5abb9424bd7927dda1d

I guess you meant 77c4adf6a6df6f8f39807eaed48eb73d0eb4261e?

I have reverted the patch and can now access the guest console. Is there 
a way to keep this patch and at the same time mapping the page in the 
userspace?


> Author: David Hildenbrand <david@redhat.com>
> Date:   Wed Mar 6 11:42:24 2019 +1100
> 
>      xen/balloon: mark inflated pages PG_offline
> 
>      Mark inflated and never onlined pages PG_offline, to tell the world that
>      the content is stale and should not be dumped.
> 
> 

Cheers,

-- 
Julien Grall

