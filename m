Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBEE3C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:40:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77E0B2147A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:40:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77E0B2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA97A6B0008; Wed,  3 Apr 2019 05:40:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2E6C6B000A; Wed,  3 Apr 2019 05:40:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCFE16B000C; Wed,  3 Apr 2019 05:40:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90D896B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 05:40:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w27so7263616edb.13
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 02:40:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HYn3kuC+sFii9dUJ/5uLwygc2aQ1ptyfMz0wiWVCiFw=;
        b=FuQeP3Eh5yVs3PZkbOEQLyYsxKSIzUmfbMpvOsVUki+xN52tC6UC/Z+c1qf67L61a5
         Hl0YbaRYtag/vfdORM2n02T2WK55mI4IPAi9CDEJkudDSSSu5eZnLuD7OW5aeNojkJ5H
         ewpS0zTDmAFte7l4gybekpNkuy29YPA258Zsoe4M6k13C2hEjAvGvktCDpFQRm7RDKOI
         GwSYG25t+9CYnPx/3CcGSAX10mnElFJGdCi0AdzDR4mKZTAdsTairv7Ot36zyNGKE0GJ
         kaqqsxNzEEJMNU+nXQXuHUia7ZvnaKg1k8GoX3PfpT2CsNjxaP92D35hOfRKnagR9qjU
         q01A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVd2fchgU4HblmjY9109rD1gHC3x/uG7LlgWqjIKA5CytcxKEEW
	CJnuIuzg0gf4qvGHdYk7M5ZoZD8sQvYYvHRl+AWu1tkxoicWYwYFKbYxrLVnWMI7Kub5d1sGZrh
	q4oeM/uRQSGHJoRHo4eXuK8WLP2GgVYKedboggk5Gec2ff5GH/UA3SQUyWbC9Elk=
X-Received: by 2002:a50:b6f2:: with SMTP id f47mr51559167ede.240.1554284456183;
        Wed, 03 Apr 2019 02:40:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7OhEPl1QViAEkyAFmOGUKbfMjLSqxpFYpUwYFwEmwLJCyXh28jIXgtJay92Tp5+cHeeaO
X-Received: by 2002:a50:b6f2:: with SMTP id f47mr51559125ede.240.1554284455405;
        Wed, 03 Apr 2019 02:40:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554284455; cv=none;
        d=google.com; s=arc-20160816;
        b=SUTx3dzPNP9dsuxQa9OxFu/gK+DcBbL3S3REbsO7vQm65PuJI5Jnxah9vmRlIWculD
         /tMD8wNTCoglgdgDY7Cx2/53zMCC+IGLqJtbPIl0yVCNTI91babVDCRY4ZrzQierwwpQ
         8JciqtGTQ3mVb3I7TYXd6lt+g8OpWv0u1znTlFSaTcCSd9VJbrBJWiCLBOXuv/N4wFa8
         exvac3C5VhSUzZ1qgSGeZGZLPXS5JtOcskA18EBLMXIeu71th9fHS+HhO6/l/UgKyAQQ
         2aTMaPmaQPWAhVhdnGd5bYTZBBj+UHffv02axRCmMnHd4xy28Raz0a4KuuNYF0fyrtDZ
         Zptw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HYn3kuC+sFii9dUJ/5uLwygc2aQ1ptyfMz0wiWVCiFw=;
        b=G09Ijj07ye5evj7VCDnUKrJ8BKshsoYi6waFNs3PTX4y+i5aLtyi4tli7Pvvund7u+
         uwZoSBkZtscwUDT/+T00JaNWIoIqwcRmtFauC9eEwckW8Lb7zQA9je+PI2YQkCkXSukF
         d1OOvM3K954ZSHIau186vyqdkCvzlqni6YEQt8NRwAKvbB2C2vqWmKbgpEyqOYCWpHXY
         VysuJ5HEIJmMbzmICA1Oozt1/JQWWXaDyH7gKeWBRnF5E164u/rN/3Yw9kDkM/51vcua
         /uSoOsxZyi54XMvtlYOh1GhgbskYB5Ig999eF8a7y5oXCnlW0UXKA1oUSeJUhdS6+VAp
         dubw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id p10si2644208ejg.263.2019.04.03.02.40.55
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 02:40:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id A2A2647F0; Wed,  3 Apr 2019 11:40:54 +0200 (CEST)
Date: Wed, 3 Apr 2019 11:40:54 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190403094054.jdr7lxm45htgcsk7@d104.suse.de>
References: <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
 <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
 <20190403083757.GC15605@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403083757.GC15605@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 10:37:57AM +0200, Michal Hocko wrote:
> That being said it should be the caller of the hotplug code to tell
> the vmemmap allocation strategy. For starter, I would only pack vmemmaps
> for "regular" kernel zone memory. Movable zones should be more careful.
> We can always re-evaluate later when there is a strong demand for huge
> pages on movable zones but this is not the case now because those pages
> are not really movable in practice.

I agree that makes sense to let the caller specify if it wants to allocate
vmemmaps per memblock or per memory-range, so we are more flexible when it
comes to granularity in hot-add/hot-remove operations.

But the thing is that the zones are picked at onling stage, while
vmemmaps are created at hot-add stage, so I am not sure we can define
the strategy depending on the zone.

-- 
Oscar Salvador
SUSE L3

