Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 9795F6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 19:11:49 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so6411118pbb.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 16:11:48 -0700 (PDT)
Date: Fri, 28 Sep 2012 16:11:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <0000013a0ec088ee-69089a7c-125f-4e80-9881-e66ab96ab59d-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1209281606230.26759@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <5063F94C.4090600@parallels.com> <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com> <0000013a0d390e11-03bf6f97-a8b7-4229-9f69-84aa85795b7e-000000@email.amazonses.com>
 <alpine.DEB.2.00.1209281336380.21335@chino.kir.corp.google.com> <0000013a0ec088ee-69089a7c-125f-4e80-9881-e66ab96ab59d-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 28 Sep 2012, Christoph Lameter wrote:

> > The first prototype, SLAM XP1, will be posted in October.  I'd simply like
> > to avoid reverting this patch down the road and having all of us
> > reconsider the topic again when clear alternatives exist that, in my
> > opinion, make the code cleaner.
> 
> If you want to make changes to the kernel then you need to justify that at
> the time when we can consider your patches and the approach taken.
> 

If I cannot speak up and say where there will be conflicts in the future 
and ask that Glauber spend more of his time down the road to figure all of 
this out again, especially when a simple and clean alternative exists, 
then that seems to result in a big waste of time.  Nothing is suffering 
from taking the alternative here, so please follow the best software 
engineering practices of allowing an implementation to reserve and ignore 
bits in an API when appropriate and not do it globally in the common code.

All of the move to mm/slab_common.c has obviously slowed down posting of 
SLAM and I haven't complained about that once or asked that it not be 
done, I'm simply pointing out an instance here that will conflict later on 
if we go with this patch.  That, to me, is respectful of other people's 
time.  That said, I'll leave it to Glauber to decide how he'd like to 
handle this issue given the knowledge of what is to come.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
