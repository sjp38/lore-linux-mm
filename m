Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB458E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 14:56:37 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so3439769plt.7
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 11:56:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 15si3565690pgv.351.2018.12.07.11.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 11:56:35 -0800 (PST)
Date: Fri, 7 Dec 2018 11:56:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V5 1/7] mm: mmap: Allow for "high" userspace addresses
Message-Id: <20181207115632.6d5cb691d65cb92917f9d21d@linux-foundation.org>
In-Reply-To: <20181206225042.11548-2-steve.capper@arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
	<20181206225042.11548-2-steve.capper@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, suzuki.poulose@arm.com, jcm@redhat.com

On Thu,  6 Dec 2018 22:50:36 +0000 Steve Capper <steve.capper@arm.com> wrote:

> This patch adds support for "high" userspace addresses that are
> optionally supported on the system and have to be requested via a hint
> mechanism ("high" addr parameter to mmap).
> 
> Architectures such as powerpc and x86 achieve this by making changes to
> their architectural versions of arch_get_unmapped_* functions. However,
> on arm64 we use the generic versions of these functions.
> 
> Rather than duplicate the generic arch_get_unmapped_* implementations
> for arm64, this patch instead introduces two architectural helper macros
> and applies them to arch_get_unmapped_*:
>  arch_get_mmap_end(addr) - get mmap upper limit depending on addr hint
>  arch_get_mmap_base(addr, base) - get mmap_base depending on addr hint
> 
> If these macros are not defined in architectural code then they default
> to (TASK_SIZE) and (base) so should not introduce any behavioural
> changes to architectures that do not define them.
> 
> Signed-off-by: Steve Capper <steve.capper@arm.com>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Andrew Morton <akpm@linux-foundation.org>
