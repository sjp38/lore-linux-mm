Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2B578E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 14:00:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so189583edz.15
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:00:34 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i3si4020379edk.411.2019.01.14.11.00.33
        for <linux-mm@kvack.org>;
        Mon, 14 Jan 2019 11:00:33 -0800 (PST)
Date: Mon, 14 Jan 2019 19:00:25 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 3/3] bitops.h: set_mask_bits() to return old value
Message-ID: <20190114190025.GA29167@fuggles.cambridge.arm.com>
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
 <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>
Cc: linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, peterz@infradead.org, Miklos Szeredi <mszeredi@redhat.com>, Ingo Molnar <mingo@kernel.org>, Jani Nikula <jani.nikula@intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jan 10, 2019 at 04:26:27PM -0800, Vineet Gupta wrote:
> | > Also, set_mask_bits is used in fs quite a bit and we can possibly come up
> | > with a generic llsc based implementation (w/o the cmpxchg loop)
> |
> | May I also suggest changing the return value of set_mask_bits() to old.
> |
> | You can compute the new value given old, but you cannot compute the old
> | value given new, therefore old is the better return value. Also, no
> | current user seems to use the return value, so changing it is without
> | risk.
> 
> Link: http://lkml.kernel.org/g/20150807110955.GH16853@twins.programming.kicks-ass.net
> Suggested-by: Peter Zijlstra <peterz@infradead.org>
> Cc: Miklos Szeredi <mszeredi@redhat.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Jani Nikula <jani.nikula@intel.com>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> ---
>  include/linux/bitops.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/bitops.h b/include/linux/bitops.h
> index 705f7c442691..602af23b98c7 100644
> --- a/include/linux/bitops.h
> +++ b/include/linux/bitops.h
> @@ -246,7 +246,7 @@ static __always_inline void __assign_bit(long nr, volatile unsigned long *addr,
>  		new__ = (old__ & ~mask__) | bits__;		\
>  	} while (cmpxchg(ptr, old__, new__) != old__);		\
>  								\
> -	new__;							\
> +	old__;							\
>  })
>  #endif

Acked-by: Will Deacon <will.deacon@arm.com>

May also explain why no in-tree users appear to use the return value!

Will
