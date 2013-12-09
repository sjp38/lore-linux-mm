Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id C491E6B0121
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 17:05:29 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id b6so3208433yha.23
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 14:05:29 -0800 (PST)
Received: from mail-yh0-x236.google.com (mail-yh0-x236.google.com [2607:f8b0:4002:c01::236])
        by mx.google.com with ESMTPS id v65si11323291yhp.158.2013.12.09.14.05.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 14:05:28 -0800 (PST)
Received: by mail-yh0-f54.google.com with SMTP id z12so3243976yhz.13
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 14:05:28 -0800 (PST)
Date: Mon, 9 Dec 2013 14:05:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add show num_poisoned_pages when oom
In-Reply-To: <1386625778-kutyp5f6-mutt-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.02.1312091405170.11026@chino.kir.corp.google.com>
References: <52A592DE.7010302@huawei.com> <1386625778-kutyp5f6-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 9 Dec 2013, Naoya Horiguchi wrote:

> > Show num_poisoned_pages when oom, it is helpful to find the reason.
> > 
> > Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> > ---
> >  lib/show_mem.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/lib/show_mem.c b/lib/show_mem.c
> > index 5847a49..1cbdcd8 100644
> > --- a/lib/show_mem.c
> > +++ b/lib/show_mem.c
> > @@ -46,4 +46,7 @@ void show_mem(unsigned int filter)
> >  	printk("%lu pages in pagetable cache\n",
> >  		quicklist_total_size());
> >  #endif
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +	printk("%lu pages poisoned\n", atomic_long_read(&num_poisoned_pages));
> > +#endif
> >  }
> 
> I think that just "poisoned" could be confusing because this word seems to
> be used also in other context (like slab and list_debug handling.)
> "hwpoisoned" or "hardware corrupted" (which is the same label in /proc/meminfo)
> looks better to me.
> 

Ah, good point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
