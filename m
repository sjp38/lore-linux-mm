Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EAE9C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:12:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9209206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:12:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9209206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 767818E001B; Tue, 30 Jul 2019 02:12:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7181E8E0003; Tue, 30 Jul 2019 02:12:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DFC68E001B; Tue, 30 Jul 2019 02:12:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12A8F8E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:12:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so39680357edr.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:12:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=+GyToamCYQslJN30QlOYB4rUgZbXEdynHh6yGFF/boo=;
        b=eGjWh+whQvWIzqi5mDLfp+LKQdarzaI8ZeCgTZ5k2reU8aPb/e8i0VrMSGarXbpkcy
         n5vkfBrauaoOGPwe79KU8/OUV/iGc4ZYff+9Bh8whBZ05AxPQ09xGKAYn3VcunzGN6C7
         WvQcMyumcZC1jTIvg+KQYujKV/b/2RUFTn5I2bkvqvaLOeb95SQUtb5dXLjJYpqjcVZh
         32d4m+aVjEDA/8HifnVhJzugFU847xO/Qq/82LW862L7LG02chrsK0ypvQXEG/7OAwrM
         8ZOrQTpigl2GBqq8dEK80ct9jZzkGiNofTCRVvIul55Zrv0Jl6FuMqqUbibI3WWd7J0f
         FZgA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWgJ6wKVnPi/GZ8ljQV44BM1dT+/gQ+Ev2L7FH0mA2S6BRlV7/i
	VfELeZViOSPNTX7tq0/ISkDcYUY0NfcKk0kb/BwUJgKy8WuQTYmvgaPv+xQCulK2bQb7s25G3d3
	0KwJAhmMPF7VqAPWsW04LVjF8ygDf65lcb7DW1rLPUaSCazvvbKv8geOCpTsXmCA=
X-Received: by 2002:aa7:c24b:: with SMTP id y11mr52853419edo.239.1564467147598;
        Mon, 29 Jul 2019 23:12:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqys510rjMxYGZNdH76vlvxHEEROQj3ibJ5TEWc9L3RBeGV4xqaKK45qXTqxaUvHm00Ha3XH
X-Received: by 2002:aa7:c24b:: with SMTP id y11mr52853374edo.239.1564467146847;
        Mon, 29 Jul 2019 23:12:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564467146; cv=none;
        d=google.com; s=arc-20160816;
        b=lKa9XUST4B7REdFCIZuZZ/ZfaewGAH0F33CpgY2FdW5vSDK4K153DC2M2c9zmhpBrY
         PKSxc3oSeQ05WzhmvUsECmyeUPjfzbK2LyzOYAS0xABCQ6UR8RhONlXJnxBuG+YAR2ws
         GbYOI8ZYaYs7k22OBfVzwPVleWfonN6uLc5xZGG4uVfxCTfA9oQ0lyEANJeKH24rBwh4
         lH3zpbretynfGxN/IOJ2c+eaCZnA6PW0qHoh/r6d/2yOydS24TaPYQb417VFvPABEU2S
         IHsgoucn0knAhPCQT78JuwMzweGZjDH9mbccF6Fmqd7cXlRCpaf4y4ACwtnaQyZYWpju
         rtpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+GyToamCYQslJN30QlOYB4rUgZbXEdynHh6yGFF/boo=;
        b=QramYOLVRTuJ8U8vqsi7bWJWi/x14+Z5kRiT+i/pSliFzRTuXMyd7zcLs5nhCB5YLS
         dGiZQk0ZuVLuif77t1YTHo7MDUdmMVsaUb3M8li5pFr5iYPpzUGkkZHyeivwEwUdGe9j
         r1tAqCSFeHTv4YCLaMcbvXgVs0wfiOOjlVsR7WzfnsXk2qUn484ardCdWa22SOp1RNxi
         zivu0awqts6J35hcznsfvukjhiK/HE6CU5zp/yCRDeiuYCGo97QODr0xT1fIQN7G4UmH
         va1x9zED3f69JbDdvqMQOmkpJyimOBhsx6eeveHucIUD30yJBJ3OA5nHlDUI4y5C85ss
         NbZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay10.mail.gandi.net (relay10.mail.gandi.net. [217.70.178.230])
        by mx.google.com with ESMTPS id k8si17817632edd.67.2019.07.29.23.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 23:12:26 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.230;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay10.mail.gandi.net (Postfix) with ESMTPSA id 8126E240007;
	Tue, 30 Jul 2019 06:12:20 +0000 (UTC)
Subject: Re: [PATCH RESEND 0/8] Fix mmap base in bottom-up mmap
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
 Helge Deller <deller@gmx.de>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Vasily Gorbik <gor@linux.ibm.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190620050328.8942-1-alex@ghiti.fr>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <175168c1-d25f-7a93-e19b-dbb6ae6289e1@ghiti.fr>
Date: Tue, 30 Jul 2019 08:12:20 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190620050328.8942-1-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/20/19 7:03 AM, Alexandre Ghiti wrote:
> This series fixes the fallback of the top-down mmap: in case of
> failure, a bottom-up scheme can be tried as a last resort between
> the top-down mmap base and the stack, hoping for a large unused stack
> limit.
>
> Lots of architectures and even mm code start this fallback
> at TASK_UNMAPPED_BASE, which is useless since the top-down scheme
> already failed on the whole address space: instead, simply use
> mmap_base.
>
> Along the way, it allows to get rid of of mmap_legacy_base and
> mmap_compat_legacy_base from mm_struct.
>
> Note that arm and mips already implement this behaviour.
>
> Alexandre Ghiti (8):
>    s390: Start fallback of top-down mmap at mm->mmap_base
>    sh: Start fallback of top-down mmap at mm->mmap_base
>    sparc: Start fallback of top-down mmap at mm->mmap_base
>    x86, hugetlbpage: Start fallback of top-down mmap at mm->mmap_base
>    mm: Start fallback top-down mmap at mm->mmap_base
>    parisc: Use mmap_base, not mmap_legacy_base, as low_limit for
>      bottom-up mmap
>    x86: Use mmap_*base, not mmap_*legacy_base, as low_limit for bottom-up
>      mmap
>    mm: Remove mmap_legacy_base and mmap_compat_legacy_code fields from
>      mm_struct
>
>   arch/parisc/kernel/sys_parisc.c  |  8 +++-----
>   arch/s390/mm/mmap.c              |  2 +-
>   arch/sh/mm/mmap.c                |  2 +-
>   arch/sparc/kernel/sys_sparc_64.c |  2 +-
>   arch/sparc/mm/hugetlbpage.c      |  2 +-
>   arch/x86/include/asm/elf.h       |  2 +-
>   arch/x86/kernel/sys_x86_64.c     |  4 ++--
>   arch/x86/mm/hugetlbpage.c        |  7 ++++---
>   arch/x86/mm/mmap.c               | 20 +++++++++-----------
>   include/linux/mm_types.h         |  2 --
>   mm/debug.c                       |  4 ++--
>   mm/mmap.c                        |  2 +-
>   12 files changed, 26 insertions(+), 31 deletions(-)
>

Hi everyone,

This is just a preparatory series for the merging of x86 mmap top-down 
functions with
the generic ones (those should get into v5.3), if you could take some 
time to take a look,
that would be great :)

Thanks,

Alex

