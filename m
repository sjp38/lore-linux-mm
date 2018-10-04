Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 329896B000D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:22:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 31-v6so3575877edr.19
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:22:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9-v6si3136959edu.214.2018.10.04.00.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:22:19 -0700 (PDT)
Date: Thu, 4 Oct 2018 09:22:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/3] mm/vmstat: skip NR_TLB_REMOTE_FLUSH* properly
Message-ID: <20181004072217.GB22233@dhcp22.suse.cz>
References: <20181001143138.95119-1-jannh@google.com>
 <20181001143138.95119-2-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181001143138.95119-2-jannh@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Mon 01-10-18 16:31:37, Jann Horn wrote:
> commit 5dd0b16cdaff ("mm/vmstat: Make NR_TLB_REMOTE_FLUSH_RECEIVED
> available even on UP") made the availability of the NR_TLB_REMOTE_FLUSH*
> counters inside the kernel unconditional to reduce #ifdef soup, but
> (either to avoid showing dummy zero counters to userspace, or because that
> code was missed) didn't update the vmstat_array, meaning that all following
> counters would be shown with incorrect values.
> 
> This only affects kernel builds with
> CONFIG_VM_EVENT_COUNTERS=y && CONFIG_DEBUG_TLBFLUSH=y && CONFIG_SMP=n.
> 
> Fixes: 5dd0b16cdaff ("mm/vmstat: Make NR_TLB_REMOTE_FLUSH_RECEIVED available even on UP")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmstat.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4cea7b8f519d..7878da76abf2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1275,6 +1275,9 @@ const char * const vmstat_text[] = {
>  #ifdef CONFIG_SMP
>  	"nr_tlb_remote_flush",
>  	"nr_tlb_remote_flush_received",
> +#else
> +	"", /* nr_tlb_remote_flush */
> +	"", /* nr_tlb_remote_flush_received */
>  #endif /* CONFIG_SMP */
>  	"nr_tlb_local_flush_all",
>  	"nr_tlb_local_flush_one",
> -- 
> 2.19.0.605.g01d371f741-goog

-- 
Michal Hocko
SUSE Labs
