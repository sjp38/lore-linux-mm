Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BABDC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 07:35:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 264462075C
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 07:35:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 264462075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A84A76B0003; Fri,  3 May 2019 03:35:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A36FD6B0005; Fri,  3 May 2019 03:35:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 925456B0007; Fri,  3 May 2019 03:35:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41A766B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 03:35:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a11so754637edq.19
        for <linux-mm@kvack.org>; Fri, 03 May 2019 00:35:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SF+uAzv/XpPuYpX92tjWcdP+Pn1trH19Oo2iEqPgjwc=;
        b=kWywmeNtb7qVcofTS2W1nbn0S/CNG/RHx2wWsAzqpqQYa8XCUfb673++k4m2JK1+v0
         vGI5D0KEMwAeHH4znMtHHZ5/A0e/xUQOdju3M/5poV9eNxrM97XfIC9onu26gMhxbrNH
         U4RccM89jJwXpoJU1qOlHiNLjugYuROAuiZOSU8evRQTlTmn7JsJY5STw+xORHNOIupd
         9T/7h6fSHjr0JMdznv9Ek47MgfGQ3g6Dw0qCS7Ix6x8Z7PPqmzaoT55gSkGwOn5PFfTV
         ji7dlm5p50FOWuKXvfypMVuxoB7c7Um7OHQfIj7e3NoynkjD4PRcgYqm0Ju/q/kOWLAC
         vAjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU53uCE8+dDBtkl456wcxkm3Nsnj5SO0Ry/BUriv+rkfYAC6Ku9
	14gwYmjXbdyPREQsFSkwbfIJHEWFn1DURNRZdpgB17+cZ5CXtvhkKEWmu+2RgitZrZAoRcCnNtB
	/oIL1NyrzdSlzE/u1TNnEpJ1OG1tE7B+S5MNQIgMoLkewUlxzTR5uQRxsrQKBp/3grA==
X-Received: by 2002:a50:8eb6:: with SMTP id w51mr6579992edw.34.1556868954835;
        Fri, 03 May 2019 00:35:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuDlCrzuCsudEfsYOEETV0PQBTsEm/N4jHsE1YfNVLOvPPV1wN1wKneeHAg3jZiC7Il+qQ
X-Received: by 2002:a50:8eb6:: with SMTP id w51mr6579934edw.34.1556868954071;
        Fri, 03 May 2019 00:35:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556868954; cv=none;
        d=google.com; s=arc-20160816;
        b=ur/o9bcmp4IVaBvUgFbblYQIQZ20pOKv4YIYmD9y3oUKmU/KtpkDsdaDbwj4lI94x5
         mPleo00/wcgOLcs++HUiloWpidVXibz8EczWHdQM6lr9MPtTYeJ/52lSZ29wetzVb4N0
         394CuxUvRr4i78MEdMdqDN9p3vcoem1jQ8EvA9EHiJsXxEM+2+CuHdLzlEXfgxUapaQS
         SuKOkclyUSm3t3B/LwUBNaD3tUDu4Pric0pQIVsEeDWC4QACFpaV+WWhVR36dr0+BIOS
         sq87uZuV21CqrQtZZr+PLWz5rk5LYJdGGf52d/Q3P3sYqoKsbSuydS8+UbPICaje3yp8
         Jg4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SF+uAzv/XpPuYpX92tjWcdP+Pn1trH19Oo2iEqPgjwc=;
        b=Fovamsnl70Ay8Ov2ww0SiETs8kE6p+UkyfnbtZ733RAMTvySFhPk5okSp5OFWd7l8G
         E9A+97CBiNgm2JhOLSuaOUXhwdgZQq9xgqwoQspzIaQpv3DBc5WzPXNij9Mtb9TX181s
         UtFZPbX4s2GiaEF4X2lmg18ZVq1Y0QOXiXQdmy5IcQfA2v5llZ4xnBe9hO8AwJ6W8IBq
         NEJqH98TO5zo8IfDHJ66Fxlf6km9UpI7x2pOOfjr/VlMTRbSR4dlnxymOv3hTZitQdXx
         wvJ79/pkDOoqPrQMbt8wpyMBugCLwinqz/g8mANEhA8OznE3JE35J1YUCs0madiyntFW
         yvSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b4si560315eja.191.2019.05.03.00.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 00:35:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8E529AE28;
	Fri,  3 May 2019 07:35:53 +0000 (UTC)
Date: Fri, 3 May 2019 09:35:50 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 01/12] mm/sparsemem: Introduce struct mem_section_usage
Message-ID: <20190503073550.GB15740@linux>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677652762.2336373.6522945152928524695.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155677652762.2336373.6522945152928524695.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:55:27PM -0700, Dan Williams wrote:
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

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

