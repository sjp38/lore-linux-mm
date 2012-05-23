Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id D3C9C6B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 15:17:14 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 23 May 2012 13:17:13 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3788819D806C
	for <linux-mm@kvack.org>; Wed, 23 May 2012 13:16:32 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4NJFstK223614
	for <linux-mm@kvack.org>; Wed, 23 May 2012 13:16:10 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4NJFbbW011116
	for <linux-mm@kvack.org>; Wed, 23 May 2012 13:15:38 -0600
Message-ID: <4FBD373A.5030109@linux.vnet.ibm.com>
Date: Wed, 23 May 2012 14:15:06 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 v2] zsmalloc: zsmalloc: use unsigned long instead
 of void *
References: <1337737402-16543-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1337737402-16543-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On 05/22/2012 08:43 PM, Minchan Kim wrote:

> We should use unsigned long as handle instead of void * to avoid any
> confusion. Without this, users may just treat zs_malloc return value as
> a pointer and try to deference it.
> 
> This patch passed compile test(zram, zcache and ramster) and zram is
> tested on qemu.
> 
> changelog
>   * from v1
>  	- change zcache's zv_create return value
>         - baesd on next-20120522
> 
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>


Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
