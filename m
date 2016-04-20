Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2647D6B0284
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 19:45:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so115982411pfb.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 16:45:08 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id th8si6078731pab.238.2016.04.20.16.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 16:45:07 -0700 (PDT)
Date: Thu, 21 Apr 2016 09:45:03 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH mmotm 1/5] huge tmpfs: try to allocate huge pages split
 into a team fix
Message-ID: <20160421094503.27906446@canb.auug.org.au>
In-Reply-To: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Sat, 16 Apr 2016 16:27:02 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
>
> Please replace the
> huge-tmpfs-try-to-allocate-huge-pages-split-into-a-team-fix.patch
> you added to your tree by this one: nothing wrong with Stephen's,
> but in this case I think the source is better off if we simply
> remove that BUILD_BUG() instead of adding an IS_ENABLED():
> fixes build problem seen on arm when putting together linux-next.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/shmem.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1744,7 +1744,6 @@ static inline struct page *shmem_hugetea
>  
>  static inline void shmem_disband_hugeteam(struct page *page)
>  {
> -	BUILD_BUG();
>  }
>  
>  static inline void shmem_added_to_hugeteam(struct page *page,

I have replaced my fix with the above in today's linux-next.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
