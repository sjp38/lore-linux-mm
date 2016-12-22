Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFA0280258
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 17:12:36 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so38337873wmu.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:12:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si29579256wmb.73.2016.12.22.14.12.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 14:12:35 -0800 (PST)
From: Andreas Schwab <schwab@suse.de>
Subject: Re: [PATCH] mm: pmd dirty emulation in page fault handler
References: <1482364101-16204-1-git-send-email-minchan@kernel.org>
	<20161222081713.GA32480@node.shutemov.name>
	<20161222145203.GA18970@bbox>
Date: Thu, 22 Dec 2016 23:12:32 +0100
In-Reply-To: <20161222145203.GA18970@bbox> (Minchan Kim's message of "Thu, 22
	Dec 2016 23:52:03 +0900")
Message-ID: <8737hftxyn.fsf@suse.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jason Evans <je@fb.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "[4.5+]" <stable@vger.kernel.org>

On Dez 22 2016, Minchan Kim <minchan@kernel.org> wrote:

> From b3ec95c0df91ad113525968a4a6b53030fd0b48d Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Thu, 22 Dec 2016 23:43:49 +0900
> Subject: [PATCH v2] mm: pmd dirty emulation in page fault handler
>
> Andreas reported [1] made a test in jemalloc hang in THP mode in arm64.
> http://lkml.kernel.org/r/mvmmvfy37g1.fsf@hawking.suse.de
>
> The problem is page fault handler supports only accessed flag emulation
> for THP page of SW-dirty/accessed architecture.
>
> This patch enables dirty-bit emulation for those architectures.
> Without it, MADV_FREE makes application hang by repeated fault forever.
>
> [1] b8d3c4c3009d, mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called

Successfully tested a backport to 4.9.

Andreas.

-- 
Andreas Schwab, SUSE Labs, schwab@suse.de
GPG Key fingerprint = 0196 BAD8 1CE9 1970 F4BE  1748 E4D4 88E3 0EEA B9D7
"And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
