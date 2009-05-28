Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B9DC86B005D
	for <linux-mm@kvack.org>; Thu, 28 May 2009 04:31:46 -0400 (EDT)
Date: Thu, 28 May 2009 01:31:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] remove CONFIG_UNEVICTABLE_LRU definition from
 defconfig
Message-Id: <20090528013146.6dd99aa0.akpm@linux-foundation.org>
In-Reply-To: <20090514111519.9B5D.A69D9226@jp.fujitsu.com>
References: <20090514110357.9B54.A69D9226@jp.fujitsu.com>
	<20090514111519.9B5D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thu, 14 May 2009 11:15:49 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Subject: [PATCH] remove CONFIG_UNEVICTABLE_LRU definition from defconfig
> 
> Now, There isn't CONFIG_UNEVICTABLE_LRU. these line are unnecessary.
> 
> ...
>
>  196 files changed, 196 deletions(-)

Gad.

I don't know if this is worth bothering about really.  The dead Kconfig
option will slowly die a natural death as people refresh the defconfig
files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
