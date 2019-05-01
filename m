Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78CA8C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 23:25:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 041172081C
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 23:25:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="BXpRmV+6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 041172081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F9726B0005; Wed,  1 May 2019 19:25:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A8E36B0006; Wed,  1 May 2019 19:25:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 298186B0007; Wed,  1 May 2019 19:25:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06FBB6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 19:25:21 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id w34so379224qtc.16
        for <linux-mm@kvack.org>; Wed, 01 May 2019 16:25:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AH9bebtrf3dfxBIvf5hyUAJKcC8A07SNFaz6GXtYOok=;
        b=a94g2KeB0HSPOAI6FWYsi3tflC2aNgsUY3qtZWT1bER75jCv1cUwQMgH39N/v8BLOv
         pvy5rfsc0V5inBLahyJPPa5DX7lHAxy8t1dEpa6OBbYupsig2mdCY92kx6xAvSBm6iC6
         TOgTZEKM5FMbcyly2i4nRK5NZx5CNnHWJXPg6VVzrt/rVeTKdImOgFRHArwm3LiVa84u
         f/Bq7cAM00Dr5sTPBa08HsBY2BHZCwybYecJ3B9llVAQ/jkPSCMpKa0NyA3+uuuefiD2
         tkcXOU6lbUq3NepETaxmpfprxak9Un9NW4GWj5Lgh78Fr/80lHeq/+VXCSHrd/J8zWfG
         wgeA==
X-Gm-Message-State: APjAAAUbHm16hvxbiYKwY9UBic7SuSqf+IgQV9kfaPpgD1xdrFai2tyn
	vWox5En9j9lCdOyC6IGcYpanRaD4AgUbLh8a+Ros0eOICZL+SDtf5is6oW6uJgyAw4fKBHAcC/8
	td1fd6xSgIkR1uT4DKdyB3nuPPbr6dx7jllzAf8Ur01QpO7yYGULdEHh9oCYLSrk5oQ==
X-Received: by 2002:ac8:3787:: with SMTP id d7mr628688qtc.95.1556753120789;
        Wed, 01 May 2019 16:25:20 -0700 (PDT)
X-Received: by 2002:ac8:3787:: with SMTP id d7mr628642qtc.95.1556753119970;
        Wed, 01 May 2019 16:25:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556753119; cv=none;
        d=google.com; s=arc-20160816;
        b=hxVRgsc+ZsuhF2UveMdlOMxQlIMZzt/ZuMKg30XOVq34seCyasrxfoRz8r4HtD9mqy
         Op8uHURnTudIhAE5LpaHoqv7SMLwSYHzGN5LiU4QGO0jqfuY3fPPP6YChAInJrTEFjj/
         VBHb/4JQ+q7izkamNsiov+WcLjZdQgXVpYwe/rPYerNunOyrov3r1GcYHEdT+1ZL7g0O
         MXPIn3HL+fhcRUqXhtTGU0Skv7bTQZRVBelG/9RrVqsyqWBOrB99X10HmqqB3/cMakhJ
         IzcmcTZDkfm5hYWXJ70X/wpElEQOAk+WJDBvfe7ckaBmE5YKJ9JtaolzBKKwwI/HgCu/
         mbFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AH9bebtrf3dfxBIvf5hyUAJKcC8A07SNFaz6GXtYOok=;
        b=RsPSzaQV7AApBwupHE51fiqHKGf8kMFeJlDrmbJKiI+dLf2tj72pEP9ROm/ZEYl3rL
         syKEtQg/Qbl/ldUEkPPRr1NHsNAfRhTfS4gqKlC4O9eYftFO8An62MUMP324Eq/IySHQ
         X55rM30kiKi74Uq/KSJ7imFudlifJ7AD9XPPDrMP+KZEyLetakEUag8Kzcj00HSk9XFS
         ErmNWr6MwEj+4t5yCajoaFGdq9dblMcq9DVw6bZfreMdyjWu+Q9uuqfq1LljBZNpHYI9
         xUJz4NYllKi0hQLZJNdQ5wGzf/BRoumo1qx4GKuSTmYik3g2aG5VPz+2+zZytpQlhLeb
         dfng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=BXpRmV+6;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s17sor16280597qta.3.2019.05.01.16.25.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 16:25:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=BXpRmV+6;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=AH9bebtrf3dfxBIvf5hyUAJKcC8A07SNFaz6GXtYOok=;
        b=BXpRmV+6OvhC688uYI7duSFxoIJaSy5qGca6z3Jg/huzWFwaDds/rsuOmCgs+X/2D6
         nBypKSCBxfF4R11Now1TSKhdmOMcrt3KkOdbhBH0StpDAk0pUqh67sdtSS9SmVYGhDUk
         /99rNYVp/l9SQQD1woxx4wplZpwQh7L398wBwiSgokkpiSyf3soHy/rfnupj45f8qETL
         3Zbbo4Qv4rbnpxEJ3d7hMOa96+c1exFDA5YIp3AA2vuT6pZa8bi7DOkFM2mh3N66ok6F
         IOCT3T8WXbGp8+s6DBvFxEJp6jdS5SHiiuzhxHnHHGQ0ViVh7R+puVcqX8lGPsNsV6j6
         gf/A==
X-Google-Smtp-Source: APXvYqz0BDqKG+Q2jzUmKI5xzLPAvNPYQjFLDLv988MLkpQr6Ryuk0h2Lnb2Pj89t7Bct/URoLhIMw==
X-Received: by 2002:ac8:27aa:: with SMTP id w39mr658332qtw.227.1556753119438;
        Wed, 01 May 2019 16:25:19 -0700 (PDT)
Received: from soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net ([40.117.208.181])
        by smtp.gmail.com with ESMTPSA id 62sm13373216qtf.89.2019.05.01.16.25.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 16:25:18 -0700 (PDT)
Date: Wed, 1 May 2019 23:25:17 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
	david@redhat.com
Subject: Re: [PATCH v6 01/12] mm/sparsemem: Introduce struct mem_section_usage
Message-ID: <20190501232517.crbmgcuk7u4gvujr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634075.2015392.3371070426600230054.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552634075.2015392.3371070426600230054.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19-04-17 11:39:00, Dan Williams wrote:
> Towards enabling memory hotplug to track partial population of a
> section, introduce 'struct mem_section_usage'.
> 
> A pointer to a 'struct mem_section_usage' instance replaces the existing
> pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
> 'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
> house a new 'map_active' bitmap.  The new bitmap enables the memory
> hot{plug,remove} implementation to act on incremental sub-divisions of a
> section.
> 
> The primary motivation for this functionality is to support platforms
> that mix "System RAM" and "Persistent Memory" within a single section,
> or multiple PMEM ranges with different mapping lifetimes within a single
> section. The section restriction for hotplug has caused an ongoing saga
> of hacks and bugs for devm_memremap_pages() users.
> 
> Beyond the fixups to teach existing paths how to retrieve the 'usemap'
> from a section, and updates to usemap allocation path, there are no
> expected behavior changes.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mmzone.h |   23 ++++++++++++--
>  mm/memory_hotplug.c    |   18 ++++++-----
>  mm/page_alloc.c        |    2 +
>  mm/sparse.c            |   81 ++++++++++++++++++++++++------------------------
>  4 files changed, 71 insertions(+), 53 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 70394cabaf4e..f0bbd85dc19a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1160,6 +1160,19 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
>  #define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
>  #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
>  
> +#define SECTION_ACTIVE_SIZE ((1UL << SECTION_SIZE_BITS) / BITS_PER_LONG)
> +#define SECTION_ACTIVE_MASK (~(SECTION_ACTIVE_SIZE - 1))
> +
> +struct mem_section_usage {
> +	/*
> +	 * SECTION_ACTIVE_SIZE portions of the section that are populated in
> +	 * the memmap
> +	 */
> +	unsigned long map_active;

I think this should be proportional to section_size / subsection_size.
For example, on intel section size = 128M, and subsection is 2M, so
64bits work nicely. But, on arm64 section size if 1G, so subsection is
16M.

On the other hand 16M is already much better than what we have: with 1G
section size and 2M pmem alignment we guaranteed to loose 1022M. And
with 16M subsection it is only 14M.

