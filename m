Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 01F986B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 04:38:33 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so92189546lfe.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 01:38:32 -0700 (PDT)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id fx15si2020625wjc.291.2016.08.23.01.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 01:38:31 -0700 (PDT)
Date: Tue, 23 Aug 2016 10:38:30 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [PATCH] mm: clarify COMPACTION Kconfig text
Message-ID: <20160823083830.GC15849@x4>
References: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2016.08.23 at 10:09 +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> The current wording of the COMPACTION Kconfig help text doesn't
> emphasise that disabling COMPACTION might cripple the page allocator
> which relies on the compaction quite heavily for high order requests and
> an unexpected OOM can happen with the lack of compaction. Make sure
> we are vocal about that.

Just a few nitpicks inline below:

>  mm/Kconfig | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 78a23c5c302d..0dff2f05b6d1 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -262,7 +262,14 @@ config COMPACTION
>  	select MIGRATION
>  	depends on MMU
>  	help
> -	  Allows the compaction of memory for the allocation of huge pages.
> +          Compaction is the only memory management component to form
> +          high order (larger physically contiguous) memory blocks
> +          reliably. Page allocator relies on the compaction heavily and
                       The page allo...      on compaction    
> +          the lack of the feature can lead to unexpected OOM killer
> +          invocation for high order memory requests. You shouldnm't
             invocations                                    shouldn't  
> +          disable this option unless there is really a strong reason for
                                              really is      
> +          it and then we are really interested to hear about that at
                            would be    

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
