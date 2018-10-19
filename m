Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58D4A6B0010
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 04:17:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x20-v6so20003187eda.21
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 01:17:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i22-v6sor7634342ejz.14.2018.10.19.01.17.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Oct 2018 01:17:32 -0700 (PDT)
Date: Fri, 19 Oct 2018 08:17:30 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] memblock: remove stale #else and the code it protects
Message-ID: <20181019081729.klvckcytnhheaian@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1538067825-24835-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538067825-24835-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Which tree it applies?

On Thu, Sep 27, 2018 at 08:03:45PM +0300, Mike Rapoport wrote:
>During removal of HAVE_MEMBLOCK definition, the #else clause of the
>
>	#ifdef CONFIG_HAVE_MEMBLOCK
>		...
>	#else
>		...
>	#endif
>
>conditional was not removed.
>
>Remove it now.
>
>Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
>Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
>Cc: Michal Hocko <mhocko@suse.com>
>---
> include/linux/memblock.h | 5 -----
> 1 file changed, 5 deletions(-)
>
>diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>index d3bc270..d4d0e01 100644
>--- a/include/linux/memblock.h
>+++ b/include/linux/memblock.h
>@@ -597,11 +597,6 @@ static inline void early_memtest(phys_addr_t start, phys_addr_t end)
> {
> }
> #endif
>-#else
>-static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align)
>-{
>-	return 0;
>-}
> 
> #endif /* __KERNEL__ */
> 
>-- 
>2.7.4

-- 
Wei Yang
Help you, Help me
