Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB5948E0097
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 16:39:43 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v12so4771375plp.16
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 13:39:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k37sor35993791pgb.78.2019.01.24.13.39.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 13:39:42 -0800 (PST)
Date: Thu, 24 Jan 2019 13:39:40 -0800
From: Sandeep Patil <sspatil@android.com>
Subject: Re: [PATCH] mm: proc: smaps_rollup: Fix pss_locked calculation
Message-ID: <20190124213940.GG243073@google.com>
References: <20190121011049.160505-1-sspatil@android.com>
 <20190123225746.5B3DF218A4@mail.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190123225746.5B3DF218A4@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: vbabka@suse.cz, adobriyan@gmail.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, Jan 23, 2019 at 10:57:45PM +0000, Sasha Levin wrote:
> Hi,
> 
> [This is an automated email]
> 
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: 493b0e9d945f mm: add /proc/pid/smaps_rollup.
> 
> The bot has tested the following trees: v4.20.3, v4.19.16, v4.14.94.
> 
> v4.20.3: Build OK!
> v4.19.16: Build OK!
> v4.14.94: Failed to apply! Possible dependencies:
>     8526d84f8171 ("fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory")
>     8e68d689afe3 ("mm: /proc/pid/smaps: factor out mem stats gathering")
>     af5b0f6a09e4 ("mm: consolidate page table accounting")
>     b4e98d9ac775 ("mm: account pud page tables")
>     c4812909f5d5 ("mm: introduce wrappers to access mm->nr_ptes")
>     d1be35cb6f96 ("proc: add seq_put_decimal_ull_width to speed up /proc/pid/smaps")
> 
> 
> How should we proceed with this patch?

I will send 4.14 / 4.9 backports to -stable if / when the patch gets
accepted.

- ssp
