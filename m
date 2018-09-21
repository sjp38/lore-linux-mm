Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 666F78E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 07:13:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p11-v6so11340880oih.17
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 04:13:30 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f5-v6si10174020otd.396.2018.09.21.04.13.29
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 04:13:29 -0700 (PDT)
Date: Fri, 21 Sep 2018 12:13:25 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: Kconfig: Remove ARCH_HAS_HOLES_MEMORYMODEL
Message-ID: <20180921111324.GB238853@arrakis.emea.arm.com>
References: <20180831151943.9281-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180831151943.9281-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

On Fri, Aug 31, 2018 at 04:19:43PM +0100, James Morse wrote:
> include/linux/mmzone.h describes ARCH_HAS_HOLES_MEMORYMODEL as
> relevant when parts the memmap have been free()d. This would
> happen on systems where memory is smaller than a sparsemem-section,
> and the extra struct pages are expensive. pfn_valid() on these
> systems returns true for the whole sparsemem-section, so an extra
> memmap_valid_within() check is needed.
> 
> On arm64 we have nomap memory, so always provide pfn_valid() to test
> for nomap pages. This means ARCH_HAS_HOLES_MEMORYMODEL's extra checks
> are already rolled up into pfn_valid().
> 
> Remove it.
> 
> Signed-off-by: James Morse <james.morse@arm.com>

Queued for 4.20. Thanks.

-- 
Catalin
