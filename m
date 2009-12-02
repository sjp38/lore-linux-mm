Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF39D600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:08:36 -0500 (EST)
Date: Wed, 2 Dec 2009 14:08:34 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 01/24] page-types: add standard GPL license head
Message-ID: <20091202130834.GC18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043043.715851393@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043043.715851393@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 11:12:32AM +0800, Wu Fengguang wrote:

> CC: Andi Kleen <andi@firstfloor.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  Documentation/vm/page-types.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> --- linux-mm.orig/Documentation/vm/page-types.c	2009-11-07 19:28:51.000000000 +0800
> +++ linux-mm/Documentation/vm/page-types.c	2009-11-08 22:04:04.000000000 +0800
> @@ -1,11 +1,22 @@
>  /*
>   * page-types: Tool for querying page flags
>   *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the Free
> + * Software Foundation; version 2.

I guess it's not fully hwpoison department, but I'll just include it
because it's so simple.
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
