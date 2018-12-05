Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id E45256B7552
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 12:36:57 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o13so9696883otl.20
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 09:36:57 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k11si8813340otl.288.2018.12.05.09.36.56
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 09:36:56 -0800 (PST)
Date: Wed, 5 Dec 2018 17:36:52 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V4 2/6] arm64: mm: Introduce DEFAULT_MAP_WINDOW
Message-ID: <20181205173651.GD27881@arrakis.emea.arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-3-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205164145.24568-3-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, jcm@redhat.com, ard.biesheuvel@linaro.org

On Wed, Dec 05, 2018 at 04:41:41PM +0000, Steve Capper wrote:
> We wish to introduce a 52-bit virtual address space for userspace but
> maintain compatibility with software that assumes the maximum VA space
> size is 48 bit.
> 
> In order to achieve this, on 52-bit VA systems, we make mmap behave as
> if it were running on a 48-bit VA system (unless userspace explicitly
> requests a VA where addr[51:48] != 0).
> 
> On a system running a 52-bit userspace we need TASK_SIZE to represent
> the 52-bit limit as it is used in various places to distinguish between
> kernelspace and userspace addresses.
> 
> Thus we need a new limit for mmap, stack, ELF loader and EFI (which uses
> TTBR0) to represent the non-extended VA space.
> 
> This patch introduces DEFAULT_MAP_WINDOW and DEFAULT_MAP_WINDOW_64 and
> switches the appropriate logic to use that instead of TASK_SIZE.
> 
> Signed-off-by: Steve Capper <steve.capper@arm.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
