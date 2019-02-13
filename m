Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A68BEC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:44:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61990222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:44:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61990222BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3E748E0002; Wed, 13 Feb 2019 10:44:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEDEF8E0001; Wed, 13 Feb 2019 10:44:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D91B68E0002; Wed, 13 Feb 2019 10:44:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 959A38E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:44:25 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s27so1951897pgm.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:44:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=vptJqCx01N81UCMUpXbc3IouR7pmhqQUEo/gMvLEEcg=;
        b=BxwsEpt7dxyn9tff+hjK57Xo4MS+Q5jZdwro3FOF65Ifd422acCpwZcdBbc3niiT7D
         9dbRE5Dr0oVWDpA0oKaRkyyBfstX9Cdx6aRb04C/Gr9N13VTWd7QwqMq59dDoQM/YekF
         bgMtgHtU5lYjzAqSTBN4/W3HNAzWuyFVGsARUHwFzCpCfYNzaSTLmcWFMjRfAVWDEKJN
         Tg10JV96sCTpS/5J/2+8lOSg9cEawAL9z7THXophKw81mZshC93tZT4pndeMNh/0ODnE
         Ac1yNZXJpggO68RwJJCap76NxCaSpsS5rXDESYVwnDLwL6Sbjb2mOs9Uxv/EBmywcrk4
         E2qw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZOzAUTGO27iMI8R2TjP+smXlJBCir9uSLlUekGlpSJfPgRMbon
	DCxT6kpXKybKiHr1avaowm74dQxBhCIqZKsdZ3fKpPG/OTizloxZ2j1S9qtM/WM3wxdQR4Z7nfe
	I+bSY7kDaaFbkS1hx9OnowpBF1IiQ+f+eK/LoNJSrmB904LcZGMeCuGeOkkEL0aOX5g==
X-Received: by 2002:a63:5902:: with SMTP id n2mr1006617pgb.354.1550072665290;
        Wed, 13 Feb 2019 07:44:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZSIrVeeRpJghDJviQCrOfyuhV1TqU3AOUCoe0vzHVv2MYb+VFjqnPeVVW8j7gflOhvYlHc
X-Received: by 2002:a63:5902:: with SMTP id n2mr1006580pgb.354.1550072664666;
        Wed, 13 Feb 2019 07:44:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550072664; cv=none;
        d=google.com; s=arc-20160816;
        b=XE5T2lg9RGGev+vPeB5TAA8/UISDZaWRT1+H8Gw3n1havqQF+Gvke8E83EpDzF4lm/
         In86pbEhvyBuOA1/qIDfb2FrBTXdBIBbKjS/QK3daK5IEwgUW0cxcnkUk+cv9Wjd06EP
         4TqZnbZtjNRxuIvl1KklRI7s4wueVFMOv0ZD95Xjz1sTrgxvqbsoLpzNrjZdMtsM1vUQ
         1YFL+QPHGZ4K+dVaR5TDddJJ5FDH3V5RadNz20azVhuIRg9TzT97yXLGsoLFeDbo4Dab
         jKemfowZ1aE9CU46EV2XV1UhCEA2Vq4RmEhYLjZyEgj608VLh7xaI0UbayowSrqJT44E
         3SzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=vptJqCx01N81UCMUpXbc3IouR7pmhqQUEo/gMvLEEcg=;
        b=nbZwdt+DnNCsecKQBfyFsL9VnUsoLYLazWsNcHxy5XS0uivu4AXhq0WTgw74JuTLuB
         2Lrmh31KUMB8N4lMWi3WsX02OonwZX3CwHkgBq1U83W2/zSkBGyOc2MqeSND0i4BcNLR
         uoY3L6jtjbyjfOaLeWTvohgH+yM57t6ZgxK5/MRfG0Hz2tMWGgaAwkubpudMpITTKBsy
         ILF7GsRKOZhK7DdKQNAbchR5dFQVUfGnaNCxYl5cjHrPCgNHZXabXjmrFTL4+8k2Yf5e
         fLb/oNIfe2df8Fj8Yg7vdAg2DFERojfsSgNGSJb+bPa8PCShJrOTcM0ESdR6j+gXBg7J
         9OxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m39si16808390plg.315.2019.02.13.07.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 07:44:24 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 07:44:24 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="143943710"
Received: from pmmonter-mobl.amr.corp.intel.com (HELO [10.254.87.236]) ([10.254.87.236])
  by fmsmga004.fm.intel.com with ESMTP; 13 Feb 2019 07:44:23 -0800
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: mhocko@kernel.org, kirill@shutemov.name, kirill.shutemov@linux.intel.com,
 vbabka@suse.cz, will.deacon@arm.com, catalin.marinas@arm.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <7f25d3f4-68a1-58de-1a78-1bd942e3ba2f@intel.com>
Date: Wed, 13 Feb 2019 07:44:24 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/13/19 12:06 AM, Anshuman Khandual wrote:
> Setting an exec permission on a page normally triggers I-cache invalidation
> which might be expensive. I-cache invalidation is not mandatory on a given
> page if there is no immediate exec access on it. Non-fault modification of
> user page table from generic memory paths like migration can be improved if
> setting of the exec permission on the page can be deferred till actual use.
> There was a performance report [1] which highlighted the problem.

How does this happen?  If the page was not executed, then it'll
(presumably) be non-present which won't require icache invalidation.
So, this would only be for pages that have been executed (and won't
again before the next migration), *or* for pages that were mapped
executable but never executed.

Any idea which one it is?

If it's pages that got mapped in but were never executed, how did that
happen?  Was it fault-around?  If so, maybe it would just be simpler to
not do fault-around for executable pages on these platforms.

