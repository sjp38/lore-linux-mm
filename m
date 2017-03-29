Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA4FF6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 12:55:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 34so4306742wrb.20
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 09:55:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i16si8699592wrc.170.2017.03.29.09.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 09:55:32 -0700 (PDT)
Date: Wed, 29 Mar 2017 12:55:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v7 1/9] mm, swap: Make swap cluster size same of THP
 size on x86_64
Message-ID: <20170329165522.GA31821@cmpxchg.org>
References: <20170328053209.25876-1-ying.huang@intel.com>
 <20170328053209.25876-2-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328053209.25876-2-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Tue, Mar 28, 2017 at 01:32:01PM +0800, Huang, Ying wrote:
> @@ -499,6 +499,19 @@ config FRONTSWAP
>  
>  	  If unsure, say Y to enable frontswap.
>  
> +config ARCH_USES_THP_SWAP_CLUSTER
> +	bool
> +	default n

This is fine.

> +config THP_SWAP_CLUSTER
> +	bool
> +	depends on SWAP && TRANSPARENT_HUGEPAGE && ARCH_USES_THP_SWAP_CLUSTER
> +	default y
> +	help
> +	  Use one swap cluster to hold the contents of the THP
> +	  (Transparent Huge Page) swapped out.  The size of the swap
> +	  cluster will be same as that of THP.

But this is a super weird thing to ask the user. How would they know
what to say, if we don't know? I don't think this should be a config
knob at all. Merge the two config items into a simple

config THP_SWAP_CLUSTER
     bool
     default n

and let the archs with reasonable THP sizes select it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
