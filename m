Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id B894F6B0100
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:52:49 -0400 (EDT)
Date: Wed, 23 May 2012 16:46:12 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 1/2 v2] zsmalloc: zsmalloc: use unsigned long instead of
 void *
Message-ID: <20120523204611.GA1991@phenom.dumpdata.com>
References: <1337737402-16543-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337737402-16543-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, May 23, 2012 at 10:43:21AM +0900, Minchan Kim wrote:
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

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
