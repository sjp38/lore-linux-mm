Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 724C46B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 12:42:48 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so17058058obb.14
        for <linux-mm@kvack.org>; Wed, 23 May 2012 09:42:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120518161933.891500516@linux.com>
References: <20120518161906.207356777@linux.com>
	<20120518161933.891500516@linux.com>
Date: Thu, 24 May 2012 01:42:47 +0900
Message-ID: <CAAmzW4OVQMMuM_+hNxCJY_AKbQQaPhXcxSnAhBKp6txk14mZvw@mail.gmail.com>
Subject: Re: [RFC] Common code 12/12] [slauob]: Get rid of __kmem_cache_destroy
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

2012/5/19 Christoph Lameter <cl@linux.com>:
> Actions done there can be done in __kmem_cache_shutdown.
>
> This affects RCU handling somewhat. On rcu free all slab allocators
> do not refer to other management structures than the kmem_cache structure.
> Therefore these other structures can be freed before the rcu deferred
> free to the page allocator occurs.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
