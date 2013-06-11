Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 2296C6B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:08:50 -0400 (EDT)
Date: Tue, 11 Jun 2013 15:08:48 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slab: prevent warnings when allocating with
 __GFP_NOWARN
In-Reply-To: <51B67553.6020205@oracle.com>
Message-ID: <0000013f33c83e5f-946866ad-d2d3-48e6-8035-6eaf1ac37fbe-000000@email.amazonses.com>
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com> <CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com> <51B62F6B.8040308@oracle.com> <0000013f3075f90d-735942a8-b4b8-413f-a09e-57d1de0c4974-000000@email.amazonses.com>
 <51B67553.6020205@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 10 Jun 2013, Sasha Levin wrote:

> > There must be another reason. Lets fix this.
>
> My, I feel silly now.
>
> I was the one who added __GFP_NOFAIL in the first place in
> 2ccd4f4d ("pipe: fail cleanly when root tries F_SETPIPE_SZ
> with big size").
>
> What happens is that root can go ahead and specify any size
> it wants to be used as buffer size - and the kernel will
> attempt to comply by allocation that buffer. Which fails
> if the size is too big.

Could you check that against a boundary? Use vmalloc if larger than a
couple of pages? Maybe PAGE_COSTLY_ORDER or so?

THe higher the order the more likely it is that the allocation will fail.
The PAGE_ORDER_COSTLY (or so) is a reasonable limit as to what size of a
linear contiguous allocation that can be expected to be successful.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
