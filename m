Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8C3E86B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 13:35:40 -0400 (EDT)
Received: by pbbjt11 with SMTP id jt11so2041157pbb.14
        for <linux-mm@kvack.org>; Wed, 08 Aug 2012 10:35:39 -0700 (PDT)
Message-ID: <5022A369.5020304@vflare.org>
Date: Wed, 08 Aug 2012 10:35:37 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] zram/zsmalloc promotion
References: <1344406340-14128-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1344406340-14128-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 08/07/2012 11:12 PM, Minchan Kim wrote:
> This patchset promotes zram/zsmalloc from staging.
> Both are very clean and zram is used by many embedded product
> for a long time.
> 
> [1-3] are patches not merged into linux-next yet but needed
> it as base for [4-5] which promotes zsmalloc.
> Greg, if you merged [1-3] already, skip them.
> 
> Seth Jennings (5):
>   1. zsmalloc: s/firstpage/page in new copy map funcs
>   2. zsmalloc: prevent mappping in interrupt context
>   3. zsmalloc: add page table mapping method
>   4. zsmalloc: collapse internal .h into .c
>   5. zsmalloc: promote to mm/
> 
> Minchan Kim (2):
>   6. zram: promote zram from staging
>   7. zram: select ZSMALLOC when ZRAM is configured
> 

All the changes look good to me. FWIW, for the entire series:
Acked-by: Nitin Gupta <ngupta@vflare.org>

Thanks for all the work.
Nitin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
