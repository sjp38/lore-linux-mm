Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1A5E96B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 06:35:44 -0400 (EDT)
Message-ID: <501A5751.4000800@parallels.com>
Date: Thu, 2 Aug 2012 14:32:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [14/16] Move kmem_cache allocations into common code.
References: <20120801211130.025389154@linux.com> <20120801211203.783229289@linux.com>
In-Reply-To: <20120801211203.783229289@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 01:11 AM, Christoph Lameter wrote:
>  
>  	if (setup_cpu_cache(cachep, gfp)) {
>  		__kmem_cache_shutdown(cachep);
> -		return NULL;
> +		return -ENOSPC;
>  	}

Are we reading anything from disk here ?
Besides that, setup_cpu_cache() itself returns an error. It would be a
lot better to just use it, instead of replacing it with our own
interpretation of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
