Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id BFD3D6B0044
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 15:45:06 -0400 (EDT)
Date: Fri, 14 Sep 2012 12:45:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] memcg: clean up networking headers file inclusion
Message-Id: <20120914124505.6d7756d1.akpm@linux-foundation.org>
In-Reply-To: <20120914120849.GL28039@dhcp22.suse.cz>
References: <20120914112118.GG28039@dhcp22.suse.cz>
	<50531339.1000805@parallels.com>
	<20120914113400.GI28039@dhcp22.suse.cz>
	<50531696.1080708@parallels.com>
	<20120914120849.GL28039@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

On Fri, 14 Sep 2012 14:08:49 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -50,8 +50,12 @@
>  #include <linux/cpu.h>
>  #include <linux/oom.h>
>  #include "internal.h"
> +
> +#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
>  #include <net/sock.h>
> +#include <net/ip.h>
>  #include <net/tcp_memcontrol.h>
> +#endif

That wasn't a cleanup!

Why not just unconditionally include them?  That will impact compile
time a teeny bit, but the code is cleaner.

And it's safer, too - conditionally including header files make it more
likely that people will accidentally break the build by not testing all
relevant CONFIG_foo combinations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
