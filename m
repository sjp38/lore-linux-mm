Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id BDD346B002C
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 01:58:08 -0500 (EST)
Received: by pbbro12 with SMTP id ro12so4303229pbb.14
        for <linux-mm@kvack.org>; Sat, 03 Mar 2012 22:58:07 -0800 (PST)
Date: Sun, 4 Mar 2012 15:57:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <20120304065759.GA7824@barrios>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

Hi Satoru,

On Fri, Mar 02, 2012 at 12:36:40PM -0500, Satoru Moriya wrote:
> Sometimes we'd like to avoid swapping out anonymous memory
> in particular, avoid swapping out pages of important process or
> process groups while there is a reasonable amount of pagecache
> on RAM so that we can satisfy our customers' requirements.
> 
> OTOH, we can control how aggressive the kernel will swap memory pages
> with /proc/sys/vm/swappiness for global and
> /sys/fs/cgroup/memory/memory.swappiness for each memcg.
> 
> But with current reclaim implementation, the kernel may swap out
> even if we set swappiness==0 and there is pagecache on RAM.
> 
> This patch changes the behavior with swappiness==0. If we set
> swappiness==0, the kernel does not swap out completely
> (for global reclaim until the amount of free pages and filebacked
> pages in a zone has been reduced to something very very small
> (nr_free + nr_filebacked < high watermark)).
> 
> Any comments are welcome.
> 
> Regards,
> Satoru Moriya
> 
> Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>

Acked-by: Minchan Kim <minchan@kernel.org>

I agree this feature but current code is rather ugly on readbility.
It's not your fault because it is caused by adding 'noswap' to avoid
scanning of anon pages when priority is 0. You just used that code. :)

Hillf's version looks to be much clean refactoring so after we merge
your patch, we can tidy it up with Hillf's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
