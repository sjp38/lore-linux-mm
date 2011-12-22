Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id BBE846B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 22:27:13 -0500 (EST)
Message-ID: <4EF2A410.6020400@cn.fujitsu.com>
Date: Thu, 22 Dec 2011 11:29:20 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] radix_tree: delete orphaned macro radix_tree_indirect_to_ptr
References: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils> <20111221050740.GD23662@dastard> <alpine.LSU.2.00.1112202218490.4026@eggly.anvils> <20111221221527.GE23662@dastard> <alpine.LSU.2.00.1112211555430.25868@eggly.anvils> <4EF2A0ED.8080308@gmail.com>
In-Reply-To: <4EF2A0ED.8080308@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "nai.xia" <nai.xia@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

nai.xia wrote:
> Seems nobody has been using the macro radix_tree_indirect_to_ptr()
> since long time ago. Delete it.
> 

Someone else has already posted the same patch.

https://lkml.org/lkml/2011/12/16/118

> Signed-off-by: Nai Xia <nai.xia@gmail.com>
> ---
>  include/linux/radix-tree.h |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -49,9 +49,6 @@
>  #define RADIX_TREE_EXCEPTIONAL_ENTRY    2
>  #define RADIX_TREE_EXCEPTIONAL_SHIFT    2
> 
> -#define radix_tree_indirect_to_ptr(ptr) \
> -    radix_tree_indirect_to_ptr((void __force *)(ptr))
> -
>  static inline int radix_tree_is_indirect_ptr(void *ptr)
>  {
>      return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
