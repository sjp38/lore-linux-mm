Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF3A0C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 09:07:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D93C218D3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 09:07:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D93C218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA97E6B0005; Wed, 24 Apr 2019 05:07:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E58E66B0006; Wed, 24 Apr 2019 05:07:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D70F76B0007; Wed, 24 Apr 2019 05:07:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A60A6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 05:07:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f17so4464152edq.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 02:07:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3nlN3+e2NozLbveQ0O44PDb0j5KzqCCSsy/ZcbssLMk=;
        b=o4IZ+7ZnThXJcTv7iA6kfJlBLk2r1kx50vK67D2oeFsVon9kxzSHRzMYm68A413oYk
         GR6yrBhiEyp0WwiQjEyQEnuZlhrko8sEp31T992BPNkCFklW31k6UVOssZ9cvUZbef2r
         xmN6Iu7+fzzKKBLARi03yf5hlwWgnxPOn9MvVSd1XehR5Vqob8cI2M0pTUGb7W3Yiv3q
         E9QsIFJ3mIKqnZkxRRcae7NpmVfr/HT7hz/zd1hg97vos0DyH253iCfvNweho3THFJyw
         lLOVh7BSkJwQgscq/8+g27zQymwX4eww+zu7JWZZJfYwdT4M1FejWy0itF9XQlYx7gTO
         i5+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVy1CLl/SbiPpU5DqmbWAULzaOnTfWxNwDMxYHnNcwD9vr5MwYX
	k5xvYMDt/3d5CVoFq9Hid0Axk+bC2fGcoVyNc60TJ2kZ+4ucLW6DLIkAiYOYnvDb1vIjGtvJGzf
	t1+//K5+zg7AQJkl2ry8bXFhJ5xuzP5fN8s8EWNdjQ1zjkqgmFy9Rui2jdi/AJenIHQ==
X-Received: by 2002:a50:9317:: with SMTP id m23mr19601662eda.114.1556096840101;
        Wed, 24 Apr 2019 02:07:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylx5PeI6eHMQJC+dL2d54eDBq+NbAyUrpbLymDnnIA6ZiT87VSJ4m9mYAmmr1tX+qtqsT0
X-Received: by 2002:a50:9317:: with SMTP id m23mr19601614eda.114.1556096839271;
        Wed, 24 Apr 2019 02:07:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556096839; cv=none;
        d=google.com; s=arc-20160816;
        b=S+jull3giVjqFqoF0ZH7yjX8fYhRCrGK/0A66jO4WnqnhU3DlE40iIUwt+jUcOFJML
         0saE+gXbg3NbVfY9smUIa3Cr9qmVm7W85IjVe8z+fANuBoh5eG9sNu5kd1Cov1FwWc6d
         /soMC9421YDFfUg+LLD89SFuiaGGEobVPBcTNWPTHYG4y6ljfdJfXW2gHyeOP2ePUuje
         NnAnO9A8QRVd6wCr7X7lqhhCxctz7ij9JajEICQYvtb5xhzgdHZBlZ3YUuHRfu3u5c/e
         a9U/SuCCUjiwMgcKnr3o42cbrCPiRiSttqUgZgaB96vaKR8zLsfxlh43LUtny2n+Bp+4
         nszw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=3nlN3+e2NozLbveQ0O44PDb0j5KzqCCSsy/ZcbssLMk=;
        b=gjtOh0FLjq+YvENRE1X+zHoMp96nPtb/sPA8gvBJ0tGSkqNnFSu8YEG0jnOi6F1CMD
         /yrkjLEHbKa9c61Y4XzjtnVr8o/bqGaRexqlP7SxQWYY15Y9yeqNGj6VYd4ZePK7BF5C
         J3+82C+vPGRqwvg4Ssnbct05xNcZAMhQ/tDQ6n9HJSarWB4DT/i793eAgN9faHZjcuKb
         QAaXXiNQ6A05b/sIYOhKasJHuiujdkIj0yDB0vWTlhASWSSsRxksbKO2eTY+pbTmJQWz
         nEKXDPwFFv3T6TuQKON48n+2lPGhImDThu9UqAofVTb9OhNPUS9DP8vFueTzaUXaX4fT
         O4JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x2si2135091ejw.358.2019.04.24.02.07.18
        for <linux-mm@kvack.org>;
        Wed, 24 Apr 2019 02:07:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3027780D;
	Wed, 24 Apr 2019 02:07:18 -0700 (PDT)
Received: from [10.163.1.68] (unknown [10.163.1.68])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AC4323F5AF;
	Wed, 24 Apr 2019 02:07:08 -0700 (PDT)
Subject: Re: [PATCH] arm64: configurable sparsemem section size
To: Pavel Tatashin <pasha.tatashin@soleen.com>, jmorris@namei.org,
 sashal@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, akpm@linux-foundation.org, mhocko@suse.com,
 dave.hansen@linux.intel.com, dan.j.williams@intel.com,
 keith.busch@intel.com, vishal.l.verma@intel.com, dave.jiang@intel.com,
 zwisler@kernel.org, thomas.lendacky@amd.com, ying.huang@intel.com,
 fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com,
 baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com,
 catalin.marinas@arm.com, will.deacon@arm.com, rppt@linux.vnet.ibm.com,
 ard.biesheuvel@linaro.org, andrew.murray@arm.com, james.morse@arm.com,
 marc.zyngier@arm.com, sboyd@kernel.org, linux-arm-kernel@lists.infradead.org
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <7f7499bd-8d48-945b-6d69-60685a02c8da@arm.com>
Date: Wed, 24 Apr 2019 14:37:11 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190423203843.2898-1-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/24/2019 02:08 AM, Pavel Tatashin wrote:
> sparsemem section size determines the maximum size and alignment that
> is allowed to offline/online memory block. The bigger the size the less
> the clutter in /sys/devices/system/memory/*. On the other hand, however,
> there is less flexability in what granules of memory can be added and
> removed.

Is there any scenario where less than a 1GB needs to be added on arm64 ?

> 
> Recently, it was enabled in Linux to hotadd persistent memory that
> can be either real NV device, or reserved from regular System RAM
> and has identity of devdax.

devdax (even ZONE_DEVICE) support has not been enabled on arm64 yet.

> 
> The problem is that because ARM64's section size is 1G, and devdax must
> have 2M label section, the first 1G is always missed when device is
> attached, because it is not 1G aligned.

devdax has to be 2M aligned ? Does Linux enforce that right now ?

> 
> Allow, better flexibility by making section size configurable.

Unless 2M is being enforced from Linux not sure why this is necessary at
the moment.

> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> ---
>  arch/arm64/Kconfig                 | 10 ++++++++++
>  arch/arm64/include/asm/sparsemem.h |  2 +-
>  2 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index b5d8cf57e220..a0c5b9d13a7f 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -801,6 +801,16 @@ config ARM64_PA_BITS
>  	default 48 if ARM64_PA_BITS_48
>  	default 52 if ARM64_PA_BITS_52
>  
> +config ARM64_SECTION_SIZE_BITS
> +	int "sparsemem section size shift"
> +	range 27 30

27 and 28 do not even compile for ARM64_64_PAGES because of MAX_ORDER and
SECTION_SIZE mismatch.

