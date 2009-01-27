Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9E06B0044
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 16:53:54 -0500 (EST)
Message-ID: <497F8172.7000403@cs.helsinki.fi>
Date: Tue, 27 Jan 2009 23:49:38 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] kmalloc: Return NULL instead of link failure
References: <4975F376.4010506@suse.com> <20090127133723.46eb7035.akpm@linux-foundation.org>
In-Reply-To: <20090127133723.46eb7035.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jeff Mahoney <jeffm@suse.com>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 20 Jan 2009 10:53:26 -0500
> Jeff Mahoney <jeffm@suse.com> wrote:
> 
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>>  The SLAB kmalloc with a constant value isn't consistent with the other
>>  implementations because it bails out with __you_cannot_kmalloc_that_much
>>  rather than returning NULL and properly allowing the caller to fall back
>>  to vmalloc or take other action. This doesn't happen with a non-constant
>>  value or with SLOB or SLUB.
>>
>>  Starting with 2.6.28, I've been seeing build failures on s390x. This is
>>  due to init_section_page_cgroup trying to allocate 2.5MB when the max
>>  size for a kmalloc on s390x is 2MB.
>>
>>  It's failing because the value is constant. The workarounds at the call
>>  size are ugly and the caller shouldn't have to change behavior depending
>>  on what the backend of the API is.
>>
>>  So, this patch eliminates the link failure and returns NULL like the
>>  other implementations.
>>
> 
> OK by me, is that's what the other sl[abcd...xyz]b.c implementations
> do.
> 
> That __you_cannot_kmalloc_that_much() thing has frequently been a PITA
> anyway - some gcc versions flub the constant_p() test and end up
> referencing __you_cannot_kmalloc_that_much() when the callsite was
> passing a variable `size' arg.

[snip]

> Strange patch format, but it applied.
> 
> I'll punt this patch in the Pekka direction.

Applied, thanks!

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
