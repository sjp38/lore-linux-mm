Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8C00A828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 13:46:02 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id r129so178964643wmr.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 10:46:02 -0800 (PST)
Date: Wed, 3 Feb 2016 13:45:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [mm -next] mapping->tree_lock inconsistent lock state
Message-ID: <20160203184509.GB4007@cmpxchg.org>
References: <20160203153633.GA32219@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160203153633.GA32219@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Benjamin LaHaise <bcrl@kvack.org>

On Thu, Feb 04, 2016 at 12:36:33AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> next-20160203
> 
> [ 3587.997451] =================================
> [ 3587.997453] [ INFO: inconsistent lock state ]
> [ 3587.997456] 4.5.0-rc2-next-20160203-dbg-00007-g37a0a9d-dirty #377 Not tainted
> [ 3587.997457] ---------------------------------
> [ 3587.997459] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.

Thanks Sergey. Vladimir sent a patch to move mem_cgroup_migrate() out
of the IRQ-disabled section:

http://marc.info/?l=linux-mm&m=145452460721208&w=2

It looks like Vladimir's original message didn't make it to linux-mm,
only my reply to it; CC Ben LaHaise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
