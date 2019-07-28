Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3852C7618B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 11:19:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B4DF2075E
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 11:19:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B4DF2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D179E8E0003; Sun, 28 Jul 2019 07:19:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC80F8E0002; Sun, 28 Jul 2019 07:19:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB7CB8E0003; Sun, 28 Jul 2019 07:19:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 715AF8E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 07:19:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so36694421edb.1
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 04:19:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nHJUhgqVI9EkiGe8FCjtgW4A4hY5vjie7p6dN4YuAns=;
        b=bbVRzkmRn70bToVgF2KNmvjB6mUZ6kiZlKc87kW3wO8nBLVZpcjloG1n0YJqBihz/s
         pyIhGITp294N0dvj5Sqh2kaPwqVrRC2VOtRHxPWKu6MxW9W3D6EB/syInbjpo59y7K7r
         T04JMd2SOZJQmiNwyQnZJnSxqIkNrpIKeuS8nYRYZN1+buKgr+yyQHdFvAQAFc0JkydC
         wygTj6gP936lUzIHqjBLjhCImpLKNGYmXnFpm0c3QqNFPCDkK+fp7E0FmrHlr3OQxceF
         0bOGQZdue1L5DM1EQ5mPLcHVLuSAVSEoAXRCZMuk/dF/ZNfj3nthiX05LmYQWmZTubVS
         pvfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAV0qXmE9/OmFqbPD09ak2SunJ9HAzGDnCIZU2gFEHPumIwhy52a
	E4c5vtnGvW5mFfOZbw5NhhQ3ehEip8IAMINrPs9x75bAcRLzkKTpVgNHVQtlvO5QeKGbk7GsE9i
	FB70XCR2+AtTg+xynXdRfZmuF25BmfTlDbSXorUAGX0MJZz6x3Yq18fKyl8+d0yPjqg==
X-Received: by 2002:a17:906:8591:: with SMTP id v17mr79697705ejx.244.1564312771911;
        Sun, 28 Jul 2019 04:19:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXFe1NMXd17wiePcWwCcwixAZN8UD54V6VdG8pU5O1SVMoivZ2VardDjyrZOoA12elaf65
X-Received: by 2002:a17:906:8591:: with SMTP id v17mr79697674ejx.244.1564312771054;
        Sun, 28 Jul 2019 04:19:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564312771; cv=none;
        d=google.com; s=arc-20160816;
        b=uVD7ZNZsKehNqsOf9ez5gfa6tfnixzzLsD0aaM6ubhDteKICbhKBwcVF6ufaIOwa7x
         HZ20K6xlhjEv1SpnHRZZnV+LGOMzaJ5fZnDhzSUtciERH9JRgFNzueEHEjClvBhv5So3
         RTZr0K7i8F3rPUUlkXKOS71m3RFuQE0seKNI1yKVzFt3YNCdEYR1OMy0RM/HS9SzPez5
         Xd05WfutbCaU0GEmaSaixTDK05TU0uYjT5baOF1gjxGByc4x+k+eW3hRaILCv+9S6CDl
         QP2YTPunxHbK/UsJ85OHYV/HAekGCCSUXwT0wd16D3M8lqSbA7rNELJ/QFIoGMktcP8P
         xdRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=nHJUhgqVI9EkiGe8FCjtgW4A4hY5vjie7p6dN4YuAns=;
        b=ve6s3ePjV7pF/V/pvLf3zMl6Vt1JdVflR8SM0AtpLBSzduYqTt5hr4XPLrwY5hjudd
         PT4aZR4hljsSAc3GXhX91fqHlxm1+R8aJrcEVFZ/t1p9r1PBVGaLIbmz4EgNlWxL1esj
         2T7/y3ETZ8M3XBNTYnoW6rTVSk6gkisNDN/s8p/W5UR7RmbWneuYRusn8HIs0WolJDtp
         0qbwtgiyiO5ItiAWz6Jwq105FDQhgHiTEmCPLHWO/W/3BHCtWb/v+on/f3mL7ZWjUihl
         oYJgFCPlOiyj4cJ/E3yLjck5y48/jCAelMgFvEcg//rECkedvk1rha1VRMc2dBymiBqx
         bhxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id u30si17127170edm.309.2019.07.28.04.19.30
        for <linux-mm@kvack.org>;
        Sun, 28 Jul 2019 04:19:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A1C89344;
	Sun, 28 Jul 2019 04:19:29 -0700 (PDT)
Received: from [10.163.1.126] (unknown [10.163.1.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 855083F71F;
	Sun, 28 Jul 2019 04:19:23 -0700 (PDT)
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan"
 <kan.liang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190722154210.42799-1-steven.price@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <794fb469-00c8-af10-92a8-cb7c0c83378b@arm.com>
Date: Sun, 28 Jul 2019 16:50:03 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/22/2019 09:11 PM, Steven Price wrote:
> Steven Price (21):
>   arc: mm: Add p?d_leaf() definitions
>   arm: mm: Add p?d_leaf() definitions
>   arm64: mm: Add p?d_leaf() definitions
>   mips: mm: Add p?d_leaf() definitions
>   powerpc: mm: Add p?d_leaf() definitions
>   riscv: mm: Add p?d_leaf() definitions
>   s390: mm: Add p?d_leaf() definitions
>   sparc: mm: Add p?d_leaf() definitions
>   x86: mm: Add p?d_leaf() definitions

The set of architectures here is neither complete (e.g ia64, parisc missing)
nor does it only include architectures which had previously enabled PTDUMP
like arm, arm64, powerpc, s390 and x86. Is there any reason for this set of
archs to be on the list and not the others which are currently falling back
on generic p?d_leaf() defined later in the series ? Are the missing archs
do not have huge page support in the MMU ? If there is a direct dependency
for these symbols with CONFIG_HUGETLB_PAGE then it must be checked before
falling back on the generic ones.

Now that pmd_leaf() and pud_leaf() are getting used in walk_page_range() these
functions need to be defined on all arch irrespective if they use PTDUMP or not
or otherwise just define it for archs which need them now for sure i.e x86 and
arm64 (which are moving to new generic PTDUMP framework). Other archs can
implement these later.

