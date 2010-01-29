Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC936B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 15:57:20 -0500 (EST)
Date: Fri, 29 Jan 2010 12:56:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFP 1/3] srcu
Message-Id: <20100129125650.78ca4876.akpm@linux-foundation.org>
In-Reply-To: <20100128195633.998332000@alcatraz.americas.sgi.com>
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
	<20100128195633.998332000@alcatraz.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>


> Subject: [RFP 1/3] srcu

Well that was terse.

On Thu, 28 Jan 2010 13:56:28 -0600
Robin Holt <holt@sgi.com> wrote:

> From: Andrea Arcangeli <andrea@qumranet.com>
> 
> This converts rcu into a per-mm srcu to allow all mmu notifier methods to
> schedule.

Changelog doesn't make much sense.

> --- mmu_notifiers_sleepable_v1.orig/include/linux/srcu.h	2010-01-28 10:36:39.000000000 -0600
> +++ mmu_notifiers_sleepable_v1/include/linux/srcu.h	2010-01-28 10:39:10.000000000 -0600
> @@ -27,6 +27,8 @@
>  #ifndef _LINUX_SRCU_H
>  #define _LINUX_SRCU_H
>  
> +#include <linux/mutex.h>
> +
>  struct srcu_struct_array {
>  	int c[2];
>  };

An unchangelogged, unrelated bugfix.  I guess it's OK slipping this
into this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
