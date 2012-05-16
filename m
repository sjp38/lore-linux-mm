Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 1BBCA6B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 04:36:12 -0400 (EDT)
Message-ID: <4FB36685.4030104@parallels.com>
Date: Wed, 16 May 2012 12:34:13 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] SL[AUO]B common code 6/9] slabs: Use a common mutex definition
References: <20120514201544.334122849@linux.com> <20120514201612.262732939@linux.com>
In-Reply-To: <20120514201612.262732939@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On 05/15/2012 12:15 AM, Christoph Lameter wrote:
> Use the mutex definition from SLAB and make it the common way to take a sleeping lock.
>
> This has the effect of using a mutex instead of a rw semaphore for SLUB.

This is very good, IMHO.

> SLOB gains the use of a mutex for kmem_cache_create serialization.
> Not needed now but SLOB may acquire some more features later (like slabinfo
> / sysfs support) through the expansion of the common code that will
> need this.

Now, won't this hurt performance of the slob allocator, that seems to 
gain its edge from its simplicity ?

But I'll let whoever cares comment on that. From where I stand:

> Signed-off-by: Christoph Lameter<cl@linux.com>
>
Reviewed-by: Glauber Costa <glommer@parallels.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
