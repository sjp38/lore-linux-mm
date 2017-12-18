Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54EB46B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 15:41:28 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y23so10010657wra.16
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 12:41:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 132si117151wms.147.2017.12.18.12.41.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 12:41:27 -0800 (PST)
Date: Mon, 18 Dec 2017 21:41:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't use the same value for MAP_FIXED_SAFE and
 MAP_SYNC
Message-ID: <20171218204052.GR16951@dhcp22.suse.cz>
References: <20171218091302.GL16951@dhcp22.suse.cz>
 <20171218184916.24445-1-avagin@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171218184916.24445-1-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrei Vagin <avagin@openvz.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon 18-12-17 10:49:16, Andrei Vagin wrote:
> Cc: Michal Hocko <mhocko@kernel.org>
> Fixes: ("fs, elf: drop MAP_FIXED usage from elf_map")
> Signed-off-by: Andrei Vagin <avagin@openvz.org>
> ---
>  include/uapi/asm-generic/mman-common.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index b37502cbbef7..2db3fa287274 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -26,7 +26,9 @@
>  #else
>  # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
>  #endif
> -#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
> +
> +/* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
> +#define MAP_FIXED_SAFE	0x100000		/* MAP_FIXED which doesn't unmap underlying mapping */

Ouch, I was developing on top of mmotm which didn't have the new the new
MAP_SYNC. Thanks for catching that. Andrew, could you fold this into the
patch, please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
