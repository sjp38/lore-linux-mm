Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7A5BC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:28:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7393720663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:28:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7393720663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E9578E0003; Wed, 26 Jun 2019 04:28:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C03E8E0002; Wed, 26 Jun 2019 04:28:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F17438E0003; Wed, 26 Jun 2019 04:28:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A47D18E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:28:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so1999288edv.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:28:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ph9MwRYy+Iz1pQfa4GCAiuf2ZMuKsfRHps1MNfPOxQA=;
        b=o5S2snlmESmqwDXHJ+N8buatiUZKt/zgg/qv0XUtJ5suc1nUy+OhFnFDnlOB/87mpJ
         k7HYWm488iFgk84hfxuHzO2Br5IToCVfaBNNML23QHBjZe31gyRAhn4JbpwmVBMJ7Yci
         e3QFc8ORjeULaSQz5oLJNUZzKc92da5tEuGdG27412BEOmEtIg4gye5KA/88LKKTlFz/
         9UjRLmJPmLH4R+4IZcKQ4y3d6La1LgAAeHQ5UcGL1cnAPwKMWwVbB9kFTZ8my4/5hPvf
         wP14RaKo9J4FvJEv2yoMGUbkc0VcB2UvMu1kcGFIamd1BFhNS4nQWxARTvTF1AWrpfOF
         oUJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU079HO3d9/lqr9mxvQyS8asBdOyJkCQMloAsKpS51iDTpXebCG
	SNQH1XCXFC/fWdE63ca2Lb5cu4NqdrJVCMzszYyJD1+tdZ65bjwwGJJV3Lnpy1GyU38A1E8J5el
	/+W8HyFmzB5lmXGRKFGAtabLf/sRRoN+6FcdoSFK1EOPVOBX6a2PG76n+hsb2pFo7lQ==
X-Received: by 2002:aa7:c98c:: with SMTP id c12mr3532225edt.225.1561537680242;
        Wed, 26 Jun 2019 01:28:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwnnyGPflmqMXoSjgfZ+PARcsBwIti/vfzLwguCh3Al4O/USPSJmmA0+xgQGRX7C5GBDB/
X-Received: by 2002:aa7:c98c:: with SMTP id c12mr3532175edt.225.1561537679448;
        Wed, 26 Jun 2019 01:27:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561537679; cv=none;
        d=google.com; s=arc-20160816;
        b=L5yGBd1ZbZsMPcgxOFJQexxCp1Eo11lQ4TNVPOdn+2KUKqgpLZCAQfz7PxUsH8c+Gy
         7c4YYnZ3jo+JGz/UfIgWuaySSBf6iYhVirUb1iZuLv+qjcPIiywdfOgtNb5699keciHi
         QecK8O6mrLtZq2ADCGCjWPbOs8DatABgPxqO1VpihVzOl+9AwxJMHHDp0pA82HQ9DYdr
         BY38IuIq1/k7JDpjNxM6HOEBSB1zBCB5/wspHtWyqQ7M1b38DuozSyJOobOvu858Xomd
         r0uohHwnuFATs8m5+QhEUwRBhbUfNeb7m7PKK/EIaOoUavA955MCYAkyO6IbgiFqgG8V
         typw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ph9MwRYy+Iz1pQfa4GCAiuf2ZMuKsfRHps1MNfPOxQA=;
        b=nzBq4i0kacv0a04vVszF2vTQ1aYOmVyPh3U3lz4wrgGqcAIjTxFMBwEonmukpPolQr
         jlA14p4pp1gjRGgB/f7EzqK+9bunUlcS+fsuGipBOIRAXYXlPWHvF70M8Ua/S4wPSCE9
         iqI1dSQ17aM++rxQKwDZU+mRu7NAl4pY2xBhsdmm0DeMYgXfpu0QvTm1ChLF9uv/VTEr
         DMTcTjWwItGk9vvEUZ4lC9bPVZSz62aL0Dh1euHUbomWRvz05AQJ/wimxnxB2/FHqaeO
         EldEL+gZgZ842lRlm3bEWH8uNnWBcoKuyoW1mbsk9U7TbYlA8MdGWrOE81yd5JHtbpLK
         6u1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i21si2721119edg.433.2019.06.26.01.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 01:27:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AD0FBAD7E;
	Wed, 26 Jun 2019 08:27:58 +0000 (UTC)
Date: Wed, 26 Jun 2019 10:27:56 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190626082756.GD30863@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626081516.GC30863@linux>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 10:15:16AM +0200, Oscar Salvador wrote:
> On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
> > Back then, I already mentioned that we might have some users that
> > remove_memory() they never added in a granularity it wasn't added. My
> > concerns back then were never fully sorted out.
> > 
> > arch/powerpc/platforms/powernv/memtrace.c
> > 
> > - Will remove memory in memory block size chunks it never added
> > - What if that memory resides on a DIMM added via MHP_MEMMAP_DEVICE?
> > 
> > Will it at least bail out? Or simply break?
> > 
> > IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save to be
> > introduced.
> 
> Uhm, I will take a closer look and see if I can clear your concerns.
> TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
> yet.
> 
> I will get back to you once I tried it out.

On a second though, it would be quite trivial to implement a check in
remove_memory() that does not allow to remove memory used with MHP_MEMMAP_DEVICE
in a different granularity:

+static bool check_vmemmap_granularity(u64 start, u64 size);
+{
+	unsigned long pfn;
+	unsigned int nr_pages;
+	struct page *p;
+
+	pfn = PHYS_PFN(start);
+	p = pfn_to_page(pfn);
+	nr_pages = size >> PAGE_SIZE;
+
+	if (PageVmemmap(p)) {
+		struct page *h = vmemmap_get_head(p);
+		unsigned long sections = (unsigned long)h->private;
+
+		if (sections * PAGES_PER_SECTION > nr_pages)
+			fail;
+	}
+	no_fail;
+}
+		
+
 static int __ref try_remove_memory(int nid, u64 start, u64 size)
 {
 	int rc = 0;
 
 	BUG_ON(check_hotplug_memory_range(start, size));
 
 	mem_hotplug_begin();
 
+	rc = check_vmemmap_granularity(start, size);
+	if (rc)
+		goto done;


The above is quite hacky, but it gives an idea.
I will try the code from arch/powerpc/platforms/powernv/memtrace.c and see how
can I implement a check.

-- 
Oscar Salvador
SUSE L3

