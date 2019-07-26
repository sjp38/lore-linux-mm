Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 464E3C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:11:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 125B7229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:11:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 125B7229F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A269F6B0003; Fri, 26 Jul 2019 06:11:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AED46B0005; Fri, 26 Jul 2019 06:11:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 877FD8E0002; Fri, 26 Jul 2019 06:11:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA746B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:11:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so33809745edr.13
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:11:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3mUbzPn3v1wYU/lFRDR2NcphYlTAt4oilMtMauvvm5c=;
        b=MdkNw0rrl1qMdwckv1zvKXjPlZCOAEsNbze3oYn1iUJI+WD191k6v66vYHZwaOIEHl
         IhMM5bVHH1SqiJRRZoyshdqOa3SJUiTxhW3wZjsb1Z720jwO10zKhPu0HWr3m7VZaHck
         khUVLwU28xuJxInp+V8qbxDT2Q5a8UIV4Uu2JXtn7CR6ipNgWI8IbctNbY6Nh0+hWidE
         /8AjzsmWQ0kr2rgmMWQhINv1bLtRBqqoIwEG50omm3piRCkK+NJM6Jiiu8oVMWF9hhJu
         MIuCMvZ54Mqd17ghQgCj8l6l3cHTBh8xjK02VV52aCXgsd2K61Yr/Yb8BU+JlZalTNMZ
         qLxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAV25G1c03ewt7APP1CDIyRQDxb4V4SyvqMvN0QJGXn9NU+j6fAh
	TaREXFGBoLLvoZNi7cIXBl1+x7uw4TUeWhdDnVEiIbRtqpo7X6u4oJkCJAkrmrc/Rf9Qa4nwe/9
	jXKfH3uK5Ekz3gr0gSlmKy6mk7vPAqX6pJvDG4gLoPyyvKRGQms2NVdnaqIzdaTHOHg==
X-Received: by 2002:a50:d2d3:: with SMTP id q19mr81268589edg.64.1564135904756;
        Fri, 26 Jul 2019 03:11:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUui18OFPdYX18BVW5wQKSCSDtynWF20LXq56JXfCXAeuoc8dF16VF/iQW1hMD9NdYV9hF
X-Received: by 2002:a50:d2d3:: with SMTP id q19mr81268503edg.64.1564135903939;
        Fri, 26 Jul 2019 03:11:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564135903; cv=none;
        d=google.com; s=arc-20160816;
        b=dfee/Qg65TOvbyPvQecH4IqwSJ12selz7zJPbzkfX+6yzaCm0d7AFMlebOyN3JtCdu
         rN174VZnSBpoyQTfjSVAhNhVqGYgJS3f4zRn01UomGjAOriT1tR32o/dncj9+IB5ZhA2
         oh0IAX5HY2kvIgavJcvPFGqkNWLaJj+3oC1lXtzPprhh/x4KpsZcaGtPwbFosDL7N7Zz
         46JqJ8vLTxdsejkQAeDjc93c3G1i7nYygb9w6siPkNt8WneNMKN7OcMfrdgfAy2TuI5o
         0Zf93m0WR6yY33YbG31XEchCeZJDkGdtlxk4yZjJ4FcWyvBTeZL6oU2kfbrvJ0bZypZw
         VKEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3mUbzPn3v1wYU/lFRDR2NcphYlTAt4oilMtMauvvm5c=;
        b=fAFxDKTSDl9JeBvOHJdib4WdQRp/KIdgKvo1g/nkiEJ8n858Rpfee1bHuDLXQxpBG/
         rHtsVZ3li6L1lc2hndQm/rkUBj48nVuwjoYOI2of6QDO4v27m7JoPKlokP+EbVx5DtHN
         pVW1LV4GPWWIsLGZgihwkYZ2ByaTevGrxqnRsS5gY6fXGWz8e5Va3HA137xfzeoO89Gr
         LQJf7Ym6kPmzfBucRIgaIt5DjFZKH16T2ThKaYAmm4DhhkJkSDfQivq6IvvKLq4lYzoh
         RA0SX9HJa/H8p8XJAe1ppMMVZcrx8MYetuJ3mEbYQj8/F+aGrtVyyQoFFVSxPWcsBPtG
         L7/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8si11210893ejq.134.2019.07.26.03.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 03:11:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 79544B634;
	Fri, 26 Jul 2019 10:11:43 +0000 (UTC)
Date: Fri, 26 Jul 2019 12:11:40 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, mhocko@suse.com,
	anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com,
	vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 2/5] mm: Introduce a new Vmemmap page-type
Message-ID: <20190726101136.GA26721@linux>
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-3-osalvador@suse.de>
 <7e8746ac-6a66-d73c-9f2a-4fc53c7e4c04@redhat.com>
 <20190726092548.GA26268@linux>
 <dbd19aea-fe18-ec42-7932-f03109cb399e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dbd19aea-fe18-ec42-7932-f03109cb399e@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 11:41:46AM +0200, David Hildenbrand wrote:
> > static void __meminit __init_single_page(struct page *page, unsigned long pfn,
> >                                 unsigned long zone, int nid)
> > {
> >         if (PageVmemmap(page))
> >                 /*
> >                  * Vmemmap pages need to preserve their state.
> >                  */
> >                 goto preserve_state;
> 
> Can you be sure there are no false positives? (if I remember correctly,
> this memory might be completely uninitialized - I might be wrong)

Normal pages reaching this point will be uninitialized or 
poisoned-initialized.

Vmemmap pages are initialized to 0 in mhp_mark_vmemmap_pages,
before reaching here.

For the false positive to be effective, page should be reserved, and 
page->type would have to have a specific value.
If we feel unsure about this, I could add a new kind of check for only
this situation, where we initialize another field of struct page
to another specific/magic value, so we will have three checks only at
this stage.

> 
> > 
> >         mm_zero_struct_page(page);
> >         page_mapcount_reset(page);
> >         INIT_LIST_HEAD(&page->lru);
> > preserve_state:
> >         init_page_count(page);
> >         set_page_links(page, zone, nid, pfn);
> >         page_cpupid_reset_last(page);
> >         page_kasan_tag_reset(page);
> > 
> > So, vmemmap pages will fall within the same zone as the range we are adding,
> > that does not change.
> 
> I wonder if that is the right thing to do, hmmmm, because they are
> effectively not part of that zone (not online)
> 
> Will have a look at the details :)

I might be wrong here, but last time I checked, pages that are used for memmaps
at boot time (not hotplugged), are still linked to some zone.

Will have to double check though.

If that is not case, it would be easier, but I am afraid it is.


-- 
Oscar Salvador
SUSE L3

