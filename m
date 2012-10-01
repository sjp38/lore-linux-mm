Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 14D846B0087
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 13:54:14 -0400 (EDT)
Date: Mon, 1 Oct 2012 17:54:12 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <alpine.DEB.2.00.1209281606230.26759@chino.kir.corp.google.com>
Message-ID: <0000013a1d76c065-7134a937-7892-40df-80bd-e7189eff7e4c-000000@email.amazonses.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <5063F94C.4090600@parallels.com> <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com> <0000013a0d390e11-03bf6f97-a8b7-4229-9f69-84aa85795b7e-000000@email.amazonses.com>
 <alpine.DEB.2.00.1209281336380.21335@chino.kir.corp.google.com> <0000013a0ec088ee-69089a7c-125f-4e80-9881-e66ab96ab59d-000000@email.amazonses.com> <alpine.DEB.2.00.1209281606230.26759@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 28 Sep 2012, David Rientjes wrote:

> All of the move to mm/slab_common.c has obviously slowed down posting of
> SLAM and I haven't complained about that once or asked that it not be
> done, I'm simply pointing out an instance here that will conflict later on
> if we go with this patch.  That, to me, is respectful of other people's
> time.  That said, I'll leave it to Glauber to decide how he'd like to
> handle this issue given the knowledge of what is to come.

I do not mind if you post a version against some older kernel. We can
then see what is going on and come to an agreement on how to move forward.
I just want to finally *see* the patches instead of just hot talk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
