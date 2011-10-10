Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id F14FA6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 08:27:31 -0400 (EDT)
Subject: Re: [PATCH 1/9] mm: add a "struct subpage" type containing a page,
 offset and length
From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 10 Oct 2011 13:27:00 +0100
In-Reply-To: <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
	 <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1318249620.21903.416.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On Mon, 2011-10-10 at 12:11 +0100, Ian Campbell wrote:

> Cc: linux-mm@kvack.org
> ---
>  include/linux/mm_types.h |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)

get_maintainers.pl didn't pick up on this CC. Since mm_types.h was split
out of mm.h does the following make sense? Not sure if mm_*.h (or just
mm_inline.hm?) also makes sense.

8<--------------------------

Subject: MAINTAINER: mm subsystem includes mm_types.h

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index ae8820e..f10a7ea 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4212,6 +4212,7 @@ L:	linux-mm@kvack.org
 W:	http://www.linux-mm.org
 S:	Maintained
 F:	include/linux/mm.h
+F:	include/linux/mm_types.h
 F:	mm/
 
 MEMORY RESOURCE CONTROLLER


> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 774b895..dc1d103 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -135,6 +135,17 @@ struct page {
>  #endif
>  ;
>  
> +struct subpage {
> +	struct page *page;
> +#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
> +	__u32 page_offset;
> +	__u32 size;
> +#else
> +	__u16 page_offset;
> +	__u16 size;
> +#endif
> +};
> +
>  typedef unsigned long __nocast vm_flags_t;
>  
>  /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
