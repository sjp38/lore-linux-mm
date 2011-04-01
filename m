Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A4F978D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 22:29:22 -0400 (EDT)
Received: by iyf13 with SMTP id 13so4324549iyf.14
        for <linux-mm@kvack.org>; Thu, 31 Mar 2011 19:29:18 -0700 (PDT)
Subject: Re: [PATCH] MAINTAINERS: add mm/page_cgroup.c into memcg subsystem
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <1301624733-6141-1-git-send-email-namhyung@gmail.com>
References: <1301624733-6141-1-git-send-email-namhyung@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 01 Apr 2011 11:29:07 +0900
Message-ID: <1301624947.1496.11.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Oops, add CC's of the maintainers.


2011-04-01 (e,?), 11:25 +0900, Namhyung Kim:
> AFAICS mm/page_cgroup.c is for memcg subsystem, but it was directed
> only to generic cgroup maintainers. Fix it.
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> ---
>  MAINTAINERS |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 6b4b9cdec370..a19a1b9677a3 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4121,6 +4121,7 @@ M:	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>  L:	linux-mm@kvack.org
>  S:	Maintained
>  F:	mm/memcontrol.c
> +F:	mm/page_cgroup.c
>  
>  MEMORY TECHNOLOGY DEVICES (MTD)
>  M:	David Woodhouse <dwmw2@infradead.org>


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
