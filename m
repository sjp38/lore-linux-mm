Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F0FB36B010F
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 09:31:43 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2036350bwz.38
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 06:31:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090921130440.GN12726@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie>
	 <1253302451-27740-2-git-send-email-mel@csn.ul.ie>
	 <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com>
	 <4AB5FD4D.3070005@kernel.org> <4AB5FFF8.7000602@cs.helsinki.fi>
	 <4AB6508C.4070602@kernel.org> <4AB739A6.5060807@in.ibm.com>
	 <20090921084248.GC12726@csn.ul.ie> <20090921130440.GN12726@csn.ul.ie>
Date: Mon, 21 Sep 2009 16:31:42 +0300
Message-ID: <84144f020909210631h23bf3292q1d87c063c7b5c126@mail.gmail.com>
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Sachin Sant <sachinp@in.ibm.com>, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 4:04 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>> The "per-cpu" area in this case is actually a per-node area. This implied that
>> it was either racing (but the locking looked sound), a buffer overflow (but
>> I couldn't find one) or the per-cpu areas were being written to by something
>> else unrelated.
>
> This latter guess was close to the mark but not for the reasons I was
> guessing. There isn't magic per-cpu-area-freeing going on. Once I examined
> the implementation of per-cpu data, it was clear that the per-cpu areas for
> the node IDs were never being allocated in the first place on PowerPC. It's
> probable that this never worked but that it took a long time before SLQB
> was run on a memoryless configuration.
>
> This patch would replace patch 1 of the first hatchet job I did. It's possible
> a similar patch is needed for S390. I haven't looked at the implementation
> there and I don't have a means of testing it.

Other architectures could be affected as well which makes me think
"hatchet job number one" is the way forward. Nick?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
