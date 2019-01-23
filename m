Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0828F8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:57:48 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g13so2543803plo.10
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:57:47 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k20si19123583pfb.215.2019.01.23.14.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:57:46 -0800 (PST)
Date: Wed, 23 Jan 2019 22:57:45 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH] mm: proc: smaps_rollup: Fix pss_locked calculation
In-Reply-To: <20190121011049.160505-1-sspatil@android.com>
References: <20190121011049.160505-1-sspatil@android.com>
Message-Id: <20190123225746.5B3DF218A4@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, Sandeep Patil <sspatil@android.com>, vbabka@suse.cz, adobriyan@gmail.com, akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 493b0e9d945f mm: add /proc/pid/smaps_rollup.

The bot has tested the following trees: v4.20.3, v4.19.16, v4.14.94.

v4.20.3: Build OK!
v4.19.16: Build OK!
v4.14.94: Failed to apply! Possible dependencies:
    8526d84f8171 ("fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory")
    8e68d689afe3 ("mm: /proc/pid/smaps: factor out mem stats gathering")
    af5b0f6a09e4 ("mm: consolidate page table accounting")
    b4e98d9ac775 ("mm: account pud page tables")
    c4812909f5d5 ("mm: introduce wrappers to access mm->nr_ptes")
    d1be35cb6f96 ("proc: add seq_put_decimal_ull_width to speed up /proc/pid/smaps")


How should we proceed with this patch?

--
Thanks,
Sasha
