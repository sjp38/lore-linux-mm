Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B72E2C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:50:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E6D921473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:50:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E6D921473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 332E96B0008; Wed,  3 Apr 2019 04:50:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E3CB6B000A; Wed,  3 Apr 2019 04:50:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AD7F6B000C; Wed,  3 Apr 2019 04:50:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEA1F6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:50:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e55so7133426edd.6
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:50:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wgwgAvCEBXksNl7D3aTGuKTsBDGD3ky3ZbBbKOlrLAA=;
        b=P03+n68Gw1nclmnBi23s6NatxXRPzvqu18Ao1l+/STxiSpZn/y/vIbod96fbFX2c1F
         RZtCBynm6SGH7Fey5M7lA6NSlrPVZj+Xw3xLiXnWIJ3xaVxr70Ukr2Rwr6O+yeaDB5rK
         /uSLWc3LC2b8VkhjOHZAX6S09cGfDbMDUI+gYoWdEjstfY7oN7614FXtMMPYE0ykYWkc
         JYCsQ3VuzWo7khnDATl4wlV8eOEe+fBF0bjxvwHQ6SZRNyBSRdPAz0Gp5CL2Xzy1CiPx
         Ymn7D1m+zrhoZ1DU0Ri16Yzjr6kWnyBQ7muBXk+yURYuuIcu+mvEj14SaZBCVdL6KbhX
         WM3w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVe8usUm13NwiwTA9QX0RszKivE22V1b+yPdey63M9oZPNuDl64
	UE4x5QRayTeLn55rwuKYMqXCddcmqLIRcradsBk9tnPWW99+5xubOSPevzEjlmAEVru0nc7feP+
	gGGf67Ynnug5vyUKhjBWqMyLCtZ7ZK0t2ZSc2gzqsLbL3DhHKLIHS9g8ruujDel0=
X-Received: by 2002:a50:978e:: with SMTP id e14mr36996673edb.217.1554281444362;
        Wed, 03 Apr 2019 01:50:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqvLf6GIZXNr381kzw30CWkxzIw/taXt+/BxnKsEFO35k25I5wf8EzzOd1lWpnY0LRBQAg
X-Received: by 2002:a50:978e:: with SMTP id e14mr36996640edb.217.1554281443670;
        Wed, 03 Apr 2019 01:50:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554281443; cv=none;
        d=google.com; s=arc-20160816;
        b=b83RRYCnArAciSBC2TXuIRWf5XKsxNTuvdxAhQl9CSu1KVPyPDDCenCgq06uZg9W50
         uagYBy7Gjbx2b7UWcGEpEqJAITaYays8iqmMDCLzugiR/rhzNkp9TD0V2ncv0nlL7gde
         WZ5wIyqEFl4ud6+ngtVm+fOBsPjIsJPxs8u+D2FYj+Pfoy59qqppZax5MOtm8w0+4HtZ
         76vqdThcIjdTmoBDBpzTrJ6itqRyrMVPIyDMl02JoHPLPHr6Ag2E4FSScOz0BI4EuWu9
         Q1m6oW3DXjGpeK1Bq+R9wIZk0DaXlZnzDCaQ43bA8PjdsbFTA0VGjHNhXe8ikL0oCCJu
         ryRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wgwgAvCEBXksNl7D3aTGuKTsBDGD3ky3ZbBbKOlrLAA=;
        b=Rc7nWRsTUZfVjyIIBfxUclJzJKaePYk0u08i/PmpBaD1LWib7qv8wW9BDMokAjHCEA
         B992IlGf1GLOcpHvyOoYq7Jh83+WkCp0MNGDDiePXJ1IyjRoq07PCmH4adaJnIsbdxOh
         EfIKX8DZAEQm5jQbYN23/ogt726UPCRQ7WoQwG1vfwu7tbqSDGiMjeOar2O8hX/V1OVA
         jWKq52UQ7kQ9g476SUTMpRHKVvTEboXgyD7bboQImjMOpnGxbkLnGyuILKcngQ2t4QV7
         kF35uEoNWAC4qF9sWYMS20E6XolDvgTJmHudvG8LKCZFQlIVdFiyJtcIYWdA6Tnao+nL
         nB2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id y41si767523edd.326.2019.04.03.01.50.43
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 01:50:43 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id EE81C47ED; Wed,  3 Apr 2019 10:50:42 +0200 (CEST)
Date: Wed, 3 Apr 2019 10:50:42 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190403085042.t5wcyvaolxiw65rr@d104.suse.de>
References: <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
 <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
 <20190403083757.GC15605@dhcp22.suse.cz>
 <04a5b856-c8e0-937b-72bb-b9d17a12ccc7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04a5b856-c8e0-937b-72bb-b9d17a12ccc7@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 10:41:35AM +0200, David Hildenbrand wrote:
> > That being said it should be the caller of the hotplug code to tell
> > the vmemmap allocation strategy. For starter, I would only pack vmemmaps
> > for "regular" kernel zone memory. Movable zones should be more careful.
> > We can always re-evaluate later when there is a strong demand for huge
> > pages on movable zones but this is not the case now because those pages
> > are not really movable in practice.
> 
> Remains the issue with potential different user trying to remove memory
> it didn't add in some other granularity. We then really have to identify
> and isolate that case.

If we let the caller specify whether it wants vmemmaps per memblock or range,
I would trust that caller to do the correct thing and specify one thing or
another depending on what it wants to do in the future.

So, say a driver adds 512MB memory and it specifies that it wants vmemmaps per
memblock because later on it will like to hot-remove in chunks of 128MB.

-- 
Oscar Salvador
SUSE L3

