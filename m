Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id D527C6B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 12:06:00 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id b14so138267255qge.2
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 09:06:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a190si3707919qke.76.2016.04.22.09.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 09:06:00 -0700 (PDT)
Date: Fri, 22 Apr 2016 12:05:57 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/5] userfaultfd: extension for non cooperative uffd usage
Message-ID: <20160422160557.GB4282@redhat.com>
References: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
 <57174F90.7080109@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57174F90.7080109@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Mike Rapoport <rapoport@il.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>

Hello Pavel and Mike,

On Wed, Apr 20, 2016 at 12:44:48PM +0300, Pavel Emelyanov wrote:
> On 03/20/2016 03:42 PM, Mike Rapoport wrote:
> > Hi,
> > 
> > This set is to address the issues that appear in userfaultfd usage
> > scenarios when the task monitoring the uffd and the mm-owner do not 
> > cooperate to each other on VM changes such as remaps, madvises and 
> > fork()-s.
> > 
> > The pacthes are essentially the same as in the prevoious respin (1),
> > they've just been rebased on the current tree.

Thanks for the rebasing and the submit of these new features!

> 
> Hi, Andrea.
> 
> Hopefully one day after LSFMM is good time to try to get a bit of
> your attention to this set :)

Yes, at first glance this patchset looks fine. In fact I already
merged it in my tree at the time of last post. Just I didn't have much
time to review it in detail yet as I did with the wrprotect tracking
one, this is why I didn't answer yet, sorry.

As said I already reviewed the wrprotect tracking feature in detail
and it requires a few (but non trivial) fixes and I was planning to
fix that part first as the developer who sent the first implementation
a few months ago got busy with something else. But until those bugs
gets fixed I cannot ship it in my tree, nor in the way to -mm.

The other main reason of the delay is that I got sidetracked by other
issues (one internal) and the other notable one is the failure in
postcopy caused by the new THP refcounting introduced in 4.5 with THP
enabled, which apparently isn't the huge zeropage (tested with
use_zero_page = 0) nor the MADV_DONTNEED. I'm also unconvinced it's a
bug only in the userfaultfd interaction with the new THP refcounting,
perhaps it's something more generic that just happen to be reproduced
more easily by the heavy postcopy load, which makes it even more high
priority to track that down.

I'm afraid until that regression is fixed, I'll have to concentrate on
fixing that. At least I found a way to reproduce faster so I'm
optimistic it won't take long ;).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
