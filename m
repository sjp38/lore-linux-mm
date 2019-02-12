Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F56AC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:47:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F18B9222C0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:47:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F18B9222C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 795378E0002; Tue, 12 Feb 2019 16:47:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 741378E0001; Tue, 12 Feb 2019 16:47:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3288E0002; Tue, 12 Feb 2019 16:47:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1886B8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:47:56 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h70so176298pfd.11
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:47:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4NnKV1ncEMyS3QDwhrnAHPQEstnwlF9jBRrcDHz5huE=;
        b=B9339tBw8a8pWqyBSucsijCSTCWIaafK3nPY13Yde0XR3wbqWEf+V+KiEOOcOdUP26
         jZD3wkXyibvhIhVsfaedSLGODdmhRXWWPdetkiZlcLwKlQeP1BqC8CqemVhQ7qVOge/V
         nDJi//kDFLLkBDZKBtHlaxT/Iayu4ISQhhIjsDF/uTe8xFZkgjzy6RkV1lqYdv2P0Mg3
         xB27dePxq8HXl7ccaJu60o7eMHcUeCK16PVg27GW0PLenBwyYqIyOnSmgPSJZs8CZ8eZ
         W896oY3qQ679wVOE1FFDt0K7dSQKCW09N50wDx+3HWeD19sty6z21hjFq325bjag2gKm
         yZqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaESicvqhb+0QbcNKo3Q2u5TZXvf2nyGbl7lm6EAUEeDwk0bf/g
	Oeht9ow2I9GGUlypSXeHSn9JMMoZraTFnr5eLL6/7XOlW4bU2QBOVzTttDcAsbvjXTgwxQlh7bF
	iJhVnHhlCBBPek06ITpbO8cKqH5kPC0lfRDAu0S4kMPb43mgHC8jo87cHMRy2oeYG8Q==
X-Received: by 2002:a62:1e45:: with SMTP id e66mr6035106pfe.152.1550008075788;
        Tue, 12 Feb 2019 13:47:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+bFIqAdYF1hHjsrfKghvn0rcEv4f21Trw+1kyLe6b5iVtACI+8ik4vPNcdxdy00+YrDyC
X-Received: by 2002:a62:1e45:: with SMTP id e66mr6035059pfe.152.1550008075077;
        Tue, 12 Feb 2019 13:47:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550008075; cv=none;
        d=google.com; s=arc-20160816;
        b=JTRwi24FfiEZCwVG9MKLEEnLPZo/H6fpJdu+fRJ6EohBV5/DgpZbinXoIayF9zdhbv
         skCun74U0wSRxPGcGNANTI4rf5V4wEn8DIGNMbN5hdmRb/2gqV1BCJUgTxTANzsbiupZ
         uu3HjqriwBSUmQ/Z4gN7AEN1sf68hIUEMsIDnGrCnYkAqD8ViKjjVuK744Es4pEIGLFQ
         nnjVjrfOk/rib/2faHpqbObVJ6FfyPl/kYoxxTMUocRqmmnuVyzs0cdYUbCDeLnvMn9t
         FgjrEU8v43FREgWqnABDqGVMZc2TvxmVEglp+rN6nq+4a/8hOiY3nxofViV/emw9lXFu
         RBMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4NnKV1ncEMyS3QDwhrnAHPQEstnwlF9jBRrcDHz5huE=;
        b=MjsV7P4z2rn9cvlpQ88oNwjx1Tly58KxStMwXCXZBPoTEuiADLwMgqrla1qWXEwuUd
         97vAlNGGFmsTS/CYMdve5jk9UHyyA7jtjxKIcuvWKoghMh4XraWJSAtbIPX5DXrcfEyv
         MEte7MjKsZwXmBrW9EYHZ24oul+1U0VAeUAIghwHJCLVQAqY/FlQB0PJvnJ6ynRcIZuc
         KO7j3H0+REVZd1ll6agOMLK1r4slJ8I8VfyUbvxcPB7Te9SER3gT/y7eH8y0oG8GdQ7x
         SjIpEBQGE7Oo0Vi/pciXRadubqQiecryOpA5sxbsCTvROxt1HOacc94CjeKO/ZMtR+KV
         hyqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j4si7075323pgc.186.2019.02.12.13.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 13:47:55 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Feb 2019 13:47:54 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,362,1544515200"; 
   d="scan'208";a="121941465"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga007.fm.intel.com with ESMTP; 12 Feb 2019 13:47:54 -0800
Date: Tue, 12 Feb 2019 14:47:36 -0700
From: Keith Busch <keith.busch@intel.com>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: linux-mm@kvack.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxarm@huawei.com,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	"Rafael J . Wysocki" <rjw@rjwysocki.net>,
	Michal Hocko <mhocko@kernel.org>, jcm@redhat.com
Subject: Re: [PATCH 1/3] ACPI: Support Generic Initator only domains
Message-ID: <20190212214736.GG6176@localhost.localdomain>
References: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
 <20190212164926.202-2-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212164926.202-2-Jonathan.Cameron@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 04:49:24PM +0000, Jonathan Cameron wrote:
> +	case ACPI_SRAT_TYPE_GENERIC_INITIATOR_AFFINITY:
> +	{
> +		struct acpi_srat_gi_affinity *p =
> +			(struct acpi_srat_gi_affinity *)header;
> +		char name[9] = {};
> +
> +		if (p->flags & ACPI_SRAT_GI_PCI_HANDLE) {
> +			/*
> +			 * For pci devices this may be the only place they
> +			 * are assigned a proximity domain
> +			 */
> +			pr_debug("SRAT Generic Initiator(Seg:%u BDF:%u) in proximity domain %d %s\n",
> +				p->pci_handle.segment,
> +				p->pci_handle.bdf,
> +				p->proximity_domain,
> +				(p->flags & ACPI_SRAT_GI_ENABLED) ?
> +				"enabled" : "disabled");

<snip>

> +#define ACPI_SRAT_GI_ENABLED     (1)		/* 00: Use affinity structure */
> +#define ACPI_SRAT_GI_ACPI_HANDLE (0)		/* 01: */
> +#define ACPI_SRAT_GI_PCI_HANDLE  (1 << 1)	/* 01: */

It looks like you're reading reserved bits. My copy of the 6.3 spec says
PCI Handle is 1, and is set in Device Handle Type field, not in the Flags.

> +/* 5 : Generic Initiator Affinity (ACPI 6.3) */
> +
> +struct acpi_srat_gi_affinity {
> +	struct acpi_subtable_header header;
> +	u8 reserved;
> +	u8 device_handl_type;
> +	u32 proximity_domain;
> +	union {
> +		struct acpi_srat_gi_acpi_handle acpi_handle;
> +		struct acpi_srat_gi_pci_handle pci_handle;
> +	};
> +	u32 flags;
> +	u32 reserved2;
> +};

