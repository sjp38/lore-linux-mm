Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id EED476B4980
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:10:23 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id e141so12391088oig.11
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:10:23 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w81si1965363oie.88.2018.11.27.09.10.22
        for <linux-mm@kvack.org>;
        Tue, 27 Nov 2018 09:10:23 -0800 (PST)
Date: Tue, 27 Nov 2018 17:10:18 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V3 3/5] arm64: mm: Define arch_get_mmap_end,
 arch_get_mmap_base
Message-ID: <20181127171017.GD3563@arrakis.emea.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-4-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114133920.7134-4-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, jcm@redhat.com, ard.biesheuvel@linaro.org

On Wed, Nov 14, 2018 at 01:39:18PM +0000, Steve Capper wrote:
> Now that we have DEFAULT_MAP_WINDOW defined, we can arch_get_mmap_end
> and arch_get_mmap_base helpers to allow for high addresses in mmap.
> 
> Signed-off-by: Steve Capper <steve.capper@arm.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
