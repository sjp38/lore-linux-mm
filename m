Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDDEB6B0003
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 06:13:29 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id a9-v6so9113531wrw.20
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 03:13:29 -0700 (PDT)
Received: from mail.bootlin.com (mail.bootlin.com. [62.4.15.54])
        by mx.google.com with ESMTP id v15-v6si8218966wru.385.2018.08.11.03.13.27
        for <linux-mm@kvack.org>;
        Sat, 11 Aug 2018 03:13:28 -0700 (PDT)
Date: Sat, 11 Aug 2018 12:12:51 +0200
From: Boris Brezillon <boris.brezillon@bootlin.com>
Subject: Re: mmotm 2018-08-09-20-10 uploaded (mtd/nand/raw/atmel/)
Message-ID: <20180811121251.1baa8696@bbrezillon>
In-Reply-To: <a7523628-9728-6586-1bab-e256d3ba56a7@infradead.org>
References: <20180810031103.Ym0HzDAqN%akpm@linux-foundation.org>
	<a7523628-9728-6586-1bab-e256d3ba56a7@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, Boris Brezillon <boris.brezillon@free-electrons.com>, linux-mtd@lists.infradead.org

Hi Randy,

On Fri, 10 Aug 2018 08:37:01 -0700
Randy Dunlap <rdunlap@infradead.org> wrote:

> On 08/09/2018 08:11 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2018-08-09-20-10 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.  
> 
> on i386:
> 
> ERROR: "of_gen_pool_get" [drivers/mtd/nand/raw/atmel/atmel-nand-controller.ko] undefined!
> ERROR: "gen_pool_dma_alloc" [drivers/mtd/nand/raw/atmel/atmel-nand-controller.ko] undefined!
> ERROR: "gen_pool_free" [drivers/mtd/nand/raw/atmel/atmel-nand-controller.ko] undefined!

Hm, missing 'depends on GENERIC_ALLOCATOR'. I'll send a patch to fix
that.

Thanks for reporting the problem.

Boris
