Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F7F2C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:53:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0139F2084E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:53:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0139F2084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B5E66B0006; Fri, 21 Jun 2019 08:53:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 865CE8E0002; Fri, 21 Jun 2019 08:53:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A2408E0001; Fri, 21 Jun 2019 08:53:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAE56B0006
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:53:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so9053943edw.20
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:53:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=K+0w3Eo7dJoAJgrQlXhVbE5fbECg9yu1TJLNsUCu8t4=;
        b=sXxduKCzhb1yxbss5RVRxnWhHk7wuQ5NCtaKxOQBeMa4R/cSkAlOG8yarSI8kiYPf8
         elbt1eWb48WCA9s6lhWPTxPvI0rnsfcC6j+yvy7MXstX8oL2wqzTGOi6teclbzgqBVy4
         0f2Rx2027FpBMNr3Vu3GfWixBm9d79mOcs48rfAh9UcJEAKvvTbSx/eabYXeDGBXZq4R
         RoGFeZEzJQk3HsObxTK3puyjxwxFklfA1J/DuMZLQaCai5Xnzmuva0nok31NPR3+HtHt
         lXD7g/R8lmaaPxWA70B1JLmG3VxTNdv0vwXgEiyZMy6atBbiuIxvEkY4RH09nooWurBv
         t0kA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVyIjK4rSD6kytvGnIlPp0sm0t99nNOLRRsCdBEkIHGZOSK0YXr
	Ac5ayj1dtiKrcWlyMIsgVdec1KuN8yYBT6aUeKvHeI2r6EDjl4Oqwp3gAklRLmzVWwEg04zsfkF
	DRC9vwHU/ti6KxqwMkEG0GM6u9Fn34r5QRiL1ud0Qduwn8FfWfmPl9iss+M7s1vBo+A==
X-Received: by 2002:a17:906:308a:: with SMTP id 10mr5257963ejv.124.1561121586745;
        Fri, 21 Jun 2019 05:53:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlzpX1oyyqkJDbQXECMfVixLnK5L08d4xj5xYKtXFpE4cMp4M0WiFmB/QMhr8Ph6vAOx9K
X-Received: by 2002:a17:906:308a:: with SMTP id 10mr5257909ejv.124.1561121586005;
        Fri, 21 Jun 2019 05:53:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561121586; cv=none;
        d=google.com; s=arc-20160816;
        b=geuRjAjoMeJaLqVVYmaEA8IKlay9tl6lsxOxueOZyRnVBrJQrFO4n9hVRNipFIFPhB
         5Qz8onYfWiaBN1cdsDuBUDvT5DNhOT3f+Xj2qZ3r6TRwibb8HbPpPNoxWgVvAf+2/wOY
         5gZEAL4OCxvlMcVWYwfURosZtdfgbHHnuZ6dFbA0fw34IOv+qzRujlm021OZuOd/xQyT
         w3z2y5oBC4Nj6X4fbS6NKmrbc1h2/pwq5241zo28utFER133oXboEorgK0ycYN6Dl4Uc
         XHtoLoFebSiMnib3anDXFtuv/sMrAOdMQ9xiulcy9ORJYvklYctHfAst6Rfe43QXXcpU
         gKnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=K+0w3Eo7dJoAJgrQlXhVbE5fbECg9yu1TJLNsUCu8t4=;
        b=QG39tCDwSqqdzVU3aapOe2uPCE9uHsOIxR8usOgVhvL9/vqtzgfh8oB4x4HybOvu8O
         MpN3/7LMhdUepit8dMN8MprtpBMzJ+p1cluAqw/UUlDY4OsbuBF7gcD9eaLxCsjxVLAq
         8e62ug0UMPTzLjWjt6nDfPyXH/Ge09UydTTXOfoQyX7q+CmeeSf8gV/0bA8OC+GpwhG5
         rweRhygfycSj3D/wmiDPcRotnjKwsoxzwokSQCmymgPpPzkdI557RJuXQYifwuFbPoVc
         voB+St550Z6PsvWBue/1Rg2DCT0r9q47vOQC84VfQ8hWuONYJPu1JboqRexjvBiWc1QE
         d+GQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id d16si1746747ejp.292.2019.06.21.05.53.05
        for <linux-mm@kvack.org>;
        Fri, 21 Jun 2019 05:53:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0978E142F;
	Fri, 21 Jun 2019 05:53:05 -0700 (PDT)
Received: from [10.162.42.140] (p8cg001049571a15.blr.arm.com [10.162.42.140])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 158133F718;
	Fri, 21 Jun 2019 05:52:59 -0700 (PDT)
Subject: Re: [PATCH V6 3/3] arm64/mm: Enable memory hot remove
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 catalin.marinas@arm.com, will.deacon@arm.com
Cc: mark.rutland@arm.com, mhocko@suse.com, ira.weiny@intel.com,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, james.morse@arm.com,
 cpandya@codeaurora.org, arunks@codeaurora.org, dan.j.williams@intel.com,
 mgorman@techsingularity.net, osalvador@suse.de, ard.biesheuvel@arm.com,
 steve.capper@arm.com
References: <1560917860-26169-1-git-send-email-anshuman.khandual@arm.com>
 <1560917860-26169-4-git-send-email-anshuman.khandual@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bc46b390-01b8-e818-588d-f973dc2c5140@arm.com>
Date: Fri, 21 Jun 2019 18:23:22 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1560917860-26169-4-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 06/19/2019 09:47 AM, Anshuman Khandual wrote:
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +	/*
> +	 * FIXME: We should have called remove_pagetable(start, end, true).
> +	 * vmemmap and vmalloc virtual range might share intermediate kernel
> +	 * page table entries. Removing vmemmap range page table pages here
> +	 * can potentially conflict with a cuncurrent vmalloc() allocation.
> +	 *
> +	 * This is primarily because valloc() does not take init_mm ptl for
> +	 * the entire page table walk and it's modification. Instead it just
> +	 * takes the lock while allocating and installing page table pages
> +	 * via [p4d|pud|pmd|pte]_aloc(). A cuncurrently vanishing page table
> +	 * entry via memory hotremove can cause vmalloc() kernel page table
> +	 * walk pointers to be invalid on the fly which can cause corruption
> +	 * or worst, a crash.

There are couple of typos above which I will fix along with other reviews.

