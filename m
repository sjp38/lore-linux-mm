Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 271546B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 03:46:50 -0400 (EDT)
Message-ID: <5035DF2E.2010101@parallels.com>
Date: Thu, 23 Aug 2012 11:43:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C12 [12/19] Move kmem_cache allocations into common code.
References: <20120820204021.494276880@linux.com> <0000013945cd2d87-d71d0827-51b3-4c98-890f-12beb8ecc72b-000000@email.amazonses.com> <50337722.3040908@parallels.com> <000001394afa9429-b8219750-1ae1-45f2-be1b-e02054615021-000000@email.amazonses.com> <50349B70.1050208@parallels.com> <000001394ef0020a-6778ce80-b864-41f4-a515-458cb0a95e6d-000000@email.amazonses.com>
In-Reply-To: <000001394ef0020a-6778ce80-b864-41f4-a515-458cb0a95e6d-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/22/2012 07:25 PM, Christoph Lameter wrote:
> On Wed, 22 Aug 2012, Glauber Costa wrote:
> 
>> On 08/22/2012 12:58 AM, Christoph Lameter wrote:
>>> On Tue, 21 Aug 2012, Glauber Costa wrote:
>>>
>>>> Doesn't boot (SLUB + debug options)
>>>
>>> Subject: slub: use kmem_cache_zalloc to zero kmalloc cache
>>>
>>> Memory for kmem_cache needs to be zeroed in slub after we moved the
>>> allocation into slab_commmon.
>>>
>> Confirmed fixed.
> 
> The code that was fixed is removed in one of the later patches.
> 
I don't see how it matters.

This code is prone to errors, as can be easily seen by the amount of
interactions it had, all of them with bugs. Our best friend in finding
those bugs is pinpointing the patch where it happens. Please make it easy.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
