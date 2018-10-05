Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2246B0275
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 12:32:57 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id d23-v6so9259960oib.6
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 09:32:57 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y206-v6si3933512oiy.213.2018.10.05.09.32.56
        for <linux-mm@kvack.org>;
        Fri, 05 Oct 2018 09:32:56 -0700 (PDT)
Date: Fri, 5 Oct 2018 17:32:51 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 3/5] arm64: mm: make use of new memblocks_present() helper
Message-ID: <20181005163248.naky3huexiiwycra@mbp>
References: <20181005161642.2462-1-logang@deltatee.com>
 <20181005161642.2462-4-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181005161642.2462-4-logang@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, Christoph Hellwig <hch@lst.de>, Albert Ou <aou@eecs.berkeley.edu>, Stephen Bates <sbates@raithlin.com>

On Fri, Oct 05, 2018 at 10:16:40AM -0600, Logan Gunthorpe wrote:
> Cleanup the arm64_memory_present() function seeing it's very
> similar to other arches.
> 
> memblocks_present() is a direct replacement of arm64_memory_present()
> 
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> ---
>  arch/arm64/mm/init.c | 20 +-------------------
>  1 file changed, 1 insertion(+), 19 deletions(-)

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
