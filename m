Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4A226B4A61
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 15:33:34 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a199so23610688qkb.23
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:33:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1sor5250502qte.27.2018.11.27.12.33.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 12:33:34 -0800 (PST)
Subject: Re: [PATCH v2] mm/zsmalloc.c: Fix zsmalloc 32-bit PAE support
References: <20181025134344.GZ30658@n2100.armlinux.org.uk>
 <20181121001150.405-1-rafael.tinoco@linaro.org>
 <91776bf8-0d12-1cc4-1ffb-ca3c486aeb0b@linaro.org>
From: Rafael David Tinoco <rafael.tinoco@linaro.org>
Message-ID: <93b0cce5-4ceb-14ab-5987-af54f15958f2@linaro.org>
Date: Tue, 27 Nov 2018 18:33:29 -0200
MIME-Version: 1.0
In-Reply-To: <91776bf8-0d12-1cc4-1ffb-ca3c486aeb0b@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk
Cc: Rafael David Tinoco <rafael.tinoco@linaro.org>, broonie@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com

On 11/20/18 10:18 PM, Rafael David Tinoco wrote:
> 
> Russell,
> 
> I have tried to place MAX_POSSIBLE_PHYSMEM_BITS in the best available
> header for each architecture, considering different paging levels, PAE
> existence, and existing similar definitions. Also, I have only
> considered those architectures already having "sparsemem.h" header.
> 
> Would you mind reviewing it ?

Should I re-send the this v2 (as v3) with complete list of
get_maintainer.pl ? I was in doubt because I'm touching headers from
several archs and I'm not sure who, if it is accepted, would merge it.

Thank you
-- 
Rafael D. Tinoco
Linaro Kernel Validation
