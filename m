Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4F28462009A
	for <linux-mm@kvack.org>; Thu,  6 May 2010 17:25:01 -0400 (EDT)
Date: Thu, 6 May 2010 14:24:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: memcontrol - uninitialised return value
Message-Id: <20100506142417.6d317068.akpm@linux-foundation.org>
In-Reply-To: <1273058509-16625-2-git-send-email-ext-phil.2.carmody@nokia.com>
References: <1273058509-16625-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<1273058509-16625-2-git-send-email-ext-phil.2.carmody@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed,  5 May 2010 14:21:49 +0300
Phil Carmody <ext-phil.2.carmody@nokia.com> wrote:

> From: Phil Carmody <ext-phil.2.carmody@nokia.com>
> 
> Only an out of memory error will cause ret to be set.
> 
> Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 90e32b2..09af773 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3464,7 +3464,7 @@ static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
>  	int type = MEMFILE_TYPE(cft->private);
>  	u64 usage;
>  	int size = 0;
> -	int i, j, ret;
> +	int i, j, ret = 0;
>  
>  	mutex_lock(&memcg->thresholds_lock);
>  	if (type == _MEM)

afacit the return value of cftype.unregister_event() is always ignored
anyway.  Perhaps it should be changed to void-returning, or fixed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
