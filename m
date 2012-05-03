Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 801BE6B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 09:18:18 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1428944qcs.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 06:18:17 -0700 (PDT)
Message-ID: <4FA2859A.5050803@vflare.org>
Date: Thu, 03 May 2012 09:18:18 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] zsmalloc: rename zspage_order with zspage_pages
References: <1336027242-372-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1336027242-372-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 5/3/12 2:40 AM, Minchan Kim wrote:
> zspage_order defines how many pages are needed to make a zspage.
> So_order_  is rather awkward naming. It already deceive Jonathan
> -http://lwn.net/Articles/477067/
> " For each size, the code calculates an optimum number of pages (up to 16)"
>
> Let's change from_order_  to_pages_  and some function names.
>
> Signed-off-by: Minchan Kim<minchan@kernel.org>
> ---
>   drivers/staging/zsmalloc/zsmalloc-main.c |   14 +++++++-------
>   drivers/staging/zsmalloc/zsmalloc_int.h  |    2 +-
>   2 files changed, 8 insertions(+), 8 deletions(-)

Acked-by: Nitin Gupta <ngupta@vflare.org>

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
