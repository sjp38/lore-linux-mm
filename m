Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B27786B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 16:25:49 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so2976021pad.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 13:25:48 -0700 (PDT)
Date: Fri, 28 Sep 2012 13:25:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <506555E9.2030809@parallels.com>
Message-ID: <alpine.DEB.2.00.1209281324490.21335@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <5063F94C.4090600@parallels.com> <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com> <506555E9.2030809@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> I am happy as long as we don't BUG and can mask out that feature.
> If Christoph is happy with me masking it in the SLAB only, I'm also fine.
> 

Absolutely, I agree that the implementation-defined __kmem_cache_create() 
can mask out bits that are not useful on the particular allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
