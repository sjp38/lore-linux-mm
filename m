Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6F5F8E0004
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:50:27 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id c14-v6so5505550wmb.2
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:50:27 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t82-v6si2290829wme.177.2018.09.27.06.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 06:50:26 -0700 (PDT)
Date: Thu, 27 Sep 2018 15:50:25 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] csky: fixups after bootmem removal
Message-ID: <20180927135025.GA8628@lst.de>
References: <20180926112744.GC4628@rapoport-lnx> <20180927134705.GA6376@guoren>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927134705.GA6376@guoren>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guo Ren <ren_guo@c-sky.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 27, 2018 at 09:47:05PM +0800, Guo Ren wrote:
> Hi Christoph,
> 
> Don't forget arch/csky for the patch:
> dma-mapping: merge direct and noncoherent ops.
> 
> arch/csky/Kconfig
> 
> -	select DMA_NONCOHERENT_OPS
> +	select DMA_DIRECT_OPS

Thanks for the reminder.  I'll just try to get my pull request in
irst so that you'll have to fix it up :)
