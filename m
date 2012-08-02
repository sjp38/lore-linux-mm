Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id ED6296B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 04:22:37 -0400 (EDT)
Message-ID: <501A381F.9040703@parallels.com>
Date: Thu, 2 Aug 2012 12:19:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [15/16] Shrink __kmem_cache_create() parameter lists
References: <20120801211130.025389154@linux.com> <20120801211204.342096542@linux.com>
In-Reply-To: <20120801211204.342096542@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> +		if (!s->name) {
> +			kmem_cache_free(kmem_cache, s);
> +			s = NULL;
> +			goto oops;
> +		}
> +
This is now only defined when CONFIG_DEBUG_VM. Now would be a good time
to fix that properly by just removing the ifdef around the label.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
