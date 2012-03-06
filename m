Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id CC6B16B004D
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 22:16:28 -0500 (EST)
Received: by dakp5 with SMTP id p5so6324002dak.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 19:16:28 -0800 (PST)
Date: Tue, 6 Mar 2012 12:16:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/1] page_alloc.c: Slightly improve the logic in
 __alloc_pages_high_priority
Message-ID: <20120306031619.GB14274@barrios>
References: <1330957105-3595-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1330957105-3595-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kautuk,

On Mon, Mar 05, 2012 at 09:18:25AM -0500, Kautuk Consul wrote:
> The loop in __alloc_pages_high_priority() seems to be checking for
> (!page) and (gfp_mask & __GFP_NOFAIL) multiple times.
> 
> In fact, we don't really need to check (gfp_mask & __GFP_NOFAIL)
> for every iteration of the loop as the gfp_mask remains constant.
> 
> Slightly improve the logic in __alloc_pages_high_priority() to
> eliminate these multiple condition checks.

Thansk for your effort.

Surely we don't need mutliple condition check but it's not fast-path
and not a problem about readability. So I don't want to increase text
size unnecessary if it doesn't have a benefit.

barrios@barrios:~/linux-2.6$ size mm/page_alloc.o
   text	   data	    bss	    dec	    hex	filename
  32772	   1307	    576	  34655	   875f	mm/page_alloc.o
barrios@barrios:~/linux-2.6$ size mm/page_alloc.o.your_patch 
   text	   data	    bss	    dec	    hex	filename
  32804	   1307	    576	  34687	   877f	mm/page_alloc.o.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
