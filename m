Message-ID: <484EFF86.1030709@ru.mvista.com>
Date: Wed, 11 Jun 2008 02:26:14 +0400
From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
MIME-Version: 1.0
Subject: Re: [RFC:PATCH 06/06] powerpc: Don't clear _PAGE_COHERENT when _PAGE_SAO
 is set
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com> <20080610220129.10257.69024.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20080610220129.10257.69024.sendpatchset@norville.austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: linuxppc-dev list <Linuxppc-dev@ozlabs.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello.

Dave Kleikamp wrote:
> powerpc: Don't clear _PAGE_COHERENT when _PAGE_SAO is set
>
> This is a placeholder.  Benh tells me that he will come up with a better fix.
>
> Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
> ---
>
>  arch/powerpc/platforms/pseries/lpar.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff -Nurp linux005/arch/powerpc/platforms/pseries/lpar.c linux006/arch/powerpc/platforms/pseries/lpar.c
> --- linux005/arch/powerpc/platforms/pseries/lpar.c	2008-06-05 10:07:34.000000000 -0500
> +++ linux006/arch/powerpc/platforms/pseries/lpar.c	2008-06-10 16:48:59.000000000 -0500
> @@ -305,7 +305,8 @@ static long pSeries_lpar_hpte_insert(uns
>  	flags = 0;
>  
>  	/* Make pHyp happy */
> -	if (rflags & (_PAGE_GUARDED|_PAGE_NO_CACHE))
> +	if ((rflags & _PAGE_GUARDED) ||
> +	    ((rflags & _PAGE_NO_CACHE) & !(rflags & _PAGE_WRITETHRU)))
>   
   I don't think you really meant bitwise AND here. I suppose the second 
expression just will never be true.

WBR, Sergei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
