Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id F36786B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 12:17:41 -0400 (EDT)
Received: by yhr47 with SMTP id 47so9671852yhr.14
        for <linux-mm@kvack.org>; Wed, 23 May 2012 09:17:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120518161933.271404153@linux.com>
References: <20120518161906.207356777@linux.com>
	<20120518161933.271404153@linux.com>
Date: Thu, 24 May 2012 01:17:41 +0900
Message-ID: <CAAmzW4Mxc3-PiPozUWdC_0C1Y+nzhP4g9T3qF=X9SqCD4Ym8sA@mail.gmail.com>
Subject: Re: [RFC] Common code 11/12] Move freeing of kmem_cache structure to
 common code
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

2012/5/19 Christoph Lameter <cl@linux.com>:
> The freeing action is basically the same in all slab allocators.
> Move to the common kmem_cache_destroy() function.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
