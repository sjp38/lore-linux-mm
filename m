Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7A0BC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:15:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 925D7208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:15:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 925D7208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C6D06B0006; Wed, 26 Jun 2019 04:15:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 250358E0003; Wed, 26 Jun 2019 04:15:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C9AF8E0002; Wed, 26 Jun 2019 04:15:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C64BE6B0006
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:15:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b33so1971947edc.17
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:15:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ju1KSPvhOb5INBPqIbo0ETZbUyGfjddJsPo7jeUpmDw=;
        b=lKeL4BkfaOGlxaSmWEHflAGn2J9GuYOHsDHLiw2C9qwHbe3wqXmguqtYW+VH0qtfxi
         ngAwkmioTIC3FuLKnCOBWB1J7JyaLOamEuv7UifLVg3E/Lj0IcifqQJwcgKnOczjzgk1
         I5lwtSHzAlyU/0/AhHM9qYC6DHVh2tXUjxMsa57p6sPPoBW2uh0AOiuT6lk7e4t7avou
         D4MKvZYEP6keBoAfNyjJzdTJmi8r/sMKXGsmpm/rCicjyG5/ESwo1Nt55pT71bGzQy1C
         4rElcnhHP2tHxs1BW5cvrfE2BtDHBXVOpSg2kQDuq+mUqT2e9xk4qmoUvqq5vNuz7mDd
         QTUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXhP24yBHTLtHAKqd1ldB3i/uu+pYtVfnYe8weJwR2wKX9I3J9G
	ZvpE7TjAKFo7bwIezR3wWZQ9UhRP1V7XqPts+BIXO2bNM4KHASKi4NmpC6naVUefTt+teLZcizb
	rjJ9F7KO+ue3tDQPuGeQ76XLLeBWIZW7jo5dxydT6VTl4/ONCKLsYquyziwyVVPfEbQ==
X-Received: by 2002:a50:95b0:: with SMTP id w45mr3722552eda.12.1561536920388;
        Wed, 26 Jun 2019 01:15:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySzPcKCvfKsZuJGTAvzRMU9Qwrh3cp9sv75L5sY4XEIPuR1pPtuiPbwlQSfElP/1qO2WAi
X-Received: by 2002:a50:95b0:: with SMTP id w45mr3722491eda.12.1561536919819;
        Wed, 26 Jun 2019 01:15:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561536919; cv=none;
        d=google.com; s=arc-20160816;
        b=MZn+9VZuXFbKRqzepD8eqKWGMuoJCWcyGsfpCzl/c/A4Z27tve6RZbyDdfBK7mzYQ6
         hN5/EKXrZn6panuaYaMPxFwyJc0qMdZlx0mcInwtQsOUjG8EE575iB7Kkb+S0iS6vYA8
         ASkROaxhQEIUINxZtRLzuP24l3CB4P4tTO7bT7xfBDMg8hAiYbPTpoQo7vR9JvVYY+mo
         sfMEc2KOGYRzw2TyU152sRBhEEm9FymjWi8Q/eBsD0LC1OCNSbRyDboHVLBX9paZwN4T
         x+fMSkUWV8CBtf5z3OSqf2IzG9A9OZeLtPKeu3unmpsCr6F/lGoqZegJwtalgQlR+UD9
         Zwzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ju1KSPvhOb5INBPqIbo0ETZbUyGfjddJsPo7jeUpmDw=;
        b=JxbiizaJk8t3E5m9AFUb15LIJYwEuwiVPz7osxkvV+ZhbBtXAGn+gHR5DAGjnWt+K/
         QX7x73q1g1Op7e6/7P9b3Cv58d5UTxaXcYP28FFBCileqpUmIXr5wDuuHZhdjVnIJHm8
         JjIhEKGI/5MKvLK+KlmOHfhvEuM86nZRRmXZT5AsskkfuR7isyxvQcxOoSzbbnR5X1gB
         GWjZQChdXkI76pftiIrHBUzA3lHgoDCLqhl3+Jr8elhLkxIbFHdDB1LuA5trHy38k3TZ
         LugU2HXg4ThSilZ+lks4wjMWQRf6CZ2tMGPxZUoCQ4SY4TlJa3mqbg+0hORCtlazZZqn
         s90A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l12si2102532eje.228.2019.06.26.01.15.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 01:15:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3DF6BAD09;
	Wed, 26 Jun 2019 08:15:19 +0000 (UTC)
Date: Wed, 26 Jun 2019 10:15:16 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190626081516.GC30863@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
> Back then, I already mentioned that we might have some users that
> remove_memory() they never added in a granularity it wasn't added. My
> concerns back then were never fully sorted out.
> 
> arch/powerpc/platforms/powernv/memtrace.c
> 
> - Will remove memory in memory block size chunks it never added
> - What if that memory resides on a DIMM added via MHP_MEMMAP_DEVICE?
> 
> Will it at least bail out? Or simply break?
> 
> IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save to be
> introduced.

Uhm, I will take a closer look and see if I can clear your concerns.
TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
yet.

I will get back to you once I tried it out.

-- 
Oscar Salvador
SUSE L3

