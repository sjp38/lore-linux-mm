Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 4697B6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 20:20:53 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so1088671pbb.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 17:20:52 -0700 (PDT)
Date: Tue, 25 Sep 2012 17:20:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] pagemap: fix wrong KPF_THP on slab pages
In-Reply-To: <1348592715-31006-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1209251719400.21751@chino.kir.corp.google.com>
References: <1348592715-31006-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 25 Sep 2012, Naoya Horiguchi wrote:

> KPF_THP can be set on non-huge compound pages like slab pages, because
> PageTransCompound only sees PG_head and PG_tail. Obviously this is a bug
> and breaks user space applications which look for thp via /proc/kpageflags.
> Currently thp is constructed only on anonymous pages, so this patch makes
> KPF_THP be set when both of PageAnon and PageTransCompound are true.
> 
> Changelog in v2:
>   - add a comment in code
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Wouldn't PageTransCompound(page) && !PageHuge(page) && !PageSlab(page) be 
better for a future extension of thp support?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
