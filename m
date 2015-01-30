Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 238F56B0073
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:56:43 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so53167939pab.6
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:56:42 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id of10si14017830pbb.84.2015.01.30.06.56.42
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:56:42 -0800 (PST)
Date: Fri, 30 Jan 2015 14:56:20 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 02/19] arm64: expose number of page table levels on
 Kconfig level
Message-ID: <20150130145619.GA18786@localhost>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1422629008-13689-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422629008-13689-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Guenter Roeck <linux@roeck-us.net>, Will Deacon <Will.Deacon@arm.com>

On Fri, Jan 30, 2015 at 02:43:11PM +0000, Kirill A. Shutemov wrote:
> We would want to use number of page table level to define mm_struct.
> Let's expose it as CONFIG_PGTABLE_LEVELS.
> 
> ARM64_PGTABLE_LEVELS is renamed to PGTABLE_LEVELS and defined before
> sourcing init/Kconfig: arch/Kconfig will define default value and it's
> sourced from init/Kconfig.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>

It looks fine.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
