Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id F33406B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 13:07:45 -0500 (EST)
Received: by vcbfk14 with SMTP id fk14so4770249vcb.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 10:07:44 -0800 (PST)
Message-ID: <4F5500EF.9080609@vflare.org>
Date: Mon, 05 Mar 2012 13:07:43 -0500
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] staging: zsmalloc: remove SPARSEMEM dependency
References: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2012 12:33 PM, Seth Jennings wrote:

> This patch series removes the dependency zsmalloc has on SPARSEMEM;
> more specifically the assumption that MAX_PHYSMEM_BITS is defined.
> 
> Based on greg/staging-next.
> 
> Seth Jennings (5):
>   staging: zsmalloc: move object/handle masking defines
>   staging: zsmalloc: add ZS_MAX_PAGES_PER_ZSPAGE
>   staging: zsmalloc: calculate MAX_PHYSMEM_BITS if not defined
>   staging: zsmalloc: change ZS_MIN_ALLOC_SIZE
>   staging: zsmalloc: remove SPARSEMEM dep from Kconfig
> 
>  drivers/staging/zsmalloc/Kconfig         |    2 +-
>  drivers/staging/zsmalloc/zsmalloc-main.c |   14 +---------
>  drivers/staging/zsmalloc/zsmalloc_int.h  |   43 +++++++++++++++++++++++++-----
>  3 files changed, 38 insertions(+), 21 deletions(-)
> 


For the entire series:

Acked-by: Nitin Gupta <ngupta@vflare.org>


Thanks for the fixes.
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
