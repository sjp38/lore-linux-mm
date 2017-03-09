Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5E6C6B03FB
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 01:02:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j5so96584895pfb.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:02:31 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p19si5453534pli.148.2017.03.08.22.02.30
        for <linux-mm@kvack.org>;
        Wed, 08 Mar 2017 22:02:30 -0800 (PST)
Date: Thu, 9 Mar 2017 15:02:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: "mm: fix lazyfree BUG_ON check in try_to_unmap_one()" build error
Message-ID: <20170309060226.GB854@bbox>
References: <20170309042908.GA26702@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170309042908.GA26702@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Sergey,

On Thu, Mar 09, 2017 at 01:29:08PM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> /* I can't https://marc.info/?l=linux-kernel&m=148886631303107 thread
>    in my mail box for some reason so the Reply-To message-id may be wrong. */
> 
> 
> 
> commit "mm: fix lazyfree BUG_ON check in try_to_unmap_one()"
> (mmotm fd07630cbf59bead90046dd3e5cfd891e58e6987)
> 
> 
> 	if (VM_WARN_ON_ONCE(PageSwapBacked(page) !=
> 			PageSwapCache(page))) {
> 	...
> 	}
> 
> 
> does not compile on !CONFIG_DEBUG_VM configs, because VM_WARN_ONCE() is
> 
> 	#define BUILD_BUG_ON_INVALID(e) ((void)(sizeof((__force long)(e))))
> 
> 
> 
> In file included from ./include/linux/mmdebug.h:4:0,
>                  from ./include/linux/mm.h:8,
>                  from mm/rmap.c:48:
> mm/rmap.c: In function a??try_to_unmap_onea??:
> ./include/linux/bug.h:45:33: error: void value not ignored as it ought to be
>  #define BUILD_BUG_ON_INVALID(e) ((void)(sizeof((__force long)(e))))
>                                  ^
> ./include/linux/mmdebug.h:49:31: note: in expansion of macro a??BUILD_BUG_ON_INVALIDa??
>  #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
>                                ^~~~~~~~~~~~~~~~~~~~
> mm/rmap.c:1416:8: note: in expansion of macro a??VM_WARN_ON_ONCEa??
>     if (VM_WARN_ON_ONCE(PageSwapBacked(page) !=
>         ^~~~~~~~~~~~~~~
> 
> 	-ss
> 

Thanks for the report, Sergey!
If others are not against, I want to go this.
