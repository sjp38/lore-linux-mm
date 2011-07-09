Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 49DF36B0083
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 16:47:36 -0400 (EDT)
Date: Sat, 9 Jul 2011 13:47:33 -0700
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/3] mm/readahead: Change the check for PageReadahead
 into an else-if
Message-ID: <20110709204733.GA17463@localhost>
References: <cover.1310239575.git.rprabhu@wnohang.net>
 <5a2186efeb299af150b1bef10f1c3a428722b3de.1310239575.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a2186efeb299af150b1bef10f1c3a428722b3de.1310239575.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Sun, Jul 10, 2011 at 03:41:18AM +0800, Raghavendra D Prabhu wrote:
> >From 51daa88ebd8e0d437289f589af29d4b39379ea76, page_sync_readahead coalesces
> async readahead into its readahead window, so another checking for that again is
> not required.
> 
> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
