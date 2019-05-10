Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8328C04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 12:56:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2E9D2177B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 12:56:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2E9D2177B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 191276B0281; Fri, 10 May 2019 08:56:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1415D6B0282; Fri, 10 May 2019 08:56:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0305E6B0283; Fri, 10 May 2019 08:56:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AACD26B0281
	for <linux-mm@kvack.org>; Fri, 10 May 2019 08:56:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z5so4015103edz.3
        for <linux-mm@kvack.org>; Fri, 10 May 2019 05:56:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:in-reply-to
         :references:message-id:user-agent;
        bh=/6Zze3qXUGgsFeFUevlaAX/mtgmxc2dKqlNLAmBq2uI=;
        b=pwvEP9ttp4cjNyC7GfHdn1kEyj1lCrwU1rp3H+Re/cmf7R9xFgK1igM2a6U2TNsr3P
         BYLoWuf6OPe3Sv9xU7qrM9EqyHrxAJSzoIuZypZryGDlWkJdsft5xV4x4tjHvf1cR26R
         ogCQ2NRNngVWByD6NiKTAI6lCRk/J5TZzKJFW1n/Gk4LiQhZw7eV2qqMpBLDCmENILoD
         GnmE6SttAjigODCA7wNlcfjBeS4U+bcOl0o27YuTihKywfR1RUTeX+LgV9an47Uo6Mw7
         XtqGbhwYIXl8kbyRxBxqO80Fqj/91PRCID0ga9XU5q7BluAASo7i4gEGkYkDbEQncRFj
         BHtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXXgc4rJqc2Z53xA6XKHy8D8e54jlKt97XCuOckG7tmqcrA4mz0
	GOfbviFu0AEjOYmoEJNpbOmQVm2De/sr8lwqbMhVytfVf0ffxjqWe4lk42ixkMnuM8GIWcFKq/w
	o2MN3t5QsVr3xZ+tW6EeR3lCUMe4AL+Hg0vx47G/VCffUzdDf1nSt8pbInP/ZtRopYw==
X-Received: by 2002:a50:87f5:: with SMTP id 50mr10490243edz.58.1557493017265;
        Fri, 10 May 2019 05:56:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjzKBCAF5Fpa+69+9FWFZkdlj5ZbFLb9nKSeboWORanYIDpZmqfNOv0Zt2IEEVDkX1UFcz
X-Received: by 2002:a50:87f5:: with SMTP id 50mr10490141edz.58.1557493016078;
        Fri, 10 May 2019 05:56:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557493016; cv=none;
        d=google.com; s=arc-20160816;
        b=pHrHn1to2Q3bFzLd/CbOs6TTPdwehcJeGorBeLNyQCyS+dWV3cWG/vh0/j5Cu/18xM
         cmactCpQfz83p9N9FTtSaAkNvDeVlNtwfmOMhrSfDYs/f45LBQxiF6seuCV7zrPchbBs
         Uom/EVJwcE/U0wPD3MYEqUlpGjUqm+XQTitYBC1TK/2ZprEqVu2CAMhl4UYiyHAFeH7i
         I1AHaCkvPhy17Y2uQHk0SH68AGCIb0fpwn/YxbFJLosw1+w9/iHC06TaowVVZGRI03DL
         wMjd3laA45OM3GMa+bZpFpWfPP3oGEXiguzFLn12r0XlKc8frKg1eyzfJmpIpFeys2Ix
         O03A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:subject:cc:to:from
         :date:content-transfer-encoding:mime-version;
        bh=/6Zze3qXUGgsFeFUevlaAX/mtgmxc2dKqlNLAmBq2uI=;
        b=uarQOvXBc15W82SgBlk3Y9EfyJwujdChqFtrAf9jx/Q4pPBRGQhzct2Y/o2anoNwSu
         efkY0UlnT9vi/cpsZ5/TLZYrO9V0GDxOIxni36l1oeC6kcjPurO52SoI6BG27lvfoIke
         t+76zqGf/BbVQNZwk4mQChnGAH4Yrxq5cTyyy0AHVX1YMepvrlJXqI4km/dUdRuNq6hs
         gVQgAM4X2Zh14Ej6BnfmREcCzuzLheQWUwBy9gwq1vr8rdpOFwKrAlGZ3ZfPpvCSt0N6
         TH5WVMaHV2edeH5S9Be/M1wTVIaxcJx4X0vEQ7Saw3dAzFUXNOoug07FJElnjwwUcbxQ
         TDoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ot8si1422666ejb.275.2019.05.10.05.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 05:56:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 851FFAE2C;
	Fri, 10 May 2019 12:56:55 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 10 May 2019 14:56:54 +0200
From: osalvador@suse.de
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Vlastimil
 Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Pavel
 Tatashin <pasha.tatashin@soleen.com>, Jane Chu <jane.chu@oracle.com>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v8 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
In-Reply-To: <155718598213.130019.10989541248734713186.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155718598213.130019.10989541248734713186.stgit@dwillia2-desk3.amr.corp.intel.com>
Message-ID: <5ce1d8dfe8e485616f9ade30fade88a5@suse.de>
X-Sender: osalvador@suse.de
User-Agent: Roundcube Webmail
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-05-07 01:39, Dan Williams wrote:
> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> sub-section active bitmask, each bit representing a PMD_SIZE span of 
> the
> architecture's memory hotplug section size.
> 
> The implications of a partially populated section is that pfn_valid()
> needs to go beyond a valid_section() check and read the sub-section
> active ranges from the bitmask. The expectation is that the bitmask
> (subsection_map) fits in the same cacheline as the valid_section() 
> data,
> so the incremental performance overhead to pfn_valid() should be
> negligible.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Tested-by: Jane Chu <jane.chu@oracle.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Now that the handling is done in pfn/nr_pages, it looks better to me:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks



