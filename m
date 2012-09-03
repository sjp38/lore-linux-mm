Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 65A4F6B005D
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:27:36 -0400 (EDT)
Message-ID: <5044CBA9.3060409@parallels.com>
Date: Mon, 3 Sep 2012 19:24:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [12/14] Move kmem_cache allocations into common code.
References: <20120824160903.168122683@linux.com> <00000139596c6770-1fa03ab0-b08b-4403-98fc-bdffd53e67f3-000000@email.amazonses.com>
In-Reply-To: <00000139596c6770-1fa03ab0-b08b-4403-98fc-bdffd53e67f3-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> Shift the allocations to common code. That way the allocation
> and freeing of the kmem_cache structures is handled by common code.
> 
> V2->V3: Use GFP_KERNEL instead of GFP_NOWAIT (JoonSoo Kim).
> V1->V2: Use the return code from setup_cpucache() in slab instead of returning -ENOSPC
> 
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reviewed-by: Glauber Costa <glommer@parallels.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
