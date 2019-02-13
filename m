Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CA46C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:21:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E58F222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:21:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E58F222B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66E578E0002; Wed, 13 Feb 2019 06:21:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61E368E0001; Wed, 13 Feb 2019 06:21:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 567E28E0002; Wed, 13 Feb 2019 06:21:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F1F578E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:21:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so885640edb.1
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:21:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=o5SQRAU7NJ838GP+bOyTPJ4EDNZy9OKnqqdmL/9/8wc=;
        b=OVbUdNStkEMcVFifp1zFhPLBrNNlKQGsMd27uqpIh1ZqxPk7Tgwem4qunTCYdkuV1T
         dIN5EmlB4K54Yu6N7nZllQuzm7JYT+j4SFGI6PYXZG5WI5CefBi5AgEp8j1+HwmdqHTg
         0jT7p/x1SfMAZRUiQ9Mz+xybUjkmDfwPUg8ObB0tTpS6+dJuVeTEgMd6zq1rimOA7Lh2
         ud7mKKxFFP2a+9RyN3LCu7C0NLMWPfD8UawDHjrmosJjMsBeXdQEK1JlftBV6ynPJqzZ
         raoHvrZvO5c6666JnM+t5BjeS+wQXkB9wgo+xsDWjop+KwKkMQui5K5zSPm5sXPFHxvs
         QyYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAubmp+pBjLG3HpslDSr4vwX/Jx/K+/eUPjO1PEBBBEeWpsNrnUS8
	uqrh9pbd8FKL6AfFA6UwbZiM25QCne5LTXH8wIfBuihlTF7C0UkpgHVInv2PfobRhmFlMcMcII8
	3UAYJ3qfVSW8PWmgK6pXpJQhloJoVqLBfsiH1zsIqWggz0DrbX/gY8GCVHJxau1wx0w==
X-Received: by 2002:a50:9ea1:: with SMTP id a30mr6829749edf.104.1550056906432;
        Wed, 13 Feb 2019 03:21:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbZ798lfJFPPeI7W8cyEJZhhWkQGKxgRnp6L7CT0KCiLBupx7OX/1ue8oLkumAEyPdfdvO3
X-Received: by 2002:a50:9ea1:: with SMTP id a30mr6829688edf.104.1550056905256;
        Wed, 13 Feb 2019 03:21:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550056905; cv=none;
        d=google.com; s=arc-20160816;
        b=hiHNyFFSCVDjNd/i7nH4eX+H7G8R1Op0stL9/aez14BqcNTcTwn5fgKj1gSAaqzbTD
         xTysCvV3/foulS+vK+IFBt4DpBvZ9dbTqL89mS0a2Xm4Y9bcKH9fnv8lAP5/zA/FV11N
         wDCW69SqKNvjjscp6V66SaozWXLjQlCg96Y2Mp1hxCNNcOMYcqniW4QBQfwQXzeNmx2r
         LUQygbJSLIsi9hfpUg2CEpr3Phgpdph+vbzH4CvvzjEMjGRXwk1hjMO0n3b72x9mGv2f
         H4cHLWz9xCgz3CBdI2IE2FH9g12pdXEM1xnq7Cjui4JVkf/ceVOk42rlmjZJRWbdoEGn
         FdPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=o5SQRAU7NJ838GP+bOyTPJ4EDNZy9OKnqqdmL/9/8wc=;
        b=bQK/8sXxSwCzrSj4UbWa6UjCpYAcDEkjWoYv6K1koaQjS2ryHP6uI7RQ7cJs1phnJM
         S2KQKg6o1FBXEV1VCfUl+y7Rj76YHbz2dWEMnyoQgG4GSTZwZ34kEHVFvsQX9hYcgBHM
         SIzhO5OEMTts4GhbJqEx1A+3tNRp/I6GcFM5o+cf3oTbafeVyVeio4rmEnDiMlvwexBL
         qDn3/VaiYVVt3nvuqbvlsw56UCXPIKpjcfH6KZsEiNFSxSNWfoJTzgTHN/+MrhW+bzlc
         MdK5SIvFoR1NOss5SWlB60aAnXvNVdZsAZ8GbHXbv78J37B3yh88m1fbYCmGIOtm/E4d
         Gb3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x2si459659edr.373.2019.02.13.03.21.44
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 03:21:45 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 10C951596;
	Wed, 13 Feb 2019 03:21:44 -0800 (PST)
Received: from c02tf0j2hf1t.cambridge.arm.com (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 100593F557;
	Wed, 13 Feb 2019 03:21:40 -0800 (PST)
Date: Wed, 13 Feb 2019 11:21:36 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org,
	kirill@shutemov.name, kirill.shutemov@linux.intel.com,
	vbabka@suse.cz, will.deacon@arm.com, dave.hansen@intel.com
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 01:36:27PM +0530, Anshuman Khandual wrote:
> Setting an exec permission on a page normally triggers I-cache invalidation
> which might be expensive. I-cache invalidation is not mandatory on a given
> page if there is no immediate exec access on it. Non-fault modification of
> user page table from generic memory paths like migration can be improved if
> setting of the exec permission on the page can be deferred till actual use.
> There was a performance report [1] which highlighted the problem.
[...]
> [1] http://lists.infradead.org/pipermail/linux-arm-kernel/2018-December/620357.html

FTR, this performance regression has been addressed by commit
132fdc379eb1 ("arm64: Do not issue IPIs for user executable ptes"). That
said, I still think this patch series is valuable for further optimising
the page migration path on arm64 (and can be extended to other
architectures that currently require I/D cache maintenance for
executable pages).

BTW, if you are going to post new versions of this series, please
include linux-arch and linux-arm-kernel.

-- 
Catalin

