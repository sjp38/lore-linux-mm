Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9048C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:06:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42BAE217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:06:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42BAE217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F4858E00C8; Wed,  6 Feb 2019 11:06:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77BC78E00B1; Wed,  6 Feb 2019 11:06:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61E5B8E00C8; Wed,  6 Feb 2019 11:06:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18F108E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:06:48 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l76so5557575pfg.1
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:06:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KdAjhSqA4Qa2x1JYak9IMHAIXHNwyjaoohHWyV1H2mQ=;
        b=qCTc3yoDSB7OOgpmzZd8EbNL1vMM0NSniRF5PrH4fOiMdgEcicoRucQUn4lt68U7mO
         V5qABfjRjHIiSYB24/Cgnwvb8yJFUvL3LFs1SWa5GAocxWSqOkeaFktiiYu951u1s9G8
         Qm71/DhOk7qJt0a1iWv8lhPHdJLSWJKBwQJ0aePPT5JshUkJiAcSEr7KB/lKml+mbtvN
         8jEiA7VRoe8ymySy3OVaeGOJGPhfyTOl7otMfujazP3ywQT7WpuLeJKQTFbbi1tBHknP
         Pd1OlmtnYo4+MbC44NGwX3bYo9KWtkuBoSmNXHEvo9AMIOfaAnSBPmSU/H8GBPT+UFIl
         g9KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYLN1FxVmQ9GNBJX3YN33WYGZP+lbiL8DrFalf7uRTTmD2Ffpqx
	4EvQcT+VWrXgNdR0stxKjYxQGOU17zSxYlkrYYGHpJpqDEm1iBBj1OD+0oTzr0kwtmcq9Ll+2fu
	AodBexzA9bm6EQccqWAap8VOJes3jukGLvK6SX3kCeTKllnklcJyT/1xanHNdq1dmRw==
X-Received: by 2002:a63:dc53:: with SMTP id f19mr2483199pgj.406.1549469207514;
        Wed, 06 Feb 2019 08:06:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYU04MUxWqTdbW3KpZmUGsH9yyn7OvzDLXU9Bp+VbTx1opterxhV4gk9cxBFcJoRV951gU+
X-Received: by 2002:a63:dc53:: with SMTP id f19mr2483124pgj.406.1549469206448;
        Wed, 06 Feb 2019 08:06:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549469206; cv=none;
        d=google.com; s=arc-20160816;
        b=d2U+uQMAVVi6Cuc5smuuIqis1OP2lgA4stH3X6npyi9EhDiYRVDGS4CG5LRS0b2RIB
         5tV2nPjWr+fq7ckaK/hqmdiXj2NFb8AOAofm96yB2OXQOeb8QBQZbnzfBQHp05Wme0Fk
         JkIFVUOFjc2h3UqOmRI6x9D4zVi0KiMs5FIorMnGf/dtgnQ62fh/pxwp0M4T5CUidyFS
         9fGaEhrjrkPvxQg4XVyCy/le134q1E5Vmoirz+lKkGbfEhyTcgaRq6pVlXgeSDb70aAg
         /9UFbGencUYcxuYW0WLLZMcR2t3yz3UzidiyVclhF+ZMhaeFw4TLULJrELBt6S/w+hAM
         gupA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KdAjhSqA4Qa2x1JYak9IMHAIXHNwyjaoohHWyV1H2mQ=;
        b=mowS3P2QZVDwCHzjryTMhDGeFfcuRDxf7kzWRgfxLooIDZgGjJaoNi2TP98tYK0lSN
         hx6QFxDhrxZNN659QWSFy2qdxcWmnq7e1LzzoYAIlTgQ9ZDL9S5BMc4HGzRoTEjJLYXS
         SdVFEQBQ9Ltxyj6Xo/aQ3eviYOIDycXyMB/9KX4a7UEhtNEBFBg1Puc346NzHDvjdyfa
         kyCqOhzDuv0rjf5rlc5O9WsgrVrYR0hIKFTeFFE/bqj96JoV8sCvvLj234UEVpsaE3ZP
         RPOwNks8uKV8LJuAwSYu0IPTUdV3cSFmyksAUbJR5ojEqpkE66D88RumlJ4GHOruPdKR
         suWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b6si3597942pgd.292.2019.02.06.08.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:06:46 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Feb 2019 08:06:45 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,340,1544515200"; 
   d="scan'208";a="142077354"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga004.fm.intel.com with ESMTP; 06 Feb 2019 08:06:44 -0800
Date: Wed, 6 Feb 2019 09:06:14 -0700
From: Keith Busch <keith.busch@intel.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 03/10] acpi/hmat: Parse and report heterogeneous memory
Message-ID: <20190206160613.GG28064@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
 <20190124230724.10022-4-keith.busch@intel.com>
 <20190206122814.00000127@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206122814.00000127@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 12:28:14PM +0000, Jonathan Cameron wrote:
> On Thu, 24 Jan 2019 16:07:17 -0700
> Keith Busch <keith.busch@intel.com> wrote:
> 
> > +	pr_info("HMAT: Locality: Flags:%02x Type:%s Initiator Domains:%d Target Domains:%d Base:%lld\n",
> > +		hmat_loc->flags, hmat_data_type(type), ipds, tpds,
> > +		hmat_loc->entry_base_unit);
> > +
> > +	inits = (u32 *)(hmat_loc + 1);
> > +	targs = &inits[ipds];
>
> This line is a bit of an oddity as it's indexing off the end of the data.
> 	targs = inits + ipds;
> would be nicer to my mind as doesn't even hint that we are in inits still.
> 
> 
> > +	entries = (u16 *)(&targs[tpds]);

Sure, I can change these to addition rather than indexing. I have no
preference either way.

> As above I'd prefer we did the pointer arithmetic explicitly rather
> than used an index off the end of the array.
> 
> > +	for (init = 0; init < ipds; init++) {
> > +		for (targ = 0; targ < tpds; targ++) {
> > +			value = entries[init * tpds + targ];
> > +			value = (value * hmat_loc->entry_base_unit) / 10;
> > +			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
> > +				inits[init], targs[targ], value,
> > +				hmat_data_type_suffix(type));
> 
> Worth checking at this early stage that the domains exist in SRAT?
> + screaming if they don't.

Sure, I think it should be sufficient to check pxm_to_node() for a valid
value to validate the table is okay..

> > +		}
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static __init int hmat_parse_cache(union acpi_subtable_headers *header,
> > +				   const unsigned long end)
> > +{
> > +	struct acpi_hmat_cache *cache = (void *)header;
> > +	u32 attrs;
> > +
> > +	if (cache->header.length < sizeof(*cache)) {
> > +		pr_debug("HMAT: Unexpected cache header length: %d\n",
> > +			 cache->header.length);
> > +		return -EINVAL;
> > +	}
> > +
> > +	attrs = cache->cache_attributes;
> > +	pr_info("HMAT: Cache: Domain:%d Size:%llu Attrs:%08x SMBIOS Handles:%d\n",
> > +		cache->memory_PD, cache->cache_size, attrs,
> > +		cache->number_of_SMBIOShandles);
> 
> Can we sanity check those smbios handles actually match anything?

Will do.
 
> > +
> > +	return 0;
> > +}
> > +
> > +static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
> > +					   const unsigned long end)
> > +{
> > +	struct acpi_hmat_address_range *spa = (void *)header;
> > +
> > +	if (spa->header.length != sizeof(*spa)) {
> > +		pr_debug("HMAT: Unexpected address range header length: %d\n",
> > +			 spa->header.length);
> 
> My gut feeling is that it's much more useful to make this always print rather
> than debug.  Same with other error paths above.  Given the number of times
> broken ACPI tables show up, it's nice to complain really loudly!
> 
> Perhaps others prefer to not do so though so I'll defer to subsystem norms.

Yeah, I demoted these to debug based on earlier feedback. We should
still be operational even with broken HMAT, so I don't want to create
unnecessary panic if its broken, but I agree something should be
immediately noticable if the firmware tables are incorrect. Maybe like
what bad_srat() provides.

