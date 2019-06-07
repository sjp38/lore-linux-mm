Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40AB7C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:34:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDD5820B7C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:34:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDD5820B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D0166B000C; Fri,  7 Jun 2019 04:34:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7830A6B000E; Fri,  7 Jun 2019 04:34:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6483E6B0269; Fri,  7 Jun 2019 04:34:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 113BE6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 04:34:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d13so2072911edo.5
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 01:34:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HyvrDinC1IPAIzuprI5A00pYg/6BzKS0lFeC6y+42zA=;
        b=JLUnvyUsDyjdDzZHerhgzEsiIP5uMtqHF7uYxjqdM1/BIGHs9fluI1jsQUM+pWg+s/
         z4cvYx1OevRaZFpdCE1XsHeVzTjxT1zhwtGGn9qFjB2lY5NMdPZ18A0e8pYil7RMc2bo
         Xlt6BhqS+ERbQpXhUXs7uxyKzItrsolkRdE3WZQ931fIwNF4Rp6i2hlQHQV4t8ZcFG02
         f/dlM84MTx4lhsYvfaduNjqUYVdPeMSsDmBXjmGgjV0r23qikLMUrFR/5qFGStkJJJJf
         1ABE2pdUG4qjE5hSb+3JAB0F9/vicOpoAgvwcCUEMvJPnp+AAtJcwxqsBTId2b0+bW28
         wsLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU11t5Rdill2V5Kf7hsxdHVJQkUylIZjZIeUkS0dSg9l5RtfHHH
	tmQmpgTF3P3U2mAinNO01ViWFwGM4D/gcqwZdSn171Zma9fRPKvh9c4kL0GTZFJrV2L9lmtLaCH
	M6O0Y6ltqa/pLPtJHnLE4ELz+SVGcqQ6UNzOzdcX4U6zPbvJf9iV/7yMyNnwuvD88gQ==
X-Received: by 2002:a17:906:c315:: with SMTP id s21mr27213865ejz.238.1559896444486;
        Fri, 07 Jun 2019 01:34:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyepxPWKkc+1/I9+Bt0lvrglyjKFHwraGfPc/pmmJOfLD9kfd2DnOTIon9uTjuoqDYKD/dj
X-Received: by 2002:a17:906:c315:: with SMTP id s21mr27213812ejz.238.1559896443546;
        Fri, 07 Jun 2019 01:34:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559896443; cv=none;
        d=google.com; s=arc-20160816;
        b=sF08JA39uJAwF3tFjS8HemRNQnUPLr1qnm+ZDIfY/YF11ORDJiUmOLaNCFGFirsRjJ
         eQFNpX+n8zJjR78xNNGNcSaqRWky7IqM2mP1iVtyjulS6At0Y42ly7j3cwNNUAhbrvIV
         KWtQ1tlDSS7dmt9Eu7hxGCuU6AsaxR/j1XRPFBXeP7Ivs7whLea+KjxB8K6uUH9RMDP0
         F2Vh30+Xhq0+fFyYxacUI9avO9t+2F7VPM8aruQQi8GFBRlsjtsp8YXvUbqcfRmftNe9
         FYU1o7z4Q80B4kPFAsSeOgsf3/+4xrzh9REXvPlPLL51uWOIDk+quswhr6qJpHHG+if1
         nCqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HyvrDinC1IPAIzuprI5A00pYg/6BzKS0lFeC6y+42zA=;
        b=yLIuBTxUpe57FaWylD6CD31JrW0rb5ueW9xqABRt/OrMNqNfOzJbXXQOEw2n3Z8Z0w
         X7/eD8rQ+nQDTnLS9UQ/aH53HV+8RRO3nYLGHVK5YJcz026vc5O+W60MqVZ9IWTwUNnX
         60p5Upzsy3QSNFX+n1RteIunDgKjFV9xFr6onlHR7Fu9IuLdpVW6WwyIqOegOvNQxwjJ
         Fe8H4oO5tlIZLrTxnekBSQ2XV6W/79XKM6c3nIspiSgYh04I4onq1ilMuXFCZy4wpiM5
         V4lDy6NH5pdZikD3tOh2BZ/NJwf3WmGGL9T1o5vEJDCQDPGOZKSH5n2wqkMak30iT0n4
         QCQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k49si875884ede.209.2019.06.07.01.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 01:34:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 123A7ABD5;
	Fri,  7 Jun 2019 08:34:03 +0000 (UTC)
Date: Fri, 7 Jun 2019 10:33:58 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 08/12] mm/sparsemem: Support sub-section hotplug
Message-ID: <20190607083351.GA5342@linux>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977192280.2443951.13941265207662462739.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155977192280.2443951.13941265207662462739.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:58:42PM -0700, Dan Williams wrote:
> The libnvdimm sub-system has suffered a series of hacks and broken
> workarounds for the memory-hotplug implementation's awkward
> section-aligned (128MB) granularity. For example the following backtrace
> is emitted when attempting arch_add_memory() with physical address
> ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
> within a given section:
> 
>  WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
>  devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
>  [..]
>  Call Trace:
>    dump_stack+0x86/0xc3
>    __warn+0xcb/0xf0
>    warn_slowpath_fmt+0x5f/0x80
>    devm_memremap_pages+0x3b5/0x4c0
>    __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
>    pmem_attach_disk+0x19a/0x440 [nd_pmem]
> 
> Recently it was discovered that the problem goes beyond RAM vs PMEM
> collisions as some platform produce PMEM vs PMEM collisions within a
> given section. The libnvdimm workaround for that case revealed that the
> libnvdimm section-alignment-padding implementation has been broken for a
> long while. A fix for that long-standing breakage introduces as many
> problems as it solves as it would require a backward-incompatible change
> to the namespace metadata interpretation. Instead of that dubious route
> [1], address the root problem in the memory-hotplug implementation.
> 
> [1]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/memory_hotplug.h |    2 
>  mm/memory_hotplug.c            |    7 -
>  mm/page_alloc.c                |    2 
>  mm/sparse.c                    |  225 +++++++++++++++++++++++++++-------------
>  4 files changed, 155 insertions(+), 81 deletions(-)
> 
[...]
> @@ -325,6 +332,15 @@ static void __meminit sparse_init_one_section(struct mem_section *ms,
>  		unsigned long pnum, struct page *mem_map,
>  		struct mem_section_usage *usage)
>  {
> +	/*
> +	 * Given that SPARSEMEM_VMEMMAP=y supports sub-section hotplug,
> +	 * ->section_mem_map can not be guaranteed to point to a full
> +	 *  section's worth of memory.  The field is only valid / used
> +	 *  in the SPARSEMEM_VMEMMAP=n case.
> +	 */
> +	if (IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP))
> +		mem_map = NULL;

Will this be a problem when reading mem_map with the crash-tool?
I do not expect it to be, but I am not sure if crash internally tries
to read ms->section_mem_map and do some sort of translation.
And since ms->section_mem_map SECTION_HAS_MEM_MAP, it might be that it expects
a valid mem_map?

> +static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
> +		struct vmem_altmap *altmap)
> +{
> +	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
> +	DECLARE_BITMAP(tmp, SUBSECTIONS_PER_SECTION) = { 0 };
> +	struct mem_section *ms = __pfn_to_section(pfn);
> +	bool early_section = is_early_section(ms);
> +	struct page *memmap = NULL;
> +	unsigned long *subsection_map = ms->usage
> +		? &ms->usage->subsection_map[0] : NULL;
> +
> +	subsection_mask_set(map, pfn, nr_pages);
> +	if (subsection_map)
> +		bitmap_and(tmp, map, subsection_map, SUBSECTIONS_PER_SECTION);
> +
> +	if (WARN(!subsection_map || !bitmap_equal(tmp, map, SUBSECTIONS_PER_SECTION),
> +				"section already deactivated (%#lx + %ld)\n",
> +				pfn, nr_pages))
> +		return;
> +
> +	/*
> +	 * There are 3 cases to handle across two configurations
> +	 * (SPARSEMEM_VMEMMAP={y,n}):
> +	 *
> +	 * 1/ deactivation of a partial hot-added section (only possible
> +	 * in the SPARSEMEM_VMEMMAP=y case).
> +	 *    a/ section was present at memory init
> +	 *    b/ section was hot-added post memory init
> +	 * 2/ deactivation of a complete hot-added section
> +	 * 3/ deactivation of a complete section from memory init
> +	 *
> +	 * For 1/, when subsection_map does not empty we will not be
> +	 * freeing the usage map, but still need to free the vmemmap
> +	 * range.
> +	 *
> +	 * For 2/ and 3/ the SPARSEMEM_VMEMMAP={y,n} cases are unified
> +	 */
> +	bitmap_xor(subsection_map, map, subsection_map, SUBSECTIONS_PER_SECTION);
> +	if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION)) {
> +		unsigned long section_nr = pfn_to_section_nr(pfn);
> +
> +		if (!early_section) {
> +			kfree(ms->usage);
> +			ms->usage = NULL;
> +		}
> +		memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
> +		ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
> +	}
> +
> +	if (early_section && memmap)
> +		free_map_bootmem(memmap);
> +	else
> +		depopulate_section_memmap(pfn, nr_pages, altmap);
> +}
> +
> +static struct page * __meminit section_activate(int nid, unsigned long pfn,
> +		unsigned long nr_pages, struct vmem_altmap *altmap)
> +{
> +	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
> +	struct mem_section *ms = __pfn_to_section(pfn);
> +	struct mem_section_usage *usage = NULL;
> +	unsigned long *subsection_map;
> +	struct page *memmap;
> +	int rc = 0;
> +
> +	subsection_mask_set(map, pfn, nr_pages);
> +
> +	if (!ms->usage) {
> +		usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
> +		if (!usage)
> +			return ERR_PTR(-ENOMEM);
> +		ms->usage = usage;
> +	}
> +	subsection_map = &ms->usage->subsection_map[0];
> +
> +	if (bitmap_empty(map, SUBSECTIONS_PER_SECTION))
> +		rc = -EINVAL;
> +	else if (bitmap_intersects(map, subsection_map, SUBSECTIONS_PER_SECTION))
> +		rc = -EEXIST;
> +	else
> +		bitmap_or(subsection_map, map, subsection_map,
> +				SUBSECTIONS_PER_SECTION);
> +
> +	if (rc) {
> +		if (usage)
> +			ms->usage = NULL;
> +		kfree(usage);
> +		return ERR_PTR(rc);
> +	}

We should not be really looking at subsection_map stuff when running on
!CONFIG_SPARSE_VMEMMAP, right?
Would it make sense to hide the bitmap dance behind

if(IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)) ?

Sorry for nagging here

>  /**
> - * sparse_add_one_section - add a memory section
> + * sparse_add_section - add a memory section, or populate an existing one
>   * @nid: The node to add section on
>   * @start_pfn: start pfn of the memory range
> + * @nr_pages: number of pfns to add in the section
>   * @altmap: device page map
>   *
>   * This is only intended for hotplug.

Below this, the return codes are specified:

---
 * Return:
 * * 0          - On success.
 * * -EEXIST    - Section has been present.
 * * -ENOMEM    - Out of memory.
 */
---

We can get rid of -EEXIST since we do not return that anymore.

-- 
Oscar Salvador
SUSE L3

