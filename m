Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32D826B322D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 13:17:50 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id j15so6022832ota.17
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:17:50 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w83-v6si24198349oib.162.2018.11.23.10.17.49
        for <linux-mm@kvack.org>;
        Fri, 23 Nov 2018 10:17:49 -0800 (PST)
Date: Fri, 23 Nov 2018 18:17:44 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V3 1/5] mm: mmap: Allow for "high" userspace addresses
Message-ID: <20181123181744.GK3360@arrakis.emea.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-2-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114133920.7134-2-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, jcm@redhat.com, ard.biesheuvel@linaro.org

On Wed, Nov 14, 2018 at 01:39:16PM +0000, Steve Capper wrote:
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

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
