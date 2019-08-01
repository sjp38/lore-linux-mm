Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E38E4C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:39:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A397C20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:39:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A397C20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B9DB8E0003; Thu,  1 Aug 2019 04:39:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36A338E0001; Thu,  1 Aug 2019 04:39:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2332D8E0003; Thu,  1 Aug 2019 04:39:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA3178E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:39:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so44266843ede.23
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:39:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sCRVf+gpn0wlMWGxl+gtqGEHaIHIajnEm/GCADxJLcs=;
        b=f0DD27rAxySKtb3Zk96VqWnLKjxQzbUSvH+5TfeFBuU25off9ApOQp4pSCignqj3Ei
         vaW/B3zdABqdrLqFUTCJp+9tnH6xTWUj0QwVllp33GE5bdWAVjqwPfmvru8lHlADKBH/
         /vEzKUwsGfC12KSvwFu1zd+vtyg++nm0BFynpzfIM0aBGP4RcLgLAK5YLzD9nz1/Pc7n
         nulCDStDB9KDD0snesx7KWyAVkfFaVmM6cisjIPiGXwyfTUb66O8ChXszbgNF2uIhrKT
         k1uRVcWgDKr+UKyM/TtdlfDd3ZYrZ0c/ZnT/Be0p9eULdn4Ywil3D7uCbkBXFzCLi2ig
         7neQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUfA+tXxN+R+Bo8x04cZoVSlxEpIdGtwTu9zMWMAlrXOYRCps4E
	lnnH5KU6fkXusAvgASwG8cEGBrYlmuay4Dj+hLtUZcP7c1KREe+guAqPm23BpfiAax8A1vFsL9m
	w3yGT/O8Pwjkq2TqkW3OynijWZDcGHHjsc7htT6MhOyessKIrjHYGdAJiSL2WMAzltw==
X-Received: by 2002:aa7:ca54:: with SMTP id j20mr112238500edt.50.1564648750386;
        Thu, 01 Aug 2019 01:39:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFxjeXYVy9ncWVTCt9UyoPVEUpBQxxK1ozRjIYzaYXIq+ivyD6OLQIK2xOZ5GIxJY/2DkY
X-Received: by 2002:aa7:ca54:: with SMTP id j20mr112238454edt.50.1564648749671;
        Thu, 01 Aug 2019 01:39:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564648749; cv=none;
        d=google.com; s=arc-20160816;
        b=Z7Ugr/YkRu7pviHYFJ+YF+hl4HifS9gl0IrAcQb2xKw5MBFNyAkTG89MEfY14x6Kuz
         KKVFTAiCZU/QEtj9Rx3+0aRRoPdWvJPYHeuyB5zJl35EneNQDqEL4ZE1RRK93sS6m41h
         BF9Eol0aNHtERH3bSxafx0OizfwsW7WPTpCKHumGGyCfJZuQBnJPC7QNcPhCnsUppUag
         4neQXbmf3mPpBXLG9vkWSY0QtcUJVcL0Dz2L5jxZ+dS2myitn6fmdjrNdGSZONMB7g+L
         r99IQFKOcsNh9t+d7Ng2tT1+FVfvGO4rfDULzgOTxMh7dopfAf2QsOAEMlHOLNXIden7
         fWxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sCRVf+gpn0wlMWGxl+gtqGEHaIHIajnEm/GCADxJLcs=;
        b=neQf8uHLzG4vhzsr/slaibNuFWRfs1ecUuf5YwucohEfEHnhZZdHYp/buoHjY6BC0H
         j+W4QqrXGl3fk3euPoIo42+KCzFfkw8HnCQRqpODi9nDP+TSx+7KYEDxmypLx+iyhXSM
         rSRLxRiJffSTqdTflPt5kr+QUrsHi8aBqcHy9HsKaVf2X0K646TbYldXpF/nD2P+yVfY
         AgCAnD7GrkJ2J0RU8K4bdGuAMFljCggd6ReVpt7rhKehbjrGx+LT0e6WBmGuSKllyfR/
         bVdUOyna7GCBpdewA+PA5tJubUpVSw/jg7bXUbkscdJlE4NRlZhiXW86Tr+5cbL1KciF
         nekg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f35si22563097edd.350.2019.08.01.01.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 01:39:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2B254B646;
	Thu,  1 Aug 2019 08:39:09 +0000 (UTC)
Date: Thu, 1 Aug 2019 10:39:01 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, mhocko@suse.com,
	anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com,
	vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 0/5] Allocate memmap from hotadded memory
Message-ID: <20190801083856.GA17316@linux>
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190801073931.GA16659@linux>
 <1e5776e4-d01e-fe86-57c3-1c3c27aae52f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e5776e4-d01e-fe86-57c3-1c3c27aae52f@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 10:17:23AM +0200, David Hildenbrand wrote:
> I am not yet sure about two things:
> 
> 
> 1. Checking uninitialized pages for PageVmemmap() when onlining. I
> consider this very bad.
> 
> I wonder if it would be better to remember for each memory block the pfn
> offset, which will be used when onlining/offlining.
> 
> I have some patches that convert online_pages() to
> __online_memory_block(struct memory block *mem) - which fits perfect to
> the current user. So taking the offset and processing only these pages
> when onlining would be easy. To do the same for offline_pages(), we
> first have to rework memtrace code. But when offlining, all memmaps have
> already been initialized.

This is true, I did not really like that either, but was one of the things
I came up.
I already have some ideas how to avoid checking the page, I will work on it.

> 2. Setting the Vmemmap pages to the zone of the online type. This would
> mean we would have unmovable data on pages marked to belong to the
> movable zone. I would suggest to always set them to the NORMAL zone when
> onlining - and inititalize the vmemmap of the vmemmap pages directly
> during add_memory() instead.

IMHO, having vmemmap pages in ZONE_MOVABLE do not matter that match.
They are not counted as managed_pages, and they are not show-stopper for
moving all the other data around (migrate), they are just skipped.
Conceptually, they are not pages we can deal with.

I thought they should lay wherever the range lays.
Having said that, I do not oppose to place them in ZONE_NORMAL, as they might
fit there better under the theory that ZONE_NORMAL have memory that might not be
movable/migratable.

As for initializing them in add_memory(), we cannot do that.
First problem is that we first need sparse_mem_map_populate to create
the mapping, and to take the pages from our altmap.

Then, we can access and initialize those pages.
So we cannot do that in add_memory() because that happens before.

And I really think that it fits much better in __add_pages than in add_memory.

Given said that, I would appreciate some comments in patches#3 and patches#4,
specially patch#4.
So I would like to collect some feedback in those before sending a new version.

Thanks David

-- 
Oscar Salvador
SUSE L3

