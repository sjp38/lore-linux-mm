Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D561F6B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:19:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d8-v6so4872330edq.11
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:19:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x8-v6si3531297edh.309.2018.10.04.00.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:19:38 -0700 (PDT)
Date: Thu, 4 Oct 2018 09:19:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm/vmstat: fix outdated vmstat_text
Message-ID: <20181004071935.GA22233@dhcp22.suse.cz>
References: <20181001143138.95119-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181001143138.95119-1-jannh@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Mon 01-10-18 16:31:36, Jann Horn wrote:
> commit 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
> removed the VMACACHE_FULL_FLUSHES statistics, but didn't remove the
> corresponding entry in vmstat_text. This causes an out-of-bounds access in
> vmstat_show().
> 
> Luckily this only affects kernels with CONFIG_DEBUG_VM_VMACACHE=y, which is
> probably very rare.
> 
> Fixes: 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmstat.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 8ba0870ecddd..4cea7b8f519d 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1283,7 +1283,6 @@ const char * const vmstat_text[] = {
>  #ifdef CONFIG_DEBUG_VM_VMACACHE
>  	"vmacache_find_calls",
>  	"vmacache_find_hits",
> -	"vmacache_full_flushes",
>  #endif
>  #ifdef CONFIG_SWAP
>  	"swap_ra",
> -- 
> 2.19.0.605.g01d371f741-goog

-- 
Michal Hocko
SUSE Labs
