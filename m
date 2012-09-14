Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id BA3366B0201
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 07:24:49 -0400 (EDT)
Message-ID: <50531339.1000805@parallels.com>
Date: Fri, 14 Sep 2012 15:21:29 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: clean up networking headers file inclusion
References: <20120914112118.GG28039@dhcp22.suse.cz>
In-Reply-To: <20120914112118.GG28039@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sachin
 Kamat <sachin.kamat@linaro.org>

On 09/14/2012 03:21 PM, Michal Hocko wrote:
> Hi,
> so I did some more changes to ifdefery of sock kmem part. The patch is
> below. 
> Glauber please have a look at it. I do not think any of the
> functionality wrapped inside CONFIG_MEMCG_KMEM without CONFIG_INET is
> reusable for generic CONFIG_MEMCG_KMEM, right?
Almost right.



>  }
>  
>  /* Writing them here to avoid exposing memcg's inner layout */
> -#ifdef CONFIG_MEMCG_KMEM
> -#include <net/sock.h>
> -#include <net/ip.h>
> +#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  
>  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);

This one is. ^^^^

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
