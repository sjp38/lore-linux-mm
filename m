Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3A61B6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:41:29 -0400 (EDT)
Received: by qam2 with SMTP id 2so886717qam.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 05:41:28 -0700 (PDT)
Message-ID: <4F97F0F1.2000506@vflare.org>
Date: Wed, 25 Apr 2012 08:41:21 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] zsmalloc: clean up and fix arch dependency
References: <1335334994-22138-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1335334994-22138-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Minchan,

On 04/25/2012 02:23 AM, Minchan Kim wrote:

> This patchset has some clean up patches(1-5) and remove 
> set_bit, flush_tlb for portability in [6/6].
> 
> Minchan Kim (6):
>   zsmalloc: use PageFlag macro instead of [set|test]_bit
>   zsmalloc: remove unnecessary alignment
>   zsmalloc: rename zspage_order with zspage_pages
>   zsmalloc: add/fix function comment
>   zsmalloc: remove unnecessary type casting
>   zsmalloc: make zsmalloc portable
> 
>  drivers/staging/zsmalloc/Kconfig         |    4 --
>  drivers/staging/zsmalloc/zsmalloc-main.c |   73 +++++++++++++++++-------------
>  drivers/staging/zsmalloc/zsmalloc_int.h  |    3 +-
>  3 files changed, 43 insertions(+), 37 deletions(-)
> 


Thanks for the fixes.


Your description is missing testing notes (especially since patch [6/6]
is not a cosmetic change). So, can you please add these either here in
patch 0 or as part of patch 6/6 description?

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
