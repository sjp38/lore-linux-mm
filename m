Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEE8E6B0010
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:23:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 31-v6so3577472edr.19
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:23:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p52-v6si3810645edc.171.2018.10.04.00.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:23:21 -0700 (PDT)
Date: Thu, 4 Oct 2018 09:23:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] mm/vmstat: assert that vmstat_text is in sync
 with stat_items_size
Message-ID: <20181004072320.GC22233@dhcp22.suse.cz>
References: <20181001143138.95119-1-jannh@google.com>
 <20181001143138.95119-3-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181001143138.95119-3-jannh@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Mon 01-10-18 16:31:38, Jann Horn wrote:
> As evidenced by the previous two patches, having two gigantic arrays that
> must manually be kept in sync, including ifdefs, isn't exactly robust.
> To make it easier to catch such issues in the future, add a BUILD_BUG_ON().
> 
> Signed-off-by: Jann Horn <jannh@google.com>

We should have done that looong ago. Thanks!
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmstat.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7878da76abf2..b678c607e490 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1663,6 +1663,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
>  	stat_items_size += sizeof(struct vm_event_state);
>  #endif
>  
> +	BUILD_BUG_ON(stat_items_size !=
> +		     ARRAY_SIZE(vmstat_text) * sizeof(unsigned long));
>  	v = kmalloc(stat_items_size, GFP_KERNEL);
>  	m->private = v;
>  	if (!v)
> -- 
> 2.19.0.605.g01d371f741-goog

-- 
Michal Hocko
SUSE Labs
