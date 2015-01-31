Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 25AD16B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 01:23:24 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so60741468pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 22:23:23 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id uv4si16237470pbc.110.2015.01.30.22.23.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 22:23:23 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so60720304pab.3
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 22:23:22 -0800 (PST)
Subject: Re: [PATCH 02/19] arm64: expose number of page table levels on Kconfig level
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <20150130145619.GA18786@localhost>
Date: Sat, 31 Jan 2015 15:23:21 +0900
Content-Transfer-Encoding: 7bit
Message-Id: <4EC115AB-C100-4D62-99CA-5BB04303609B@gmail.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com> <1422629008-13689-3-git-send-email-kirill.shutemov@linux.intel.com> <20150130145619.GA18786@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Guenter Roeck <linux@roeck-us.net>, Will Deacon <Will.Deacon@arm.com>

On Jan 30, 2015, at 11:56 PM, Catalin Marinas wrote:
> On Fri, Jan 30, 2015 at 02:43:11PM +0000, Kirill A. Shutemov wrote:
>> We would want to use number of page table level to define mm_struct.
>> Let's expose it as CONFIG_PGTABLE_LEVELS.
>> 
>> ARM64_PGTABLE_LEVELS is renamed to PGTABLE_LEVELS and defined before
>> sourcing init/Kconfig: arch/Kconfig will define default value and it's
>> sourced from init/Kconfig.
>> 
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
> 
> It looks fine.
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>

A system can boot up successfully on top of arm64/for-next/core branch under
4KB + {3|4}Level + CONFIG_DEBUG_RODATA, but I don't try it with 64KB pages.

Best Regards
Jungseok Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
