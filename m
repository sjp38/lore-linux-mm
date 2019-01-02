Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51A1FC43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 12:22:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA4DB2171F
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 12:22:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA4DB2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5539C8E0020; Wed,  2 Jan 2019 07:22:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52A968E0002; Wed,  2 Jan 2019 07:22:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 440B78E0020; Wed,  2 Jan 2019 07:22:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18DEC8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 07:22:06 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id b18so22342671oii.1
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 04:22:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=xLLA6VmVJuYqiEd4W8zWFL6IR3l25ZB6XUM+IMTJ0Y4=;
        b=ebTct0JcXa0KctJh0ocYmH0AMTc3YpcyvtYpB0AIrhHY9WzgWlVvy2MbCIMEMdMJPt
         CODNOEEuoXGhm7MDvnuYrWOIKwn42ol3E432hIC/eGW6qoEu+HaPajCnLZHxUOoOAsPN
         7rWO/GsDrYoK1bZ5QTBGyHQQ24dTrYidSpoqII2O1cUOM5fUOKFrc4om3IVWX76REDQL
         0CAocno109fqlL3mjVBS1cj/NQe7UmH33cC2O4Ezu5sG/3xT8PiTprWnBoAfAdXiUseO
         qwuYgV0NKshBtbmJWMkBdiVEcQgNXx6nM9KBeyDcPkhcvYgJJVvmIIEz0uDNkm4qkfdq
         D/9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AJcUukfFZH/8mltKbA0o5IfPDRdHumcxZOuGNcJ1Zdk2mYjnNvST6/FU
	tFFQmD5tl7ot8NAUpZ3KusjH3/tu5AxH2HIlcOEGrlC4bR5vO9JAmCViOS3MwAkgH+vl4y7mT1k
	vdyUB3UUcx/6LJB8msqBu2QoUWMKujI2gBrvzWc6limQPgwwvwjT3oigPNgh0rLzDZQ==
X-Received: by 2002:aca:ea84:: with SMTP id i126mr27818910oih.84.1546431725748;
        Wed, 02 Jan 2019 04:22:05 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XR5KnCOiI6MuWv8GTCZb/4dUjJ4RKlXevjRY8Ye7Ii3tyXIahn7DxNvu77ivxwFRjB9WNA
X-Received: by 2002:aca:ea84:: with SMTP id i126mr27818874oih.84.1546431724448;
        Wed, 02 Jan 2019 04:22:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546431724; cv=none;
        d=google.com; s=arc-20160816;
        b=WHEZTmop6Npndm0ptTrWHmSCaqtxKRHbqMQxOsnoRSYZotGjzpBDX1uWAryh/vJBT6
         JK2fvRU0J4sJ2J9/D+BvqJVkLAA91CAzWgUwsRK5yQg2lpAsh5NaOo8yzXkM3lW/Mk9H
         BRMf2c9MzcTM7+G40aVNJdnRi+UEQXAAMvmT+XADWQ7LrrNjEellyZETeV19MauV/xdg
         /5WdP107fbUz/bfkx2ZaTu70dzIAO0vZkxxTmaA2323J8FKbkHhuPk2k4DtAaIjCmMbn
         KYWM9r2ZWZElXTsK5iVJyDaluKZN9UPRa2HYwPwAlxWyW7Psax7XbCFnuZ0hS5PU6QNc
         3EiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=xLLA6VmVJuYqiEd4W8zWFL6IR3l25ZB6XUM+IMTJ0Y4=;
        b=tJIplVhrFWF0l8z+5qWubm/0JvMx11XVlB0zjZ9DKWz7V7CmpPZ8qxWxvNjjXUMsTd
         5iogL3gf5oINsPN2UMgcFpYUC1fZ6ujup5YwWPmVJp2mqxE+S6lSmgPDG2i/iZ26OC/u
         Q5Iq22P8YMX9FNAnFjN9f3/W7qJh6+wtrYFgR8gte9edDUojBLqYkzpqgtppGFp8MoGB
         Bdwtuh12CLBaBpKiqcbU42tEO/EBMPGDlz64CD2uSMJB6UaES2myZ+AEpnEgva4T65mY
         c/tyNZvOe1EzFqof1Wnu4hXHoagtopyAyPJaNBCyyflb4gqISgy01Fu2JqsM1bhgdOYM
         c9FA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id i9si24195303oth.116.2019.01.02.04.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 04:22:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 6F89F76F7D252;
	Wed,  2 Jan 2019 20:21:30 +0800 (CST)
Received: from localhost (10.202.226.46) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.408.0; Wed, 2 Jan 2019
 20:21:25 +0800
Date: Wed, 2 Jan 2019 12:21:10 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Fengguang Wu <fengguang.wu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	<kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>,
	Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>,
	Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"Mel  Gorman" <mgorman@suse.de>,
	Andrea Arcangeli <aarcange@redhat.com>,
	<linux-accelerators@lists.ozlabs.org>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190102122110.00000206@huawei.com>
In-Reply-To: <20181228195224.GY16738@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
	<20181227203158.GO16738@dhcp22.suse.cz>
	<20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
	<20181228084105.GQ16738@dhcp22.suse.cz>
	<20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
	<20181228121515.GS16738@dhcp22.suse.cz>
	<20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
	<20181228195224.GY16738@dhcp22.suse.cz>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.46]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102122110.lh-xv9i-xHWvvhi32KSjbs9k3yWWjgFoDYhoSgrjecE@z>

On Fri, 28 Dec 2018 20:52:24 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> [Ccing Mel and Andrea]
> 
> On Fri 28-12-18 21:31:11, Wu Fengguang wrote:
> > > > > I haven't looked at the implementation yet but if you are proposing a
> > > > > special cased zone lists then this is something CDM (Coherent Device
> > > > > Memory) was trying to do two years ago and there was quite some
> > > > > skepticism in the approach.  
> > > > 
> > > > It looks we are pretty different than CDM. :)
> > > > We creating new NUMA nodes rather than CDM's new ZONE.
> > > > The zonelists modification is just to make PMEM nodes more separated.  
> > > 
> > > Yes, this is exactly what CDM was after. Have a zone which is not
> > > reachable without explicit request AFAIR. So no, I do not think you are
> > > too different, you just use a different terminology ;)  
> > 
> > Got it. OK.. The fall back zonelists patch does need more thoughts.
> > 
> > In long term POV, Linux should be prepared for multi-level memory.
> > Then there will arise the need to "allocate from this level memory".
> > So it looks good to have separated zonelists for each level of memory.  
> 
> Well, I do not have a good answer for you here. We do not have good
> experiences with those systems, I am afraid. NUMA is with us for more
> than a decade yet our APIs are coarse to say the least and broken at so
> many times as well. Starting a new API just based on PMEM sounds like a
> ticket to another disaster to me.
> 
> I would like to see solid arguments why the current model of numa nodes
> with fallback in distances order cannot be used for those new
> technologies in the beginning and develop something better based on our
> experiences that we gain on the way.
> 
> I would be especially interested about a possibility of the memory
> migration idea during a memory pressure and relying on numa balancing to
> resort the locality on demand rather than hiding certain NUMA nodes or
> zones from the allocator and expose them only to the userspace.

This is indeed a very interesting direction.  I'm coming at this from a CCIX
point of view.  Ignore the next bit of you are already familiar with CCIX :)

Main thing CCIX brings is that memory can be fully coherent
anywhere in the system including out near accelerators, all via shared physical
address space, leveraging ATS / IOMMUs / MMUs to do translations. Result is a
big and possibly extremely heterogenous NUMA system.  All the setup is done in
firmware so by the time the kernel sees it everything is in SRAT / SLIT
/ NFIT / HMAT etc.

We have a few usecases that need some more fine grained control combined with
automated balancing.  So far we've been messing with nasty tricks like
hotplugging memory after boot a long way away, or the original CDM zone patches
(knowing they weren't likely to go anywhere!)  Userspace is all hand tuned
which is not great in the long run...

Use cases (I've probably missed some):

* Storage Class Memory near to the host CPU / DRAM controllers (pretty much
  the same as this series is considering).  Note that there isn't necessarily
  any 'pairing' with host DRAM as seen in this RFC.  A typical system might have
  a large single pool with similar access characteristics from each host SOC.
  The paired approach is probably going to be common in early systems though.
  Also not necessarily Non Volatile, could just be a big DDR expansion board.

* RAM out near an accelerator. Aim would be to migrate data to that RAM if
  the access patterns from the accelerator justify it being there rather than
  near any of the host CPUs.  In a memory pressure on host situation anything
  could be pushed out there as probably still better than swapping.
  Note that this would require some knowledge of 'who' is doing the accessing
  which isn't needed for what this RFC is doing.

* Hot pages may not be hot just because the host is using them a lot.  It would be
  very useful to have a means of adding information available from accelerators
  beyond simple accessed bits (dreaming ;)  One problem here is translation
  caches (ATCs) as they won't normally result in any updates to the page accessed
  bits.  The arm SMMU v3 spec for example makes it clear (though it's kind of
  obvious) that the ATS request is the only opportunity to update the accessed
  bit.  The nasty option here would be to periodically flush the ATC to force
  the access bit updates via repeats of the ATS request (ouch).
  That option only works if the iommu supports updating the accessed flag
  (optional on SMMU v3 for example).

We need the explicit placement, but can get that from existing NUMA controls.
More of a concern is persuading the kernel it really doesn't want to put
it's data structures in distant memory as it can be very very distant.

So ideally I'd love this set to head in a direction that helps me tick off
at least some of the above usecases and hopefully have some visibility on
how to address the others moving forwards,

Good to see some new thoughts in this area!

Jonathan
> 
> > On the other hand, there will also be page allocations that don't care
> > about the exact memory level. So it looks reasonable to expect
> > different kind of fallback zonelists that can be selected by NUMA policy.
> > 
> > Thanks,
> > Fengguang  
> 


