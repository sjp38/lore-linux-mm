Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 219586B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 06:13:56 -0400 (EDT)
Message-ID: <501A5235.4090803@parallels.com>
Date: Thu, 2 Aug 2012 14:11:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [11/16] slub: Use a statically allocated kmem_cache boot
 structure for bootstrap
References: <20120801211130.025389154@linux.com> <20120801211201.868580928@linux.com>
In-Reply-To: <20120801211201.868580928@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> Simplify bootstrap by statically allocated two kmem_cache structures. These are
> freed after bootup is complete. Allows us to no longer worry about calculations
> of sizes of kmem_cache structures during bootstrap.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

The changes seems reasonable.

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
