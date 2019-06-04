Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75B86C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:41:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4863A24C53
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:41:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4863A24C53
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BED516B000C; Tue,  4 Jun 2019 03:41:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9B0E6B0010; Tue,  4 Jun 2019 03:41:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A63AD6B0270; Tue,  4 Jun 2019 03:41:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 598646B000C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:41:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k15so30478379eda.6
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:41:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Oe3jFM/rKMpf7Gvn4/0w5+5n0gR3xZQobt02RPbdzC0=;
        b=ijHGWVBNNXsruH1JyLtMtLFqb+VLmmjP+HLRthOsiqdAgdjupt5XwhHjpYMN4jPUmc
         1wKyJyF3bXeuwRgTLo2zTirtGY+PSUCbSpDCQkdFbPkPjsiHL7NwOJyaHXQ00qd9DRnl
         jqBnb/UvX04sj4zAd2LaLlJ05d2/eZgx1iGTskMlgoWyDH7JuZ2MPQc1xzpbMqHSrl5j
         TFXmhfQ72iOJ/Us2Lw8mBGMDgmEeJqzXIjd88Cv9aKarvIdOV4ZHGjtYUzjMcqqBfSp6
         7GRqBTSlzxuTL1IFWZfuHt5TwiMBsNuZhSnO8IkCpFt84okjrW/prMyBa+VP2HCmIqrZ
         jNNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW82Kp9dSUJrWIrmbXFgbZyw4PEStNM3L3DfjyX/SQCtiiLAUAq
	gtpYVJGWhtLhkQAWzA57P9ohA2g5OOh3eNGxN7qEL4dGZ/gc1aG5H4kK84YWKYovRKUIQjdUAZI
	2dtqX5NyOPjSaVsE6QWHFmp9XbRNsh7xmwpNET3hbIURiJo6cEV1+P5uXslbkCHDhJA==
X-Received: by 2002:a17:906:31d4:: with SMTP id f20mr28751933ejf.275.1559634069922;
        Tue, 04 Jun 2019 00:41:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRcO7VMieCuVdUHOMrPGzjZ3kPfhsm+9cYpRu5qU6reJRuNNuaoquS2jAcYEVbQYBc4lRI
X-Received: by 2002:a17:906:31d4:: with SMTP id f20mr28751853ejf.275.1559634068895;
        Tue, 04 Jun 2019 00:41:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559634068; cv=none;
        d=google.com; s=arc-20160816;
        b=LLuv5c99RG8arY3fI0gR4XtW9rbJngaMHJ5MjrIIpOHm/VGjAJZT3xRWod5aMvqUUe
         bkMUbWOFmbT8G0UKtqFZljizeQ+ipkiGFtjoToOfzjzfki45bkxo/ZDtrsFL0fIrxgBH
         rozLFDY30b+HQEMqM0SdxaP+VEdT69fkzO8j/Goyo6OHtAtNZESu3N0M4/Dd7MUWf8Aj
         vGRYdxQ59YarTYC5qlYRh7WaGjGUcX67r2YH8D0F2oViKTds14bUiZ+Q6dMgpHsugrSy
         QTSjCdwyXP2JjnVWbTSqsjyA3g31EQTrMQgZG49xyII37NS/16ydY7XPLHes6g1+BLbR
         oeSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Oe3jFM/rKMpf7Gvn4/0w5+5n0gR3xZQobt02RPbdzC0=;
        b=zUK7VuAD62g+UU4FSrtwNY4rpW6x4ePDNBbCCw+T+rOAgI0XnKhsAno3fT9rpVS25M
         PEel2aneIVLpCC0JG1gzXfcCgmcReyagBIDKWkOe1hX5DDiiKy6cgENiOEG9MNpC4mBe
         QdW2v/C07H1ahpkNC//zPiWswa377aRsQtZsm2SHw2eRX9qEGF/bRnxOCJ/S/RBOkWnC
         EjDSPA4bGwPoISayx4xe3ydyW4CTjWS7kYU0z1g78cZuIJEtm3+woTVbLDJfN8fbJVZv
         o/RVayzuFSvD6itBWThOoMg3cdqKtDRERhqEHpYxV9lbn6fMIba6l722SKQnMGwCdzgs
         f6mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si10950215ejj.80.2019.06.04.00.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 00:41:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BB2AEADD5;
	Tue,  4 Jun 2019 07:41:07 +0000 (UTC)
Date: Tue, 4 Jun 2019 09:41:00 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>,
	Jane Chu <jane.chu@oracle.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Paul Mackerras <paulus@samba.org>, Toshi Kani <toshi.kani@hpe.com>,
	Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-nvdimm@lists.01.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v8 00/12] mm: Sub-section memory hotplug support
Message-ID: <20190604074056.GA2853@linux>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:39:26PM -0700, Dan Williams wrote:
> Changes since v7 [1]:
> 
> - Make subsection helpers pfn based rather than physical-address based
>   (Oscar and Pavel)
> 
> - Make subsection bitmap definition scalable for different section and
>   sub-section sizes across architectures. As a result:
> 
>       unsigned long map_active
> 
>   ...is converted to:
> 
>       DECLARE_BITMAP(subsection_map, SUBSECTIONS_PER_SECTION)
> 
>   ...and the helpers are renamed with a 'subsection' prefix. (Pavel)
> 
> - New in this version is a touch of arch/powerpc/include/asm/sparsemem.h
>   in "[PATCH v8 01/12] mm/sparsemem: Introduce struct mem_section_usage"
>   to define ARCH_SUBSECTION_SHIFT.
> 
> - Drop "mm/sparsemem: Introduce common definitions for the size and mask
>   of a section" in favor of Robin's "mm/memremap: Rename and consolidate
>   SECTION_SIZE" (Pavel)
> 
> - Collect some more Reviewed-by tags. Patches that still lack review
>   tags: 1, 3, 9 - 12

Hi Dan,

are you planning to send V10 anytime soon?

After you addressed comments from Patch#9, the general implementation looks
fine to me and nothing sticked out from the other patches.
But I would rather wait to see v10 with the comments addressed before stamping
my Reviewed-by.

I am planning to fire my vmemmap patchset again [1], and I would like to re-base
it on top of this work, otherwise we will face many unnecessary collisions.

Thanks

[1] https://patchwork.kernel.org/patch/10875025/

-- 
Oscar Salvador
SUSE L3

