Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 06CAC6B005D
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 14:19:13 -0400 (EDT)
Date: Fri, 25 Sep 2009 11:19:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory : adjust the ugly comment
Message-Id: <20090925111913.c7c32a06.akpm@linux-foundation.org>
In-Reply-To: <1253870451-4887-1-git-send-email-shijie8@gmail.com>
References: <1253870451-4887-1-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Sep 2009 17:20:51 +0800 Huang Shijie <shijie8@gmail.com> wrote:

> The origin comment is too ugly, so modify it more beautiful.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/memory.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 7e91b5f..6a38caa 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2405,7 +2405,10 @@ restart:
>  }
>  
>  /**
> - * unmap_mapping_range - unmap the portion of all mmaps in the specified address_space corresponding to the specified page range in the underlying file.
> + * unmap_mapping_range - unmap the portion of all mmaps in the specified
> + *	 		address_space corresponding to the specified page range
> + * 			in the underlying file.
> + *

The comment must all be in a single line so that the kerneldoc tools
process it correctly.  It's a kerneldoc restriction which all are
welcome to fix ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
