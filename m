Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FC01C06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:44:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 274FC212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:44:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 274FC212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 710346B0003; Mon,  1 Jul 2019 05:44:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C07D8E0003; Mon,  1 Jul 2019 05:44:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 589728E0002; Mon,  1 Jul 2019 05:44:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id 09E656B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:44:23 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id l26so16542980eda.2
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:44:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5F+/8sMUxoYA2KfFpDZEjO16pdCT4UQ4lF+RZj01JQE=;
        b=f2+agCyGzrzT28ExTpsTCxSmt8yIeCkCAWe3IjcHrJ7ZMrj+MUjcNPLiibd8mSPmz7
         HHI0XMUPdzL+jEmHwpJTwjALjm+v6hIxz4UNVJGaGQfXZeeCDXSWA7Mta1aqCmLcl2rz
         hD4oG8eubShRKXGY6tCmBK8g4k+LV3IebH/mt+QQOYT/Dg82/ApXs6VXyFaosdP7bd1s
         o/5jjwzq7+pb9l6mpJ4pIn3bzj+VZjIARMw1uDEzipjOlsBQNdtIPI244p99kt3hx235
         YC209anEe2dz6akYOaniX21fDX5d6wTT9mWiZZ084L0T7rgdD3A7c2piIbJ7mK4vymZc
         oJCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXvHuBC1OlQG4k++c5bH38FUXWObN9u3ZhQJA7bX8BCprPWCvb5
	m6s72nZ71Q1oN7yIlxlQTqnEwwqTRFW9zHf1rPCQ0Xb5cFfOns4j4bla6Tqu7fzA8adVEWhfek0
	aHWwZzTcBllWQqCR8gaInqP4+mg7bzW11UwSQazwRBb54sLyJyEZI4GjVkLl/+VJ06Q==
X-Received: by 2002:a17:906:19c3:: with SMTP id h3mr21867178ejd.49.1561974262608;
        Mon, 01 Jul 2019 02:44:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBtpfF8Pa84EXnH4HCuY//K9hN+UPT8b4D2cpwLJCOugSkrAMnsBCsJzIMPd8fW+fveQHN
X-Received: by 2002:a17:906:19c3:: with SMTP id h3mr21867116ejd.49.1561974261736;
        Mon, 01 Jul 2019 02:44:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561974261; cv=none;
        d=google.com; s=arc-20160816;
        b=bogX+EuV4cH9wv2j7JcY4iyX/j9v4xTJ6Bmy/95a3wD/9ecniLfVm0tjR6wA9T7fEV
         sF/3vzKfuWrK+5zmjquuXNUZE12KsEU2Q6k69h6XrmANE4n6sf1xSEIt0yanojTge/vm
         zoITFi1JEEhRCRnwAYGRM1jmzL+lTR2BCbnWffl7cmHeEfSoUIEd3VApq53gvlUKv/bV
         EXXJTJT9mDoE1WSIcHSNdDE+T/NS0g6cqZlFhkXW+yRsJnY2udhL3CfQW4LKFkaVg7ku
         cYzIBn5W9E7jew4uRv7yWzYxCHCbqIQsPHAPQgwmF9s4SozNgo1fpuKSXJyuvg3NbksW
         kPwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5F+/8sMUxoYA2KfFpDZEjO16pdCT4UQ4lF+RZj01JQE=;
        b=aAydKwyEV+8bVbQP9brfprtk1DhorVZjXdt8shWo1oVStg8zVezHvEMEy/KUe4iTka
         KTl5v9+o3pOcRD6pYdtchu/0KcNK2wbZcZg6UKi2m5A69BLl+SPCpDG4ZOddJKGElrXe
         dmmpnxClDoiXyuwyLlfLDeNYWKiyDjilQRfRlFkbMGKqTLImGExngL6pNgcJHyhv6cZH
         2+UaLoPZj6JF/oNQVGOPBdKwhew2Xb93M7FUKjyCiU2eu5LqTvvtah636S369VDpGK8J
         mi3BELHuM47dkiRil+b/HGFMeyp1cu4TicWjQkgxpui+8hZCUr0RSyqWps3qHwTKgyYt
         roHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id qc1si6918683ejb.59.2019.07.01.02.44.21
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 02:44:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E1E752B;
	Mon,  1 Jul 2019 02:44:20 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 727AD3F718;
	Mon,  1 Jul 2019 02:44:19 -0700 (PDT)
Date: Mon, 1 Jul 2019 10:44:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: "linux-mm @ kvack . org" <linux-mm@kvack.org>,
	"linux-arm-kernel @ lists . infradead . org" <linux-arm-kernel@lists.infradead.org>,
	"linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Steven Price <steven.price@arm.com>
Subject: Re: [PATCH v2 1/3] arm64: mm: Add p?d_large() definitions
Message-ID: <20190701094417.GB21774@arrakis.emea.arm.com>
References: <20190701064026.970-1-npiggin@gmail.com>
 <20190701064026.970-2-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701064026.970-2-npiggin@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 04:40:24PM +1000, Nicholas Piggin wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information will be provided by the
> p?d_large() functions/macros.
> 
> For arm64, we already have p?d_sect() macros which we can reuse for
> p?d_large().
> 
> pud_sect() is defined as a dummy function when CONFIG_PGTABLE_LEVELS < 3
> or CONFIG_ARM64_64K_PAGES is defined. However when the kernel is
> configured this way then architecturally it isn't allowed to have a
> large page that this level, and any code using these page walking macros
> is implicitly relying on the page size/number of levels being the same as
> the kernel. So it is safe to reuse this for p?d_large() as it is an
> architectural restriction.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Steven Price <steven.price@arm.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

