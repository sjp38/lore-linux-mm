Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k03LYQnC005378
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 16:34:26 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k03LX9ZM094772
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 14:33:09 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k03LYQ27032634
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 14:34:26 -0700
Message-ID: <43BAEDDD.8080805@austin.ibm.com>
Date: Tue, 03 Jan 2006 15:34:21 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: [Patch] New zone ZONE_EASY_RECLAIM take 4. (disable gfp_easy_reclaim
 bit)[5/8]
References: <20051220173013.1B10.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051220173013.1B10.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> ===================================================================
> --- zone_reclaim.orig/fs/pipe.c	2005-12-16 18:36:20.000000000 +0900
> +++ zone_reclaim/fs/pipe.c	2005-12-16 19:15:35.000000000 +0900
> @@ -284,7 +284,7 @@ pipe_writev(struct file *filp, const str
>  			int error;
>  
>  			if (!page) {
> -				page = alloc_page(GFP_HIGHUSER);
> +				page = alloc_page(GFP_HIGHUSER & ~__GFP_EASY_RECLAIM);
>  				if (unlikely(!page)) {
>  					ret = ret ? : -ENOMEM;
>  					break;

That is a bit hard to understand.  How about a new GFP_HIGHUSER_HARD or 
somesuch define back in patch 1, then use it here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
