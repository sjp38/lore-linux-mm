Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B92316B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 05:32:49 -0400 (EDT)
Message-ID: <501A4892.5090809@parallels.com>
Date: Thu, 2 Aug 2012 13:29:54 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [09/16] Do slab aliasing call from common code
References: <20120801211130.025389154@linux.com> <20120801211200.655711830@linux.com>
In-Reply-To: <20120801211200.655711830@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> +	s = __kmem_cache_alias(name, size, align, flags, ctor);
> +	if (s)
> +		goto oops;
> +

"goto oops" is a really bad way of naming a branch conditional to a
perfectly valid state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
