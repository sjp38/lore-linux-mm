Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2224BC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:50:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE02C21773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:50:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE02C21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B6B26B0007; Wed, 24 Apr 2019 06:50:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 866746B0008; Wed, 24 Apr 2019 06:50:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 755146B000A; Wed, 24 Apr 2019 06:50:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD566B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:50:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o8so9636145edh.12
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:50:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QDNP03AQGb24+LbcbcF7AUvAIcDzscwdInH9nGdezrE=;
        b=TpKjpV9jKZNduOZAMcHIangO8aFptuieJ9VGhGGyAdunYL2FpxHb8JweY1I6KcH2sh
         xhiNjDJ/ch7SkYtx5rkJPibhR0BIaUsWeBUxv0tCcnKgj2fVWGeoNsPK8IXZelO5ecTc
         wnx44dE3a1wXoFwbYM/CHfgdlNdw+2KJ0wEQBs6v0XOqRjO0/KOE20oaEGqVcBxxxpJk
         0A4Tv4ENWV9VVGXl2Dsnq7+ibsvapsJv8vFhG52zwB4sAZjoAF2liviYnf6dkd5dovf4
         2JiTCwyarEDrvD1Kq1nkJmMVz2E4hTbWNhJhOs7i6xp0V7oXPJ/5Qolr0bcyG1GfmbpF
         k/fg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWUtbIftx06gZq47dZF3aXct9PHIv91ZaQiAOfkPYGlbAH9hA4y
	pukaSFqowH0iC45jluHEfEWctX1V9cZ/c45sHPd8qWnPZ8ylD+n9h7rpw2KDQEY6Cd1VjongfE+
	iC274OKSQTYRejXU46qxAyJghKhw8a3R2w8Ytdukt3Q8Y78yg7BtjVmSNRADVHl90qg==
X-Received: by 2002:a17:906:69d6:: with SMTP id g22mr15996998ejs.124.1556103002824;
        Wed, 24 Apr 2019 03:50:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkTsUHq1ZYpk7KLNU1tEZ4TSeQAZMtxzBFOpnm8t8RYqTRSpfanJ0FYdGzNUsLCKVw2av3
X-Received: by 2002:a17:906:69d6:: with SMTP id g22mr15996970ejs.124.1556103001971;
        Wed, 24 Apr 2019 03:50:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556103001; cv=none;
        d=google.com; s=arc-20160816;
        b=k1IHa2tENqdaQrJIYKNebgqnYDkqezeP/KJOVyxLtq49H0rBm//tAJa4/cT7Kgfgzc
         /v6wjOoInkQG0Qr/M3nUBD3K89ewkO2CaWx1vDJXoj2CymOnle0mB1WSrohdJbiU4uF+
         fenSsemRvGe7tc3IrwigQstLt7Hx3z56Y+i+K7dJjlhGY+tMf/tn0pud+SkJg22YfLVY
         cJ2mwPfL8EaiBUN+DFQT4Sgg8Rdu1+92I11il4eSuYHgRGAEmnAMAo6bPe4YFXR6r17T
         uOWZ2rfLNtaqCey2zXI1XsTOLlyn4A/I3DqKyUVi13Ynt1pJTgolrAMq+0dMm8WI9voY
         h8Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QDNP03AQGb24+LbcbcF7AUvAIcDzscwdInH9nGdezrE=;
        b=VJCfw4kIp5XHQUEulvRVjCzm+WcIlPYUq2iE1mbMkACuHi7mFPjzNnBLGlMgtNqwWA
         FcFBJmJSnXVsCMwrmzwPW0aMpLcZ66HadjaUAkG/sOxz0ToREVOwpr9AAFV698i0Uq2o
         BxXP9EdMYNWIGz4Uc1tE8n0eBjBveeYD4xXuojvHx51My+7HG8TlzDTOxVrZjPMSjG7l
         vtPJDBthCunTyusgwdWYgCQ1MSt170LRltv268WIbFJbaoXU4uvmRNMhHn65QAO9vwe/
         cThGaOo+OaNhTntg5dbjIrZwwyjGDw2UNgFvfYtTkhnhFGReX73ovjcjL6t967N+PJg7
         Apyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e19si1497399eje.133.2019.04.24.03.50.01
        for <linux-mm@kvack.org>;
        Wed, 24 Apr 2019 03:50:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CFA83A78;
	Wed, 24 Apr 2019 03:50:00 -0700 (PDT)
Received: from [10.163.1.68] (unknown [10.163.1.68])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 179573F5AF;
	Wed, 24 Apr 2019 03:49:58 -0700 (PDT)
Subject: Re: [PATCH] docs/vm: add documentation of memory models
To: Mike Rapoport <rppt@linux.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bbde10af-0e9f-08be-30d6-1513c50e0d17@arm.com>
Date: Wed, 24 Apr 2019 16:20:02 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/24/2019 03:58 PM, Mike Rapoport wrote:
> +To use vmemmap, an architecture has to reserve a range of virtual
> +addresses that will map the physical pages containing the memory
> +map. and make sure that `vmemmap` points to that range. In addition,
> +the architecture should implement :c:func:`vmemmap_populate` method
> +that will allocate the physical memory and create page tables for the
> +virtual memory map. If an architecture does not have any special
> +requirements for the vmemmap mappings, it can use default
> +:c:func:`vmemmap_populate_basepages` provided by the generic memory
> +management.

Just to complete it, could you also include struct vmem_altmap and how it
can contribute towards the physical backing for vmemmap virtual mapping.
Otherwise the write up looks complete.

