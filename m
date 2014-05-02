Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 23DA66B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 18:35:03 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so3951926pde.12
        for <linux-mm@kvack.org>; Fri, 02 May 2014 15:35:02 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id gr5si305166pac.278.2014.05.02.15.35.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 15:35:02 -0700 (PDT)
Message-ID: <53641D8C.6040601@oracle.com>
Date: Fri, 02 May 2014 18:34:52 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/17] mm: page_alloc: Use word-based accesses for get/set
 pageblock bitmaps
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-9-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

Hi Mel,

Vlastimil Babka suggested I should try this patch to work around a different
issue I'm seeing, and noticed that it doesn't build because:

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> +void set_pageblock_flags_mask(struct page *page,
> +				unsigned long flags,
> +				unsigned long end_bitidx,
> +				unsigned long nr_flag_bits,
> +				unsigned long mask);

set_pageblock_flags_mask() is declared.


> +static inline void set_pageblock_flags_group(struct page *page,
> +					unsigned long flags,
> +					int start_bitidx, int end_bitidx)
> +{
> +	unsigned long nr_flag_bits = end_bitidx - start_bitidx + 1;
> +	unsigned long mask = (1 << nr_flag_bits) - 1;
> +
> +	set_pageblock_flags_mask(page, flags, end_bitidx, nr_flag_bits, mask);
> +}

And used here, but never actually defined.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
