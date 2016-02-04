Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7E63B680F7F
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 19:17:03 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id w123so23772496pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 16:17:03 -0800 (PST)
Date: Thu, 4 Feb 2016 09:18:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [mm -next] mapping->tree_lock inconsistent lock state
Message-ID: <20160204001816.GA1861@swordfish>
References: <20160203153633.GA32219@swordfish>
 <20160203184509.GB4007@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160203184509.GB4007@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Benjamin LaHaise <bcrl@kvack.org>

On (02/03/16 13:45), Johannes Weiner wrote:
> On Thu, Feb 04, 2016 at 12:36:33AM +0900, Sergey Senozhatsky wrote:
> > Hello,
> > 
> > next-20160203
> > 
> > [ 3587.997451] =================================
> > [ 3587.997453] [ INFO: inconsistent lock state ]
> > [ 3587.997456] 4.5.0-rc2-next-20160203-dbg-00007-g37a0a9d-dirty #377 Not tainted
> > [ 3587.997457] ---------------------------------
> > [ 3587.997459] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> 
> Thanks Sergey. Vladimir sent a patch to move mem_cgroup_migrate() out
> of the IRQ-disabled section:
> 
> http://marc.info/?l=linux-mm&m=145452460721208&w=2
> 
> It looks like Vladimir's original message didn't make it to linux-mm,
> only my reply to it; CC Ben LaHaise.

Thanks Johannes. Will test it (well, just in case) later today.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
