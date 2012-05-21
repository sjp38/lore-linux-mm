Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 7B0986B0082
	for <linux-mm@kvack.org>; Mon, 21 May 2012 05:37:29 -0400 (EDT)
Message-ID: <4FBA0C5E.4010102@parallels.com>
Date: Mon, 21 May 2012 13:35:26 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 10/12] sl[aub]: Use the name "kmem_cache" for
 the slab cache with the kmem_cache structure.
References: <20120518161906.207356777@linux.com> <20120518161932.708441342@linux.com>
In-Reply-To: <20120518161932.708441342@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/18/2012 08:19 PM, Christoph Lameter wrote:
> Make all allocators use the "kmem_cache" slabname for the "kmem_cache" structure.
>
> Signed-off-by: Christoph Lameter<cl@linux.com>
This is a good change.

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
