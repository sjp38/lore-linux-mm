Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4F86B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 05:39:38 -0400 (EDT)
Received: by pzk33 with SMTP id 33so6347072pzk.36
        for <linux-mm@kvack.org>; Fri, 29 Jul 2011 02:39:36 -0700 (PDT)
Date: Fri, 29 Jul 2011 18:39:29 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 3/3]vmscan: cleanup kswapd_try_to_sleep
Message-ID: <20110729093929.GF1843@barrios-desktop>
References: <1311840789.15392.409.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311840789.15392.409.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, mgorman@suse.de

On Thu, Jul 28, 2011 at 04:13:09PM +0800, Shaohua Li wrote:
> cleanup kswapd_try_to_sleep() a little bit. Sometimes kswapd doesn't
> really sleep. In such case, don't call prepare_to_wait/finish_wait.
> It just wastes CPU.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

And it increases just code size a little bit even without big benefit of CPU.
You said it's cleanup but I doubt how it helps readability.
So code itself dosn't have a problem but I don't like it.

barrios@barrios-desktop:~/linux-mmotm$ size mm/vmscan.o.old
   text	   data	    bss	    dec	    hex	filename
  10271	     30	      8	  10309	   2845	mm/vmscan.o.old
barrios@barrios-desktop:~/linux-mmotm$ size mm/vmscan.o
   text	   data	    bss	    dec	    hex	filename
  10287	     30	      8	  10325	   2855	mm/vmscan.o

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
