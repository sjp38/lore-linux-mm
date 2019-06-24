Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 339C0C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 20:45:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02F4220665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 20:45:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02F4220665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 866E86B0005; Mon, 24 Jun 2019 16:45:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F07A8E0003; Mon, 24 Jun 2019 16:45:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B9418E0002; Mon, 24 Jun 2019 16:45:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3926B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 16:45:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so22186986edo.5
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:45:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8EGDkDlRwTg68dmvhUz2v5W3wT6YxTFHi108IOVbZTM=;
        b=Jl/kdKl6HT6VUcrY28FB/GfPaAQdyT76aUXHPbO4tiDci49BVTEDwFiwDWK/3kjIxp
         2BcNUZWj/yTb8r4rwG26qjsLBCc5+8HkOFBWnI0xiUBmJrpLXZzHb9ls56B9sHuMSa9M
         5s9wAQ2VyjJuSdAM5C1QPFeu8WkmcEbiVLEoQAmBYXhXiJ393hEGsPGaCdaAjUqKRKDo
         CgBq+LCBAJKNkG+1hF0g7ZTGj8XQtRkq+sBL0FMLNd/D8fqzFxmQwwRfNhyq5saoKtpd
         mElvTBbb2RAfPvEb1LMQJwmS7Sm62YnOFM1bNWavFj7l8Ytt36pGylHKJqng0Rh/j8tz
         Jw+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUPY5P68MfHXuoGJb8vOiQh7Fg14WLAfVXRPKFNl1G0MaktpzVx
	zAmkbWRO2bS5vgq3uQ45O24nbZZDagBXZtsFRc/7rD03kcrywsiGTuggAVS7e9FM2YQKeghbXuF
	dnXSJbuXhPtxZOnP/rvsjeyWpdC4G0BzBD8sIvzbaDip7DXJFJ9bLEt8F70QYP8i2Bg==
X-Received: by 2002:a50:adec:: with SMTP id b41mr11723747edd.102.1561409133628;
        Mon, 24 Jun 2019 13:45:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGVx9ITcBfqRZzbx409Qgwsyk4DFjUjSshxd/Tc3FDeGc4cyh/qtPhVIFzXZBljFLl6/nh
X-Received: by 2002:a50:adec:: with SMTP id b41mr11723669edd.102.1561409132633;
        Mon, 24 Jun 2019 13:45:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561409132; cv=none;
        d=google.com; s=arc-20160816;
        b=tepKWlLdn+DXhl9xytum644lNGXaNoMu9exljx2MvQMXk+5VdX5oL94joLDZuglWi5
         ZWqiadXuFdwBgRtN6Igwq7lEC2bHVkJhi6eogPHOP0veIiLeetGUtFNJb1qtx36L19RS
         QgAwG1ZTyPz7DFL7I6sBrKPkp2xqtY5EuEpiRUnya66GEFZsL7VU+ddAQ3bQ5GESU8um
         fk2K9ncPhZmnQ1tPuObsolUrJo1YBH1Q0mm6AgjjYSYaBw1DWUWVchwmx6c0IsJGT2Fu
         FO/8Dwg/F28IzrjXyLUX+lvght5qCzl4jHasK32GK0fAk6OzPxmKZ1NpTUMPBculZcQz
         P8oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=8EGDkDlRwTg68dmvhUz2v5W3wT6YxTFHi108IOVbZTM=;
        b=j7gQXprS/A0CzrC1KMl58vf/nhgqKzzw1yoJpQlx6RTZxpW/6rCpQ/enw2zH1SSleD
         rHpjGmJFmX0/m9+xAwa9Sh6nFkZqxX/Lrz3H5JXbbnCcI1TjtTuk2wGxQQsexM0rFlij
         0aeZ8yPDDWTzx4Raa1MeErC/cqwA0CWPGzOLvkXf8+G+6q+qhCmHxgBhqmVaOJP11ia0
         dKN37k9tIJEaXsOJduUos5xy9hvIOaRYfVzGqOLQCXH+RDAXr0l/iwVHr0A4ifcYGdM5
         5QSD6PG/t3sVHG7x8V6xzkbqS1gIhABbjAF8MIAyroiajMa4n0+pt0djhzKvFQ7fgyj4
         IGJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f25si10463315ede.206.2019.06.24.13.45.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 13:45:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CC8C4AE34;
	Mon, 24 Jun 2019 20:45:31 +0000 (UTC)
Message-ID: <1561409129.3058.1.camel@suse.de>
Subject: Re: [PATCH v10 09/13] mm/sparsemem: Support sub-section hotplug
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Logan
 Gunthorpe <logang@deltatee.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, linux-mm@kvack.org, 
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Mon, 24 Jun 2019 22:45:29 +0200
In-Reply-To: <156092354368.979959.6232443923440952359.stgit@dwillia2-desk3.amr.corp.intel.com>
References:
	  <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <156092354368.979959.6232443923440952359.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-18 at 22:52 -0700, Dan Williams wrote:
> The libnvdimm sub-system has suffered a series of hacks and broken
> workarounds for the memory-hotplug implementation's awkward
> section-aligned (128MB) granularity. For example the following
> backtrace
> is emitted when attempting arch_add_memory() with physical address
> ranges that intersect 'System RAM' (RAM) with 'Persistent Memory'
> (PMEM)
> within a given section:
> 
>     # cat /proc/iomem | grep -A1 -B1 Persistent\ Memory
>     100000000-1ffffffff : System RAM
>     200000000-303ffffff : Persistent Memory (legacy)
>     304000000-43fffffff : System RAM
>     440000000-23ffffffff : Persistent Memory
>     2400000000-43bfffffff : Persistent Memory
>       2400000000-43bfffffff : namespace2.0
> 
>     WARNING: CPU: 38 PID: 928 at arch/x86/mm/init_64.c:850
> add_pages+0x5c/0x60
>     [..]
>     RIP: 0010:add_pages+0x5c/0x60
>     [..]
>     Call Trace:
>      devm_memremap_pages+0x460/0x6e0
>      pmem_attach_disk+0x29e/0x680 [nd_pmem]
>      ? nd_dax_probe+0xfc/0x120 [libnvdimm]
>      nvdimm_bus_probe+0x66/0x160 [libnvdimm]
> 
> It was discovered that the problem goes beyond RAM vs PMEM collisions
> as
> some platform produce PMEM vs PMEM collisions within a given section.
> The libnvdimm workaround for that case revealed that the libnvdimm
> section-alignment-padding implementation has been broken for a long
> while. A fix for that long-standing breakage introduces as many
> problems
> as it solves as it would require a backward-incompatible change to
> the
> namespace metadata interpretation. Instead of that dubious route [1],
> address the root problem in the memory-hotplug implementation.
> 
> Note that EEXIST is no longer treated as success as that is how
> sparse_add_section() reports subsection collisions, it was also
> obviated
> by recent changes to perform the request_region() for 'System RAM'
> before arch_add_memory() in the add_memory() sequence.
> 
> [1]: https://lore.kernel.org/r/155000671719.348031.234736316014111923
> 7.stgit@dwillia2-desk3.amr.corp.intel.com
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>


-- 
Oscar Salvador
SUSE L3

