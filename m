Date: Tue, 22 May 2007 11:38:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch] memory unplug v3 [1/4] page isolation
In-Reply-To: <20070522160151.3ae5e5d7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705221137160.29456@schroedinger.engr.sgi.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
 <20070522160151.3ae5e5d7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:

> Index: devel-2.6.22-rc1-mm1/mm/page_isolation.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ devel-2.6.22-rc1-mm1/mm/page_isolation.c	2007-05-22 15:12:28.000000000 +0900
> @@ -0,0 +1,67 @@
> +/*
> + * linux/mm/page_isolation.c
> + */
> +
> +#include <stddef.h>
> +#include <linux/mm.h>
> +#include <linux/page-isolation.h>
> +
> +#define ROUND_DOWN(x,y)	((x) & ~((y) - 1))
> +#define ROUND_UP(x,y)	(((x) + (y) -1) & ~((y) - 1))

Use the common definitions like ALIGN in kernel.h and the rounding 
functions in log2.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
