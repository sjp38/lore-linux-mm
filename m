Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2B7A46B004A
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 14:10:00 -0400 (EDT)
Date: Tue, 12 Jul 2011 11:09:55 -0700
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Re. Revised [PATCH 3/3] mm/readahead: Remove the check for
 ra->ra_pages
Message-ID: <20110712180955.GA12562@localhost>
References: <cover.1310239575.git.rprabhu@wnohang.net>
 <323ddfc402a7f7b94f0cb02bba15acb2acca786f.1310239575.git.rprabhu@wnohang.net>
 <20110709205308.GC17463@localhost>
 <20110710125909.GA4460@Xye>
 <20110710155906.GB7432@localhost>
 <20110711230209.GA39196@Xye>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110711230209.GA39196@Xye>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <rprabhu@wnohang.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

>  The check for ra->ra_pages is not required since fs like tmpfs which have
>  ra_pages set to 0 don't use filemap_fault as part of their VMA ops (it uses
>  shmem_fault). Also, page_cache_sync_readahead does its own check for ra_pages.
> 
>  Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
