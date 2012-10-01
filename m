Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 970A86B005D
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 04:02:19 -0400 (EDT)
Message-ID: <50694D3C.8000603@parallels.com>
Date: Mon, 1 Oct 2012 11:58:52 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com> <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <5063F94C.4090600@parallels.com> <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com> <0000013a0d390e11-03bf6f97-a8b7-4229-9f69-84aa85795b7e-000000@email.amazonses.com> <alpine.DEB.2.00.1209281336380.21335@chino.kir.corp.google.com> <CAOJsxLFYSKqq-JexK1Q7NEtQmxtJnWB-WwbNyp9tk9mpAh6vGg@mail.gmail.com>
In-Reply-To: <CAOJsxLFYSKqq-JexK1Q7NEtQmxtJnWB-WwbNyp9tk9mpAh6vGg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>

On 10/01/2012 11:28 AM, Pekka Enberg wrote:
> Hello,
> 
> [ Found this in my @cs.helsinki.fi inbox, grmbl. ]
> 
> On Fri, Sep 28, 2012 at 11:39 PM, David Rientjes <rientjes@google.com> wrote:
>> The first prototype, SLAM XP1, will be posted in October.  I'd simply like
>> to avoid reverting this patch down the road and having all of us
>> reconsider the topic again when clear alternatives exist that, in my
>> opinion, make the code cleaner.
> 
> David, I'm sure you know we don't work speculatively against
> out-of-tree code that may or may not be include in the future...
> 
> That said, I don't like Glauber's patch because it leaves CREATE_MASK
> in mm/slab.c. And I'm not totally convinced a generic SLAB_INTERNAL is
> going to cut it either. Hmm.
> 
>                         Pekka
> 

How about we require allocators to define their own CREATE_MASK, and
then in slab_common.c we mask out any flags outside that mask?

This way we can achieve masking in common code while still leaving the
decision to the allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
