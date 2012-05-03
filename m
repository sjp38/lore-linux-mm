Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id B4D766B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 09:32:56 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1446329qcs.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 06:32:55 -0700 (PDT)
Message-ID: <4FA28907.9020300@vflare.org>
Date: Thu, 03 May 2012 09:32:55 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1336027242-372-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On 5/3/12 2:40 AM, Minchan Kim wrote:
> We should use zs_handle instead of void * to avoid any
> confusion. Without this, users may just treat zs_malloc return value as
> a pointer and try to deference it.
>
> Cc: Dan Magenheimer<dan.magenheimer@oracle.com>
> Cc: Konrad Rzeszutek Wilk<konrad.wilk@oracle.com>
> Signed-off-by: Minchan Kim<minchan@kernel.org>
> ---
>   drivers/staging/zcache/zcache-main.c     |    8 ++++----
>   drivers/staging/zram/zram_drv.c          |    8 ++++----
>   drivers/staging/zram/zram_drv.h          |    2 +-
>   drivers/staging/zsmalloc/zsmalloc-main.c |   28 ++++++++++++++--------------
>   drivers/staging/zsmalloc/zsmalloc.h      |   15 +++++++++++----
>   5 files changed, 34 insertions(+), 27 deletions(-)

This was a long pending change. Thanks!

Acked-by: Nitin Gupta <ngupta@vflare.org>


  - Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
