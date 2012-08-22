Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 8B5026B0071
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 04:45:32 -0400 (EDT)
Message-ID: <50349B70.1050208@parallels.com>
Date: Wed, 22 Aug 2012 12:42:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C12 [12/19] Move kmem_cache allocations into common code.
References: <20120820204021.494276880@linux.com> <0000013945cd2d87-d71d0827-51b3-4c98-890f-12beb8ecc72b-000000@email.amazonses.com> <50337722.3040908@parallels.com> <000001394afa9429-b8219750-1ae1-45f2-be1b-e02054615021-000000@email.amazonses.com>
In-Reply-To: <000001394afa9429-b8219750-1ae1-45f2-be1b-e02054615021-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/22/2012 12:58 AM, Christoph Lameter wrote:
> On Tue, 21 Aug 2012, Glauber Costa wrote:
> 
>> Doesn't boot (SLUB + debug options)
> 
> Subject: slub: use kmem_cache_zalloc to zero kmalloc cache
> 
> Memory for kmem_cache needs to be zeroed in slub after we moved the
> allocation into slab_commmon.
> 
Confirmed fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
