Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9DC966B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 10:56:53 -0400 (EDT)
Message-ID: <520B9AB0.7010209@fastmail.fm>
Date: Wed, 14 Aug 2013 17:56:48 +0300
From: Pekka Enberg <penberg@fastmail.fm>
MIME-Version: 1.0
Subject: Re: [3.12 1/3] Move kmallocXXX functions to common code
References: <20130813154940.741769876@linux.com> <00000140785e1062-89326db9-3999-43c1-b081-284dd49b3d9b-000000@email.amazonses.com>
In-Reply-To: <00000140785e1062-89326db9-3999-43c1-b081-284dd49b3d9b-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/13/2013 06:49 PM, Christoph Lameter wrote:
> As a results of this patch there is a common set of functions for
> all allocators. Also means that kmalloc_large() is now available
> in general to perform large order allocations that go directly
> via the page allocator. kmalloc_large() can be substituted if
> kmalloc() throws warnings because of too large allocations.
>
> kmalloc_large() has exactly the same semantics as kmalloc but
> can only used for allocations > PAGE_SIZE.

The introduction kmalloc_large() needs to happen in a
separate patch. What exactly is the benefit of adding the
new API, btw? Why don't people just use the page allocator
directly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
