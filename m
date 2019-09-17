Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C877C4CECE
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 16:21:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F5D520665
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 16:21:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="IPKfWlnk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F5D520665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 978696B0006; Tue, 17 Sep 2019 12:21:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9509B6B0008; Tue, 17 Sep 2019 12:21:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8655F6B000A; Tue, 17 Sep 2019 12:21:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id 66E056B0006
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 12:21:48 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E492D348D
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 16:21:47 +0000 (UTC)
X-FDA: 75944928654.19.fan99_2cba5cb4d0937
X-HE-Tag: fan99_2cba5cb4d0937
X-Filterd-Recvd-Size: 5901
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 16:21:47 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id f16so4610779qkl.9
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 09:21:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=7zcxfoeB93t2LFv4lA/iGGDzpuTwdsiMs4R0hCM94F0=;
        b=IPKfWlnk6g+8xYh6QPDOV11rgt8hSjZYNydSSMeCC5lKQ3BAPdYcMVFhqlL6/hwZ0L
         EpNpNap6RxUM7xANzt7U00kSQeknoPyQ0uViAZwm0bLghRCvcpjwrSukCB7LJP0jbqug
         AEambkcgJO2Rxl/j3spzefDlO8/yGcnoM6b3xgAltN01rOEE6NQh4V3K1/Vx98YKkQOu
         BrnCaimHtq85qpZJuiNfl/zuqz/jg+n6ZacxHKeAFoTQdf6eXO07ENRaIErUPzEcfZvG
         6VqeXfW7mFmajNBrjUD4+IoP3kIZdGCGAI9/IPGQK/9dVx4ArRCNMufP0PkHULbLyK6g
         Vglw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=7zcxfoeB93t2LFv4lA/iGGDzpuTwdsiMs4R0hCM94F0=;
        b=PFYy40dT+HfxNWWW7B1NWmKe5cRRk4sPd0m9Bq38g+TLL1o4+NIiU2yQwIjWjZ+nrh
         nvuANl6t31GoVqePmrAKTPF7CpGQQRxI+bGabjVTGaQSleui4pp0kJZyAvup3q3yqs6k
         SXqhHeLt5sW95t52Oyrqbb4oN4/KH4Q6uDxG8kGd89x6PJV4VHuNAlzHhE3FNbjhKuXg
         RmCF7iZMkJkeizLG4N/v76/sFV6woxbUm6vWe6zah6mgjpIX3drBqYFwc8mpsB4+dY5S
         oNEgA+uOmmPAMzYBD38+83vJdYt7WA0HRk0e0wsZ8MCpWrdBQ6LmEbNHsFKK5wocLKsG
         5fpA==
X-Gm-Message-State: APjAAAUhVSsRk6YlsPbnen5x9Ieo8PJ8Z7Q1zvTd3SviiA1yUoxF2d/n
	Q7AR2rZ9d2RDypjnyeHjHwkIhA==
X-Google-Smtp-Source: APXvYqwb/MFu85JM4GcuDSGF0uOmP1Zyl45W9YDIPitIpFmqcKkM4HZhLZjsrcEi4qbiBF9otNjRKQ==
X-Received: by 2002:a05:620a:1458:: with SMTP id i24mr4660603qkl.361.1568737306585;
        Tue, 17 Sep 2019 09:21:46 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id b16sm1824587qtk.65.2019.09.17.09.21.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Sep 2019 09:21:45 -0700 (PDT)
Message-ID: <1568737304.5576.162.camel@lca.pw>
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
From: Qian Cai <cai@lca.pw>
To: Waiman Long <longman@redhat.com>, David Hildenbrand <david@redhat.com>, 
 Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"akpm@linux-foundation.org"
	 <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, 
	"adobriyan@gmail.com"
	 <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>, "sfr@canb.auug.org.au"
	 <sfr@canb.auug.org.au>, "mst@redhat.com" <mst@redhat.com>, Naoya Horiguchi
	 <n-horiguchi@ah.jp.nec.com>, Junichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 17 Sep 2019 12:21:44 -0400
In-Reply-To: <59c946f8-843d-c017-f342-d007a5e14a85@redhat.com>
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
	 <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com>
	 <e762ee45-43e3-975a-ad19-065f07d1440f@vx.jp.nec.com>
	 <40a1ce2e-1384-b869-97d0-7195b5b47de0@redhat.com>
	 <6a99e003-e1ab-b9e8-7b25-bc5605ab0eb2@vx.jp.nec.com>
	 <e4e54258-e83b-cf0b-b66e-9874be6b5122@redhat.com>
	 <31fd3c86-5852-1863-93bd-8df9da9f95b4@vx.jp.nec.com>
	 <38e58d23-c20b-4e68-5f56-20bba2be2d6c@redhat.com>
	 <59c946f8-843d-c017-f342-d007a5e14a85@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-17 at 11:49 -0400, Waiman Long wrote:
> On 9/17/19 3:13 AM, David Hildenbrand wrote:
> > On 17.09.19 04:34, Toshiki Fukasawa wrote:
> > > On 2019/09/09 16:46, David Hildenbrand wrote:
> > > > Let's take a step back here to understand the issues I am aware of. I
> > > > think we should solve this for good now:
> > > > 
> > > > A PFN walker takes a look at a random PFN at a random point in time. It
> > > > finds a PFN with SECTION_MARKED_PRESENT && !SECTION_IS_ONLINE. The
> > > > options are:
> > > > 
> > > > 1. It is buddy memory (add_memory()) that has not been online yet. The
> > > > memmap contains garbage. Don't access.
> > > > 
> > > > 2. It is ZONE_DEVICE memory with a valid memmap. Access it.
> > > > 
> > > > 3. It is ZONE_DEVICE memory with an invalid memmap, because the section
> > > > is only partially present: E.g., device starts at offset 64MB within a
> > > > section or the device ends at offset 64MB within a section. Don't access it.
> > > 
> > > I don't agree with case #3. In the case, struct page area is not allocated on
> > > ZONE_DEVICE, but is allocated on system memory. So I think we can access the
> > > struct pages. What do you mean "invalid memmap"?
> > 
> > No, that's not the case. There is no memory, especially not system
> > memory. We only allow partially present sections (sub-section memory
> > hotplug) for ZONE_DEVICE.
> > 
> > invalid memmap == memmap was not initialized == struct pages contains
> > garbage. There is a memmap, but accessing it (e.g., pfn_to_nid()) will
> > trigger a BUG.
> > 
> 
> As long as the page structures exist, they should be initialized to some
> known state. We could set PagePoison for those invalid memmap. It is the

Sounds like you want to run page_init_poison() by default.


> garbage that are in those page structures that can cause problem if a
> struct page walker scan those pages and try to make sense of it.


