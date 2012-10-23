Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 4441A6B005A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 10:15:34 -0400 (EDT)
Message-ID: <5086A678.7010403@parallels.com>
Date: Tue, 23 Oct 2012 18:15:20 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] slab: move kmem_cache_free to common code
References: <1350914737-4097-1-git-send-email-glommer@parallels.com> <1350914737-4097-3-git-send-email-glommer@parallels.com> <0000013a88eff593-50da3bb8-3294-41db-9c32-4e890ef6940a-000000@email.amazonses.com> <508561E0.5000406@parallels.com> <CAAmzW4PJkDbLJBKZ1zPNDw+dHPcgzX_25tMw3rWoX0ybpXACSQ@mail.gmail.com> <50865024.60309@parallels.com> <0000013a8df775ea-2411bbc8-8025-4514-8b58-ef007d11beef-000000@email.amazonses.com>
In-Reply-To: <0000013a8df775ea-2411bbc8-8025-4514-8b58-ef007d11beef-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: JoonSoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 10/23/2012 06:12 PM, Christoph Lameter wrote:
> On Tue, 23 Oct 2012, Glauber Costa wrote:
> 
>> I do agree, but since freeing is ultimately dependent on the allocator
>> layout, I don't see a clean way of doing this without dropping tears of
>> sorrow around. The calls in slub/slab/slob would have to be somehow
>> inlined. Hum... maybe it is possible to do it from
>> include/linux/sl*b_def.h...
>>
>> Let me give it a try and see what I can come up with.
> 
> The best solution would be something that would have a consolidated
> kmem_cache_free() in include/linux/slab.h.
> 

I don't know what exactly do you have in mind, but since the cache
layouts are very different, this is quite hard to do without incurring
without function calls anyway.

Do take a look at what I sent in response to that, and tell me what do
you think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
