Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D2F656B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 19:11:45 -0400 (EDT)
Subject: Re: [GIT BISECT] BUG kmalloc-8192: Object already free from
 kmem_cache_destroy
From: Eric Paris <eparis@redhat.com>
In-Reply-To: <1252866835.13780.37.camel@dhcp231-106.rdu.redhat.com>
References: <1252866835.13780.37.camel@dhcp231-106.rdu.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 13 Sep 2009 19:11:33 -0400
Message-Id: <1252883493.16335.8.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: dfeng@redhat.com, penberg@cs.helsinki.fi, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2009-09-13 at 14:33 -0400, Eric Paris wrote:
> 2a38a002fbee06556489091c30b04746222167e4 is first bad commit
> commit 2a38a002fbee06556489091c30b04746222167e4
> Author: Xiaotian Feng <dfeng@redhat.com>
> Date:   Wed Jul 22 17:03:57 2009 +0800
> 
>     slub: sysfs_slab_remove should free kmem_cache when debug is enabled
>     
>     kmem_cache_destroy use sysfs_slab_remove to release the kmem_cache,
>     but when CONFIG_SLUB_DEBUG is enabled, sysfs_slab_remove just release
>     related kobject, the whole kmem_cache is missed to release and cause
>     a memory leak.
>     
>     Acked-by: Christoph Lameer <cl@linux-foundation.org>
>     Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
>     Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> CONFIG_SLUB_DEBUG=y
> CONFIG_SLUB=y
> CONFIG_SLUB_DEBUG_ON=y
> # CONFIG_SLUB_STATS is not set

I also had problems destroying a kmem_cache in a security_initcall()
function which had a different backtrace (it's what made me create the
module and bisect.)   So be sure to let me know what you find so I can
be sure that we fix that place as well   (I believe that was a kref
problem rather than a double free)

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
