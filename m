Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23259C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 11:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC8A72070B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 11:56:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC8A72070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30FAB8E0003; Mon,  4 Mar 2019 06:56:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E3E18E0001; Mon,  4 Mar 2019 06:56:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D48E8E0003; Mon,  4 Mar 2019 06:56:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BCF9C8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 06:56:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o9so2533250edh.10
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 03:56:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=V4MHQpXWPAcCZV7QaLKDIEt71UAdXIwx9TuioGwDtoc=;
        b=FBCNaSMnLSJdKeZ0H5r8peRWMnIgYP3PwurUjYfS1Dlpkcsz9csdv4+FWFFgbGlXki
         7Me6QA6mRJ8Z+xzknLycEz2tFoG0gaceKdCML8TljOehrVOlta8w9Hq9b2w3hku2pM8A
         oZIUJf/odCGR2Umhh0P9aTLULTqjSVFPPzWRacA2VVXwcTT/TyrSy25qXBSrr23viM1s
         RIAI22PrP3yYwzJtW/9kl5lODtahFBjGm9gnVlsURu5sUMdG+uFzjzTD94MUKxSAsQbN
         UlYvbFEM25j1LMG1ZHOyKalyRnEyCFiHkDsglF0/FUutTKRNc+xCcucs9ioqOyIWOgU1
         yVHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVBX+l12zNVc5+hH125ikPEH4z6nkuxfJBmEcC76xNZuwN75Zy4
	jhxzsaGN7d9AYY+NfA3uKeCVA094cS7WN3XJW7GxkuDuBu+Jr5smuJMglAaGb+evATbPdZMDnsS
	sLzGVLQXCAo64eWrresvaw/6d4Un3G+dcQ4Mx1b3AYNUWJC8kSIJ9cQKZKsf8TpSVEg==
X-Received: by 2002:a50:89b6:: with SMTP id g51mr15182891edg.136.1551700581237;
        Mon, 04 Mar 2019 03:56:21 -0800 (PST)
X-Google-Smtp-Source: APXvYqzku7fSwE98JnVHd7HkMLxD3v6uQY3OGHvehAQnGNP1Mby7KMaD4oPUPkadI5KyY0dYx0xO
X-Received: by 2002:a50:89b6:: with SMTP id g51mr15182840edg.136.1551700580149;
        Mon, 04 Mar 2019 03:56:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551700580; cv=none;
        d=google.com; s=arc-20160816;
        b=YEnrhcRxF2tpVT2qzgvtkaGZaPjjieUV5thbWoENAn9MAa4SV3LTzBZWhOHwG4LAi6
         nK2uFmGU2QPZMy0gM1+S35TUyCM7UU+f2i4VpoaiqDCs86qmi2HYz8NQ7VkMkkuz3Lev
         A6kt9MpoU/xzgMUnexII/d2/bh4O1D8DmMCrGDSM7xgE+Qpj/jawurHpVglWwHMgjfgH
         Fv9fJUnT4fq98Qg+pYJFEreoupbDoCSKoLud5YH6RSWFZzeozGX2aSKU1gbR9oNyYFqn
         bOkxTO1+o3KV+siI6iFD7hrDjc2J+lbCPYsgbyOG+QRL8hOFVEvwxSoEbgnMpbm3RvdY
         cJbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=V4MHQpXWPAcCZV7QaLKDIEt71UAdXIwx9TuioGwDtoc=;
        b=V7XbSYhUz7t9Rdzc0PxMQUykbluRiwqyeMLcmSupIIzhhZLubFcGLPI/xxJ/NK1RJk
         7hiP7tCLnoaGITnfgjqlKAxg70w1Ye3LDjdI/F7nDxWDODu21WjIG6cGXmhppvb7qCs4
         mx2J1kk/C9/kftGH7CQUvqczHuUN+E26XTL13ZXX1ZxrMEYfkqQfNNqc1EUzATVC9Phy
         8o6XlTPCUCj2N7QCmpt0w3GZBH57a4YgxIyVguE/62NgErgq47jVUMyY4NxJzFIW/mp4
         gXmz3L+OroIjMkDlIQEer3IQwWpr1KjpLJzFnH66VWAKGKgUwiUQPUDdkWEOuJY6ZxI+
         cyOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n20si2261145edn.423.2019.03.04.03.56.19
        for <linux-mm@kvack.org>;
        Mon, 04 Mar 2019 03:56:20 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DE573A78;
	Mon,  4 Mar 2019 03:56:18 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9426E3F703;
	Mon,  4 Mar 2019 03:56:15 -0800 (PST)
Subject: Re: [PATCH v3 03/34] arm: mm: Add p?d_large() definitions
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 Russell King <linux@armlinux.org.uk>, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-4-steven.price@arm.com>
 <20190301214715.hyzy5tevvwgki4w5@kshutemo-mobl1>
From: Steven Price <steven.price@arm.com>
Message-ID: <974310a0-0114-9a0c-9041-4e0394c4b9aa@arm.com>
Date: Mon, 4 Mar 2019 11:56:13 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190301214715.hyzy5tevvwgki4w5@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/03/2019 21:47, Kirill A. Shutemov wrote:
> On Wed, Feb 27, 2019 at 05:05:37PM +0000, Steven Price wrote:
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information will be provided by the
>> p?d_large() functions/macros.
>>
>> For arm, we already provide most p?d_large() macros. Add a stub for PUD
>> as we don't have huge pages at that level.
> 
> We do not have PUD for 2- and 3-level paging. Macros from generic header
> should cover it, shouldn't it?
> 

I'm not sure of the reasoning behind this, but levels are folded in a
slightly strange way. arm/include/asm/pgtable.h defines
__ARCH_USE_5LEVEL_HACK which means:

PGD has 2048 (2-level) or 4 (3-level) entries which are always
considered 'present' (pgd_present() returns 1 defined in
asm-generic/pgtables-nop4d-hack.h).

P4D has 1 entry which is always present (see asm-generic/5level-fixup.h)

PUD has 1 entry (see asm-generic/pgtable-nop4d-hack.h). This is always
present for 2-level, and present only if the first level of real page
table is present with a 3-level.

PMD/PTE are as you might expect.

So in terms of tables which are more than one entry you have PGD,
(optionally) PMD, PTE. But the levels which actually read the table
entries are PUD, PMD, PTE.

This means that the corresponding p?d_large() macros are needed for
PUD/PMD as that is where the actual entries are read. The asm-generic
files provide the definitions for PGD/P4D.

Steve

