Date: Wed, 22 Dec 2004 11:18:52 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/11] alternate 4-level page tables patches (take 2)
Message-ID: <20041222101852.GA15894@wotan.suse.de>
References: <41C94361.6070909@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41C94361.6070909@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Comments? Any consensus as to which way we want to go? I don't want to
> inflame tempers by continuing this line of work, just provoke discussion.

Personally I think it's still better to just convert the architectures
over like I did. It has to be done anyways, since you can't leave
the warnings in.

When that is done it doesn't matter much which level you hcange.

I offer my tested patchkit for that :) Main advantage is that since
it's already been tested for quite some time it would be possible
to merge it much faster. And Nick would save some work someone
else already did ;-)

If it helps I can do a global s/pml4_t/p<whatevernamelinusprefers>_t/ too.  

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
