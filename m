Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 365FD6003C2
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 03:11:15 -0500 (EST)
Date: Wed, 2 Dec 2009 09:11:02 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 16/24] HWPOISON: limit hwpoison injector to known page
 types
Message-ID: <20091202081102.GA16218@elte.hu>
References: <20091202031231.735876003@intel.com>
 <20091202043045.711553780@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043045.711553780@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Haicheng Li <haicheng.li@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> --- linux-mm.orig/mm/hwpoison-inject.c	2009-11-30 20:44:41.000000000 +0800
> +++ linux-mm/mm/hwpoison-inject.c	2009-11-30 20:58:20.000000000 +0800
> @@ -3,16 +3,41 @@
>  #include <linux/debugfs.h>
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
> +#include <linux/swap.h>
>  #include "internal.h"
>  
>  static struct dentry *hwpoison_dir;
>  
>  static int hwpoison_inject(void *data, u64 val)
>  {

i'd like to raise a continuing conceptual objection against the ad-hoc 
and specialistic nature of the event injection in the 
mm/memory-failure*.c code. It should probably be using a standardized 
interface by integrating with perf events - as i outlined it before.

Where needed perf events should be extended - we can help with that. 
There's no point in having scattered pieces of incompatible (and 
user-ABI affecting) infrastructure all around the kernel.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
