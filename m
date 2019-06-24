Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDAA0C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87A3220657
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:54:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87A3220657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16DC16B0005; Mon, 24 Jun 2019 13:54:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11EF58E0003; Mon, 24 Jun 2019 13:54:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00CAF8E0002; Mon, 24 Jun 2019 13:54:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A48956B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:54:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so21424205ede.23
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:54:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZohiUrhuYIkVXfTu1oWHvtXLL9Y+IqHd/RNLxnTAXm0=;
        b=J0x/iK4FociVHgVZBa+MQ/KqNnVuquob0xIF8Ls5tJ1JEUqTC103JX+I5b6RrU5Zjv
         GCOh1OYaglhNZ9EKPEvUlZxcOHu7yU7jeO5cqJ76jjTimP8zjRUiRjIVgHIwpsZkRRWv
         JdaIaAJ8UzNYsEFUYCypluQRmpqva2P/sGxFLBWfOqSF7IesM5xL2CPJZ/q+peXpa6c0
         Lx6C6666jxhG0XUXgEEh0NoBH/AcOAGSQTIc0ayb5f5Up2VjQHP9unNbSU2+A+ZAMwnW
         R2/ezSrq3BxNYs+Sz6ofh9dPxQnlvt3KJ8WT2jKYGKRxuHAUg3e6oakJ1Xpn4wvjuup5
         RixA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWGpbsTGXGQ/AY9QRx3ROpfzOkjwDLejM8njo9eZznXYlvOUQcz
	rChLug2tWeiv5KZdWTVzwCy/BMjOukqfk3JVs3ElpAeGbW+b+O/jfDOFmr2fTFYQtetG9rQal1w
	3HUA2BtxFgtrQwJv1o4vKAxazmc8F8f1foSSmO31HFAxVN4LPvnKpkZRztjG8pRgwjA==
X-Received: by 2002:a17:906:2111:: with SMTP id 17mr6127600ejt.75.1561398873223;
        Mon, 24 Jun 2019 10:54:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxg0c0VzUMF01aBrDtxXhYxMnB78d97RLKG8YxotGqUdeB3KLhO9MkZfizbts2xDx29evtW
X-Received: by 2002:a17:906:2111:: with SMTP id 17mr6127551ejt.75.1561398872382;
        Mon, 24 Jun 2019 10:54:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561398872; cv=none;
        d=google.com; s=arc-20160816;
        b=FASXxilCsQxZG9ic/YzWs3WqRFeDy9xzuU0UlprFShngGV9DbxGHuNyGWDEYDgVoNh
         w2NocjNe1qHFs16LIlWOWvgHofVUnpg+XNLSo2duotQ2rjnapLJx+u6AugTnFCuVaPn8
         nBWb2AUx7WSMYcmeEn4ObadhlDZxucfBOTIrQn1ytfARF4Ms1Ft3587jgHrEcnyS16xc
         KGifs1+2s09q8iO7I3QnhWN1UnInSgUPGFMOdQFX7IHUHpRE9FOD+/0XQDpOn+FFPdFc
         H0vJxgb4MxWJe65co9kPoJL4TGZ9m9Gk29LMCdPZscx8/e9FDFApASvxQsxH8+JwhRRN
         tCAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=ZohiUrhuYIkVXfTu1oWHvtXLL9Y+IqHd/RNLxnTAXm0=;
        b=ZEXEy3VJQI9ORYkvMLfX58Hjd7bjssesZ063Rm4jotDgfDrM+Iy3gaRWSw4BQKMH1g
         yKvNt2MlWG11M/ZveveR+QpNW8kaNI3k4OI+Vyl9S/4OKl9hQHlzHtgZCFSIgOR+i1oO
         s25gy7igGWR/wGuaz8bje5U92uAs3W+iIC8LYKauFqcC8cIoY3gl97cyI7iphd2QvwbG
         /XP693IOwgkcqB7QWwKzbQJewXcGDKnTsAAj/AgBr5igW2BGe3qpJjwwgGJ7GeiTFo6w
         O6/TzqsiDPDAVmfi3Gus75qEpRplKVoEEK84TRzZzzjmO7pVsfbgeVxeOmuGTDtBWJhy
         CxZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e49si10720821edb.184.2019.06.24.10.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 10:54:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D36E8ABE1;
	Mon, 24 Jun 2019 17:54:31 +0000 (UTC)
Message-ID: <1561398869.3073.4.camel@suse.de>
Subject: Re: [PATCH v10 02/13] mm/sparsemem: Introduce a SECTION_IS_EARLY
 flag
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Qian Cai <cai@lca.pw>, Michal Hocko <mhocko@suse.com>, Logan Gunthorpe
 <logang@deltatee.com>, David Hildenbrand <david@redhat.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
  linux-kernel@vger.kernel.org
Date: Mon, 24 Jun 2019 19:54:29 +0200
In-Reply-To: <156092350358.979959.5817209875548072819.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <156092350358.979959.5817209875548072819.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-18 at 22:51 -0700, Dan Williams wrote:
> In preparation for sub-section hotplug, track whether a given section
> was created during early memory initialization, or later via memory
> hotplug.  This distinction is needed to maintain the coarse
> expectation
> that pfn_valid() returns true for any pfn within a given section even
> if
> that section has pages that are reserved from the page allocator.
> 
> For example one of the of goals of subsection hotplug is to support
> cases where the system physical memory layout collides System RAM and
> PMEM within a section. Several pfn_valid() users expect to just check
> if
> a section is valid, but they are not careful to check if the given
> pfn
> is within a "System RAM" boundary and instead expect pgdat
> information
> to further validate the pfn.
> 
> Rather than unwind those paths to make their pfn_valid() queries more
> precise a follow on patch uses the SECTION_IS_EARLY flag to maintain
> the
> traditional expectation that pfn_valid() returns true for all early
> sections.
> 
> Link: https://lore.kernel.org/lkml/1560366952-10660-1-git-send-email-
> cai@lca.pw/
> Reported-by: Qian Cai <cai@lca.pw>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

[...]
> @@ -731,7 +732,7 @@ int __meminit sparse_add_one_section(int nid,
> unsigned long start_pfn,
>  	page_init_poison(memmap, sizeof(struct page) *
> PAGES_PER_SECTION);
>  
>  	section_mark_present(ms);
> -	sparse_init_one_section(ms, section_nr, memmap, usage);
> +	sparse_init_one_section(ms, section_nr, memmap, usage, 0);

I think this is an improvment, and I really like the idea of leveraring
a new section's flag for this, but I have mixed feelings about the way
to mark a section as an early one.
IMHO, I think that a new "section_mark_early" function would be better
than passing a new flag parameter to sparse_init_one_section().

But I do not feel strong on this:

Reviewed-by: Oscar Salvador <osalvador@suse.de>


-- 
Oscar Salvador
SUSE L3

