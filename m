Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 16D206B004D
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 21:49:35 -0400 (EDT)
Message-ID: <4A3C4083.2080205@redhat.com>
Date: Fri, 19 Jun 2009 21:50:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/4] tmem: infrastructure for tmem layer
References: <b6ebd2d7-7bac-4aa0-8910-991304979fb9@default>
In-Reply-To: <b6ebd2d7-7bac-4aa0-8910-991304979fb9@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:

> --- linux-2.6.30/mm/Makefile	2009-06-09 21:05:27.000000000 -0600
> +++ linux-2.6.30-tmem/mm/Makefile	2009-06-19 09:33:59.000000000 -0600
> @@ -16,6 +16,8 @@
>  obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
>  obj-$(CONFIG_BOUNCE)	+= bounce.o
>  obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
> +obj-$(CONFIG_PRESWAP)	+= preswap.o
> +obj-$(CONFIG_PRECACHE)	+= precache.o

This patch does not actually add preswap.c or precache.c,
so it would lead to an uncompilable changeset.

This in turn breaks git bisect.

Please make sure that every changeset that is applied results
in a compilable and bootable kernel.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
