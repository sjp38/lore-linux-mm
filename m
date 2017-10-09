Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 068616B0266
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:59:13 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j201so13440321ioj.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:59:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d184si7242627itg.161.2017.10.09.11.59.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 11:59:12 -0700 (PDT)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v99IxBvO015350
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 18:59:11 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v99IxAke026808
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 18:59:10 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id v99IxAad028200
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 18:59:10 GMT
Received: by mail-oi0-f50.google.com with SMTP id c77so39378855oig.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:59:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009184834.GE30828@arm.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com> <20171003144845.GD4931@leverpostej>
 <20171009171337.GE30085@arm.com> <CAOAebxtHHFvYn4WysMASe1GqvgKYPVyjJ572UM3Sef5sP0hi9A@mail.gmail.com>
 <20171009182217.GC30828@arm.com> <CAOAebxu1310eCrk88EC=Oaw3n90-9RuHZ1KBhPvLu_DyXBNZFQ@mail.gmail.com>
 <20171009184834.GE30828@arm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 9 Oct 2017 14:59:09 -0400
Message-ID: <CAOAebxs5s3DKV8f+Zw+LFVB98PE6cs=RwcOH8qEiU_MPLM9RvQ@mail.gmail.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Will,

> We have two table walks even with your patch series applied afaict: one in
> our definition of vmemmap_populate (arch/arm64/mm/mmu.c) and this one
> in the core code.

I meant to say implementing two new page table walkers, not at runtime.

> My worry is that these are actually highly arch-specific, but will likely
> grow more users in mm/ that assume things for all architectures that aren't
> necessarily valid.

I see, how about moving new kasan_map_populate() implementation into
arch dependent code:

arch/x86/mm/kasan_init_64.c
arch/arm64/mm/kasan_init.c

This way we won't need to add pmd_large()/pud_large() macros for arm64?

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
