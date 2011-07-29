Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 62A066B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 06:47:53 -0400 (EDT)
Date: Fri, 29 Jul 2011 18:46:50 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [patch 3/3]vmscan: cleanup kswapd_try_to_sleep
Message-ID: <20110729104650.GB7120@sli10-conroe.sh.intel.com>
References: <1311840789.15392.409.camel@sli10-conroe>
 <20110729093929.GF1843@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110729093929.GF1843@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "mgorman@suse.de" <mgorman@suse.de>

On Fri, Jul 29, 2011 at 05:39:29PM +0800, Minchan Kim wrote:
> On Thu, Jul 28, 2011 at 04:13:09PM +0800, Shaohua Li wrote:
> > cleanup kswapd_try_to_sleep() a little bit. Sometimes kswapd doesn't
> > really sleep. In such case, don't call prepare_to_wait/finish_wait.
> > It just wastes CPU.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> And it increases just code size a little bit even without big benefit of CPU.
> You said it's cleanup but I doubt how it helps readability.
> So code itself dosn't have a problem but I don't like it.
> 
> barrios@barrios-desktop:~/linux-mmotm$ size mm/vmscan.o.old
>    text	   data	    bss	    dec	    hex	filename
>   10271	     30	      8	  10309	   2845	mm/vmscan.o.old
> barrios@barrios-desktop:~/linux-mmotm$ size mm/vmscan.o
>    text	   data	    bss	    dec	    hex	filename
>   10287	     30	      8	  10325	   2855	mm/vmscan.o
I'm curious why the size is increased, the patch doesn't add new code.
Maybe gcc has different optimization.
This hasn't big benefit for sure, but both prepare_to_wait/finish_wait
use spinlock, it's expensive operation even without contention. From
this point view, it has benefit because we don't blindly call them.
But anyway, it's a trival patch. I'm fine if it's rejected.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
