Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9506B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 05:49:50 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 84-v6so3946318oii.20
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 02:49:50 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w49-v6si1830551oti.105.2018.04.20.02.49.48
        for <linux-mm@kvack.org>;
        Fri, 20 Apr 2018 02:49:49 -0700 (PDT)
Date: Fri, 20 Apr 2018 10:49:44 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] treewide: use PHYS_ADDR_MAX to avoid type casting
 ULLONG_MAX
Message-ID: <20180420094943.25erqjuco7ern2sy@armageddon.cambridge.arm.com>
References: <20180419214204.19322-1-stefan@agner.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419214204.19322-1-stefan@agner.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Agner <stefan@agner.ch>
Cc: akpm@linux-foundation.org, mhocko@suse.com, torvalds@linux-foundation.org, pasha.tatashin@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 19, 2018 at 11:42:04PM +0200, Stefan Agner wrote:
> With PHYS_ADDR_MAX there is now a type safe variant for all
> bits set. Make use of it.
> 
> Patch created using a sematic patch as follows:
> 
> // <smpl>
> @@
> typedef phys_addr_t;
> @@
> -(phys_addr_t)ULLONG_MAX
> +PHYS_ADDR_MAX
> // </smpl>
> 
> Signed-off-by: Stefan Agner <stefan@agner.ch>
> ---
>  arch/arm64/mm/init.c               | 6 +++---

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
