Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id C040C6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 16:39:59 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so6283932pbb.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 13:39:59 -0700 (PDT)
Date: Fri, 28 Sep 2012 13:39:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <0000013a0d390e11-03bf6f97-a8b7-4229-9f69-84aa85795b7e-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1209281336380.21335@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <5063F94C.4090600@parallels.com> <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com> <0000013a0d390e11-03bf6f97-a8b7-4229-9f69-84aa85795b7e-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 28 Sep 2012, Christoph Lameter wrote:

> > For context, as many people who attended the kernel summit and LinuxCon
> > are aware, a new slab allocator is going to be proposed soon that actually
> > uses additional bits that aren't defined for all slab allocators.  My
> > opinion is that leaving unused bits and reserved bits to the
> > implementation is the best software engineering practice.
> 
> Could you please come out with the new allocator and post some patchsets?
> 
> We can extend the number of flags reserved if necessary but we really need
> to see the source for that.
> 

The first prototype, SLAM XP1, will be posted in October.  I'd simply like 
to avoid reverting this patch down the road and having all of us 
reconsider the topic again when clear alternatives exist that, in my 
opinion, make the code cleaner.

 [ There _was_ a field for internal flags for mm/slab.c, called "dflags", 
   before I removed it because it was unused; I'm regretting that now 
   because it would have been very easy to use it for this purpose. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
