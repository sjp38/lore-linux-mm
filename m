Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3716C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D8F52175B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:17:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D8F52175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D44806B000A; Tue, 23 Apr 2019 09:17:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF2516B000C; Tue, 23 Apr 2019 09:17:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE1A16B000D; Tue, 23 Apr 2019 09:17:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8E96B000A
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:17:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j9so3595930eds.17
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 06:17:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EG0JgLoe/66pVFntx363FynOzU34Hjn5CNxb8kVNDq8=;
        b=qSVsC7K1k+o4zyCbDpiCryHCReyhcBgtK3pBxJ71vTJDjLSBxorZBlcdxl/sxu71p6
         AuQi493yPsIXc5EpgQ35mZIjR52WF2nw5XJWSXKRKybqdGrooGnk7f0jzRXwrn025Yn5
         fTvfXI9u6c0j+wgs9Z114iA6/Q/KCZhY9qxDNtIpjhs5mo6WkA0VUp/UHBMz3JEevB6e
         HiGnLwrI5JqY/4vXCsFjb5mQc646fDqmIZqAr+Bath3b3ci6ULNLm8iF91EV1arVylGx
         SIz61TCOHAyqBiv73X8nUshQEqQXyqnBEg4LojF60PZDJQ/Z0OzYwVUkYESdJlvZblEd
         kcbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWYEMKnlhLfGaAp7xG5lG1yVDN3INZd8yg3RZUh60hgzC5rO4GR
	8fZJkBvLO8EuE8L/LtJQRBP14SSSEIpsVZL2TmFpWvYVbBxp4cxaBk1ESbIaNw3gI2N4FtCVzO8
	ki80SbM1XcgjR7jGMrDlGP8aotNt/C6cwUC9qXdEo3VaSqi7FbBGDAssoEcfE+ZPK3Q==
X-Received: by 2002:a17:906:3e8f:: with SMTP id a15mr12262495ejj.189.1556025437893;
        Tue, 23 Apr 2019 06:17:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwO3phGCiN76C3E2F2J9w0ytWCy6PI2EDsV/x+JtXRMYks7NB37PU/ZZ8KUjZLTFGBy+tKZ
X-Received: by 2002:a17:906:3e8f:: with SMTP id a15mr12262435ejj.189.1556025436533;
        Tue, 23 Apr 2019 06:17:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556025436; cv=none;
        d=google.com; s=arc-20160816;
        b=hA40rBQuFx/+78xs9/ds5QwBKI1y232jK2KE5xKrrvzitjM9YHotVS2982uqY+X/oH
         wkrxzZlbaHG68hKFjyRc4M22YqSxooiLcfEtKoempFJFToNkkpNCJgLtaQnAZocEh2oT
         eqoRrvqHv3623NHDXrw1wCclT33kTg5LvgK/YkHWc8faYTU3Iw4cTbmPZPCu9gr3+DuA
         TM4QLFa/SV09fNxk7FPwhIUHWutyC61JI7WIv4FRwcb2XLSvCw+WXFXZGPgTXWyaUzUR
         4Pm0gNSK+/EV0adlwvkNhPvO61fwJZfzQ4rLhV6nIsGqU4N2L7VZgP/kOyA365NyncQ6
         666Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=EG0JgLoe/66pVFntx363FynOzU34Hjn5CNxb8kVNDq8=;
        b=zuZCzTRzZJXModhaNqDmHbEwfhPGJqpRpAAtZx2KNTYWg3m5wmxjS1A8qbOkal6O8f
         p0i7ixKTw5lPuHS2l5hVo03VlQACrH2xI2uMt5xyoCEAyLzq7Po7Onj5ix1aIv6LQgc5
         hgqOKfJ49fVvSn6odCfCfVJdIA6RvjP0L3KKT41MOt0h7r9qf+oG5w2BnbZBWXASXx9O
         EvdXCLxDdnkp3wpciIJ0A43Oa8ZLBInmqxx1YWCdRzh2pRFPMJl+R5iKRI+LMpfATUxb
         RjnqB/4u7MkO9HpnyVsjdhCtGLcwN9Tgv3PsgdwQio6hiRhFSpzOEVdrI+2hRW4xiMXn
         WinQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c38si2277449eda.49.2019.04.23.06.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 06:17:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8A81EABB1;
	Tue, 23 Apr 2019 13:17:15 +0000 (UTC)
Message-ID: <1556025416.2956.0.camel@suse.de>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>, Andrew Morton
	 <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
	 <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Toshi Kani
	 <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, Michal Hocko
	 <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, stable
	 <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm
	 <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List
	 <linux-kernel@vger.kernel.org>
Date: Tue, 23 Apr 2019 15:16:56 +0200
In-Reply-To: <CAPcyv4hB47NJrVi1sm+7msL+6dJNhBD10BJbtLPZRcK2JK6+pg@mail.gmail.com>
References: 
	<155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20190417150331.90219ca42a1c0db8632d0fd5@linux-foundation.org>
	 <CAPcyv4hB47NJrVi1sm+7msL+6dJNhBD10BJbtLPZRcK2JK6+pg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-04-17 at 15:59 -0700, Dan Williams wrote:
> On Wed, Apr 17, 2019 at 3:04 PM Andrew Morton <akpm@linux-foundation.
> org> wrote:
> > 
> > On Wed, 17 Apr 2019 11:38:55 -0700 Dan Williams <dan.j.williams@int
> > el.com> wrote:
> > 
> > > The memory hotplug section is an arbitrary / convenient unit for
> > > memory
> > > hotplug. 'Section-size' units have bled into the user interface
> > > ('memblock' sysfs) and can not be changed without breaking
> > > existing
> > > userspace. The section-size constraint, while mostly benign for
> > > typical
> > > memory hotplug, has and continues to wreak havoc with 'device-
> > > memory'
> > > use cases, persistent memory (pmem) in particular. Recall that
> > > pmem uses
> > > devm_memremap_pages(), and subsequently arch_add_memory(), to
> > > allocate a
> > > 'struct page' memmap for pmem. However, it does not use the
> > > 'bottom
> > > half' of memory hotplug, i.e. never marks pmem pages online and
> > > never
> > > exposes the userspace memblock interface for pmem. This leaves an
> > > opening to redress the section-size constraint.
> > 
> > v6 and we're not showing any review activity.  Who would be
> > suitable
> > people to help out here?
> 
> There was quite a bit of review of the cover letter from Michal and
> David, but you're right the details not so much as of yet. I'd like
> to
> call out other people where I can reciprocate with some review of my
> own. Oscar's altmap work looks like a good candidate for that.

Thanks Dan for ccing me.
I will take a look at the patches soon.

-- 
Oscar Salvador
SUSE L3

