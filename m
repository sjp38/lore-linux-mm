Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 222A76B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 03:50:55 -0400 (EDT)
Message-ID: <506555E9.2030809@parallels.com>
Date: Fri, 28 Sep 2012 11:46:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com> <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <5063F94C.4090600@parallels.com> <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On 09/28/2012 02:56 AM, David Rientjes wrote:
> On Thu, 27 Sep 2012, Glauber Costa wrote:
> 
>> But I still don't see the big reason for your objection. If other
>> allocator start using those bits, they would not be passed to
>> kmem_cache_alloc anyway, right? So what would be the big problem in
>> masking them out before it?
>>
> 
> A slab allocator implementation may allow for additional bits that are 
> currently not used or used for internal purposes by the current set of 
> slab allocators to be passed in the unsigned long to kmem_cache_create() 
> that would be a no-op on other allocators.  It's implementation defined, 
> so this masking should be done in the implementation, i.e. 
> __kmem_cache_create().
> 
> For context, as many people who attended the kernel summit and LinuxCon 
> are aware, a new slab allocator is going to be proposed soon that actually 
> uses additional bits that aren't defined for all slab allocators.  My 
> opinion is that leaving unused bits and reserved bits to the 
> implementation is the best software engineering practice.
> 

I am happy as long as we don't BUG and can mask out that feature.
If Christoph is happy with me masking it in the SLAB only, I'm also fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
