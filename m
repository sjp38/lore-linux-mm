Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 140136B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 10:33:27 -0400 (EDT)
Message-ID: <5044BEF8.8090304@parallels.com>
Date: Mon, 3 Sep 2012 18:30:16 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [03/14] Improve error handling in kmem_cache_create
References: <20120824160903.168122683@linux.com> <00000139596c66f1-eb21326d-76c1-4ccb-af7f-d755d596d37e-000000@email.amazonses.com>
In-Reply-To: <00000139596c66f1-eb21326d-76c1-4ccb-af7f-d755d596d37e-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> Instead of using s == NULL use an errorcode. This allows much more
> detailed diagnostics as to what went wrong. As we add more functionality
> from the slab allocators to the common kmem_cache_create() function we will
> also add more error conditions.
> 
> Print the error code during the panic as well as in a warning if the module
> can handle failure. The API for kmem_cache_create() currently does not allow
> the returning of an error code. Return NULL but log the cause of the problem
> in the syslog.
> 
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
