Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BBF2D6B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 03:02:54 -0400 (EDT)
Message-ID: <5063F94C.4090600@parallels.com>
Date: Thu, 27 Sep 2012 10:59:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com> <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On 09/27/2012 05:16 AM, David Rientjes wrote:
> On Wed, 26 Sep 2012, Glauber Costa wrote:
> 
>> So the problem I am facing here is that when I am creating caches from
>> memcg, I would very much like to reuse their flags fields. They are
>> stored in the cache itself, so this is not a problem. But slab also
>> stores that flag, leading to the precise BUG_ON() on CREATE_MASK that
>> you quoted.
>>
>> In this context, passing this flag becomes completely valid, I just need
>> that to be explicitly masked out.
>>
>> What is your suggestion to handle this ?
>>
> 
> I would suggest cachep->flags being used solely for the flags passed to 
> kmem_cache_create() and seperating out all "internal flags" based on the 
> individual slab allocator's implementation into a different field.  There 
> should be no problem with moving CFLGS_OFF_SLAB elsewhere, in fact, I just 
> removed a "dflags" field from mm/slab.c's kmem_cache that turned out never 
> to be used.  You could simply reintroduce a new "internal_flags" field and 
> use it at your discretion.
> 
I can do it with you both agree with the approach.

But I still don't see the big reason for your objection. If other
allocator start using those bits, they would not be passed to
kmem_cache_alloc anyway, right? So what would be the big problem in
masking them out before it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
