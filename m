Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E158A6B0093
	for <linux-mm@kvack.org>; Wed, 27 May 2009 01:25:27 -0400 (EDT)
Date: Tue, 26 May 2009 22:25:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3]  clean up functions related to pages_min V2
Message-Id: <20090526222510.ad054b8a.akpm@linux-foundation.org>
In-Reply-To: <20090521092304.0eb3c4cb.minchan.kim@barrios-desktop>
References: <20090521092304.0eb3c4cb.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 21 May 2009 09:23:04 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> Changelog since V1 
>  o Change function name from setup_per_zone_wmark_min to setup_per_zone_wmarks
>    - by Mel Gorman advise
>  o Modify description - by KOSAKI advise
> 
> Mel changed zone->pages_[high/low/min] with zone->watermark array.
> So, the functions related to pages_min also have to be changed.
> 
> * setup_per_zone_pages_min
> * init_per_zone_pages_min
> 
> This patch is just clean up. so it doesn't affect behavior.
> 

I cannot actually find a usable changelog amongst all that text.  Can
you try again please?

afacit the patch simply changes the names of a couple of functions. 
The changelog should concisely and completely describe what those naming
changes are, and the reason for making them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
