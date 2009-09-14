Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E0A526B004D
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 23:25:38 -0400 (EDT)
Subject: Re: [GIT BISECT] BUG kmalloc-8192: Object already free from
 kmem_cache_destroy
From: Eric Paris <eparis@redhat.com>
In-Reply-To: <4AADB5EE.9090902@redhat.com>
References: <1252866835.13780.37.camel@dhcp231-106.rdu.redhat.com>
	 <4AADB5EE.9090902@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 13 Sep 2009 23:25:39 -0400
Message-Id: <1252898739.5793.4.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Danny Feng <dfeng@redhat.com>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-09-14 at 11:18 +0800, Danny Feng wrote:
> diff --git a/mm/slub.c b/mm/slub.c
> index b627675..40e12d5 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3337,8 +3337,8 @@ struct kmem_cache *kmem_cache_create(const char
> *name, size_t size,
>                                 goto err;
>                         }
>                         return s;
> -               }
> -               kfree(s);
> +               } else
> +                       kfree(s);
>         }
>         up_write(&slub_lock);
>   

Doesn't the return inside the conditional take care of this?  I'll give
it a try in the morning, but I don't see how this can solve the
problem....

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
