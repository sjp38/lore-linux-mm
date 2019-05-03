Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0D9CC004C9
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 07:31:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 994572133F
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 07:31:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 994572133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 076B86B0003; Fri,  3 May 2019 03:31:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04FD26B0005; Fri,  3 May 2019 03:31:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA6F26B0007; Fri,  3 May 2019 03:31:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7E946B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 03:31:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o8so2931851edh.12
        for <linux-mm@kvack.org>; Fri, 03 May 2019 00:31:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Kt48tJlgk/G1hX/+bOUindu2xfX+ApNMcd/aONBMTOU=;
        b=nDfCdAo8WtqpxUdB6AIEipCBh1XeZvrq9skfInOSfF1/uQCwGIn0fGuD/KbD6ulOPL
         kl1CRuiL5CR21i8W6dCotyjo9vbAVdWrEUmWn6ElPQrUHKA2NXP1g+9H38V21vgHJQ5K
         1ztUYp3iA/9MV97AxBJvWb3jAxDqWP/9cllkw0keb4/C6RwGjMge4EsJylrHIEI+/gWu
         rNno4o2QC+hEZN/hu7C8iXibhQE4Odpg6ZnGhThT9oLkAHNS90qB9OXSpjL1dJupdcm9
         6zjnRLa+yJT93eCpoZ3y39DZ2ZwQgoihbPN27NjJoBv4m22hZ6KpIl9x9Mx68Uh9IFci
         9Hag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAX83Tz2BrQtl0PENKRgkVYRXpj6MXKd9Bnom9VDdUER/utu0Qyv
	GyQRxEkm8LzZYUY4vMYSFilOYbO19TkBTg3YF0a3kJUQ9s4md5CQMM2GHLxe8il+sz3fPDu/Ou4
	VjcCLgpU9L19q5rFTs3IQyddZOS4mAUyleqovcqGLawfIWI6xEUURBAFUD5nSGM7C5A==
X-Received: by 2002:a50:b862:: with SMTP id k31mr4606235ede.27.1556868691330;
        Fri, 03 May 2019 00:31:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrUNsNBFvoM7+5SxiRZRGfELqUYC2ZK3iz9Cs3wHi4CF5QK+GoNCncKqe+LtdS8nQkqIFs
X-Received: by 2002:a50:b862:: with SMTP id k31mr4606160ede.27.1556868690364;
        Fri, 03 May 2019 00:31:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556868690; cv=none;
        d=google.com; s=arc-20160816;
        b=nPu73WGNulmrIFpW0St+P0c64SkqzLyf398IVCYtXI72T1i1b1Nii/qsQZLIC9Gah6
         kBXBRu2fgiD9ERBntDcweIPdaLysMREDNYxgExfcK5kbODyLdz2Q11CinLERsK5VwJSI
         ewE56x02HJN4tx+wkfhBCoZTzURC2eenObQHUlGAk8wKmHSZDtFRi8Gp4TUiqEIPBrqn
         c/rcnvZhs0qpX4E0UxbpHO4oNvq5JfdD5palHxOhIkofLXSFnZago2HWcuC56nPT/tBk
         i3IlUeK8ruSKcEFUyg9lhHqwBRMzJAh4nw1MVYMW/L+HCNVybQCJ4JZlw9zEQlpuwk6G
         7+sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Kt48tJlgk/G1hX/+bOUindu2xfX+ApNMcd/aONBMTOU=;
        b=THpJ8U4uMaoF7XstGexQbq9wnfcWzil4I7npoUqdkjwNKrEWi2nAn1qA01uXF+5U/g
         5IXhkNUqPe9hrPGL3TSCH+xeD/wAhb5dtMzeB3e5WMLoPD/MQNytaMA+AKVpPNgQAvd5
         iySTsRe4PFUXhjbzzu1CNJu2rlXyUQzE7pGtF4mF7Ui6VtBUTQu+1Pt2WvUgNmI4zdEB
         /ZVBeI6WsEiKDpns087nX9kB2ap/FNykObTLFAZnHXRhJkzhzi84PcPOMJGGXtI7krrD
         setKav/PVFSqWfxy1kzo0RYs79vx/3/JZlBtg2aadno8LsodL4S61vjx/KmNJzL22jw8
         XplA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x47si70007edb.353.2019.05.03.00.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 00:31:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C5BB9AEA1;
	Fri,  3 May 2019 07:31:29 +0000 (UTC)
Date: Fri, 3 May 2019 09:31:26 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jane Chu <jane.chu@oracle.com>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v7 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
Message-ID: <20190503073121.GA15740@linux>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677653785.2336373.11131100812252340469.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190502074803.GA3495@linux>
 <CAPcyv4jPG56sf4hHaKEoacQbDEpcMrr4fJVEwkxGjcWcCmieNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jPG56sf4hHaKEoacQbDEpcMrr4fJVEwkxGjcWcCmieNQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 07:03:45AM -0700, Dan Williams wrote:
> > section_active_mask() also converts the value to address/size.
> > Why do we need to convert the values and we cannot work with pfn/pages instead?
> > It should be perfectly possible unless I am missing something.
> >
> > The only thing required would be to export earlier your:
> >
> > +#define PAGES_PER_SUB_SECTION (SECTION_ACTIVE_SIZE / PAGE_SIZE)
> > +#define PAGE_SUB_SECTION_MASK (~(PAGES_PER_SUB_SECTION-1))
> >
> > and change section_active_index to:
> >
> > static inline int section_active_index(unsigned long pfn)
> > {
> >         return (pfn & ~(PAGE_SECTION_MASK)) / SUB_SECTION_ACTIVE_PAGES;

Sorry, here I meant:

return (pfn & ~(PAGE_SECTION_MASK)) / PAGES_PER_SUB_SECTION;

But I think you got the idea :-)

-- 
Oscar Salvador
SUSE L3

