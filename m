Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E590DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:46:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BCAF20643
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:46:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BCAF20643
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E5B38E0008; Mon, 11 Mar 2019 03:46:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 095BC8E0002; Mon, 11 Mar 2019 03:46:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EED948E0008; Mon, 11 Mar 2019 03:46:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 970CC8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:46:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k6so1680009edq.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 00:46:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3uSilXgZ35GQs2AEQs1JZ8gcoL1MAcAt9W++WCrIytg=;
        b=nH33dSCPfGB0tI5GScSwZcYePKj1gHd0Kn07QZSHHD+e0FD/9AnoCPBaIb55hwb0Iz
         zBWYa1qf7btMmMk0VV7p6+bJZpJwOFEOUfQ966HB8kkXy+cfh+Z9HRAd2cEJ6Tra+PeJ
         8rlZxPhB2kjILA4qY2WagvXvsH26Iw3kns5f41kFLQ4UfKTowY+gN/59bHjF0kLKHZp0
         C0NG/CCcAu8d4guKMGUuc8cqGiN+66We+5+LRMgzUDSF5AjEOeBuO+S+Hj9J4ROI812k
         UvgAJperS8BKnAMO6cjjtwYF0NfcIRR2EDA+LEjc5OP3Pnyji3AO9fmvjV6yEUqidOW2
         p9NA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWNBpyfllGA1xDDdlKFWen3EkR+QW/rkP2o1Q8UquZe64/KVIG8
	DR2ej3NePv8jbKcXZpM6J5dDtNTBOZn5CHFO3m7oIaeRGsQZR/pGkFNlKrbY14xZyxg5J5FK2E1
	illc47WS+4ja74PJIlsbqvxwqryE1hz/T6JqAvbRm56KFJubSg3lo5Iw4sN7GpNHGdg==
X-Received: by 2002:a17:906:66d4:: with SMTP id k20mr1229633ejp.121.1552290367187;
        Mon, 11 Mar 2019 00:46:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKgLVXlkXEUKr6UUKi3dZ2Ds7rYNViDWIgH1zu4gHP6IPVutNKzCrh2MbxdAaa9cHeonEv
X-Received: by 2002:a17:906:66d4:: with SMTP id k20mr1229595ejp.121.1552290366160;
        Mon, 11 Mar 2019 00:46:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552290366; cv=none;
        d=google.com; s=arc-20160816;
        b=ItjTNGum6f+jd33nT6VRLFree5FAjnlyLffHXWxRONkANRyDlwbQQy9FQh0wzY0hXj
         fTFDb9qfFZ7o0oqKubkYH90o4DHo+QQW7NtLscCcGIorTOVPYN/wW9cCev95FfSmblE3
         X9z3DQpg1JHh9d8UjixcgpWNMlqR2UqfQkhgwwGaoc7em/LqDNmQz4pLGrWerdNw6CRd
         kXFzy91RkNwrXysl5r9uU9tmEfRuOGIokCOidxBJzU5B/p5/9w/FzjNdMEzV4oZ/rYdB
         F3qIcF2ryGJ+7b0RkXJMCQxfHr8YrpzsY0t8j6LzQZX57ml2el2AF2su9vmWA9JJ1OvG
         +X+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3uSilXgZ35GQs2AEQs1JZ8gcoL1MAcAt9W++WCrIytg=;
        b=uUdSK7akcL8d3HpWrZObfV4rdAjcujJWyGSMKyfPQmxtGbGNFVKp9Fw1Xwre3iTu2w
         yCeET2Sf4hXL8J/K/A7ofJQxuJ1Rkb3ztG9s6/BpWfmuA5tb4osVzqbttOpwqsU2d2EW
         x1lRZEOS9BlfmOIWb/rnc5G+b3QPbJ2JoiKTNDMQt3PmcVLegI6EMCKWsAQzJoPZ9Vo0
         6GodYaRByeCQaNicySfcdfPD9RuDtKyyZV0mA1kLYy2lBD/NFucOEhbixJ0uAH3dNCqY
         8jPJWC3ghp73csnC6HnaPz1Gyb8cQDwYbLhQ5fwCgWVJb3R6KBukiiyxD1e260UjS+Zg
         9oTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e10si2628069edq.128.2019.03.11.00.46.05
        for <linux-mm@kvack.org>;
        Mon, 11 Mar 2019 00:46:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ED397A78;
	Mon, 11 Mar 2019 00:46:04 -0700 (PDT)
Received: from [10.163.1.86] (unknown [10.163.1.86])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BA8B73F59C;
	Mon, 11 Mar 2019 00:45:58 -0700 (PDT)
Subject: Re: [PATCH v3 1/3] arm64: mm: use appropriate ctors for page tables
To: Yu Zhao <yuzhao@google.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Joel Fernandes <joel@joelfernandes.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>,
 Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
References: <20190218231319.178224-1-yuzhao@google.com>
 <20190310011906.254635-1-yuzhao@google.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b0ae4f65-aa0f-148a-eced-0d9831a7bf01@arm.com>
Date: Mon, 11 Mar 2019 13:15:55 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190310011906.254635-1-yuzhao@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Yu,

We had some disagreements over this series last time around after which I had
posted the following series [1] which tried to enable ARCH_ENABLE_SPLIT_PMD_PTLOCK
after doing some pgtable accounting changes. After some thoughts and deliberations
I figure that its better not to do pgtable alloc changes on arm64 creating a brand
new semantics which ideally should be first debated and agreed upon in generic MM.

Though I still see value in a changed generic pgtable page allocation semantics
for user and kernel space that should not stop us from enabling more granular
PMD level locks through ARCH_ENABLE_SPLIT_PMD_PTLOCK right now.

[1] https://www.spinics.net/lists/arm-kernel/msg709917.html

Having said that this series attempts to enable ARCH_ENABLE_SPLIT_PMD_PTLOCK with
some minimal changes to existing kernel pgtable page allocation code. Hence just
trying to re-evaluate the series in that isolation.

On 03/10/2019 06:49 AM, Yu Zhao wrote:

> For pte page, use pgtable_page_ctor(); for pmd page, use
> pgtable_pmd_page_ctor(); and for the rest (pud, p4d and pgd),
> don't use any.

This is semantics change. Hence the question is why ? Should not we wait until a
generic MM agreement in place in this regard ? Can we avoid this ? Is the change
really required to enable ARCH_ENABLE_SPLIT_PMD_PTLOCK for user space THP which
this series originally intended to achieve ?

> 
> For now, we don't select ARCH_ENABLE_SPLIT_PMD_PTLOCK and
> pgtable_pmd_page_ctor() is a nop. When we do in patch 3, we
> make sure pmd is not folded so we won't mistakenly call
> pgtable_pmd_page_ctor() on pud or p4d.

This makes sense from code perspective but I still dont understand the need to
change kernel pgtable page allocation semantics without any real benefit or fix at
the moment. Cant we keep kernel page table page allocation unchanged for now and
just enable ARCH_ENABLE_SPLIT_PMD_PTLOCK for user space THP benefits ? Do you see
any concern with that.

