Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD996B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 02:44:32 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so19580092lbc.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:44:32 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w81si48003187wmd.93.2016.06.01.23.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 23:44:31 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n184so12407984wmn.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:44:31 -0700 (PDT)
Date: Thu, 2 Jun 2016 08:44:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm/vmstat: remove unused header cpumask.h
Message-ID: <20160602064428.GE1995@dhcp22.suse.cz>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
 <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com>
 <866efd744a89b6e16c9d3acd1a00b011adbd59af.1464847139.git.geliangtang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <866efd744a89b6e16c9d3acd1a00b011adbd59af.1464847139.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 02-06-16 14:15:35, Geliang Tang wrote:
> Remove unused header cpumask.h from mm/vmstat.c.

what about for_each_online_cpu? Maybe it will get included transitively
from other header but I guess it is better to have a direct include
because transitive includes lead to unexpected compilation issues.

> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  mm/vmstat.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1b585f8..3653449 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -15,7 +15,6 @@
>  #include <linux/module.h>
>  #include <linux/slab.h>
>  #include <linux/cpu.h>
> -#include <linux/cpumask.h>
>  #include <linux/vmstat.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
