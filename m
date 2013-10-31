Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E1B796B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 18:25:26 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so2988219pdj.38
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 15:25:26 -0700 (PDT)
Received: from psmtp.com ([74.125.245.102])
        by mx.google.com with SMTP id t2si3015843pbq.188.2013.10.31.15.25.24
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 15:25:25 -0700 (PDT)
Received: by mail-ea0-f172.google.com with SMTP id r16so1718660ead.17
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 15:25:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131031095143.GA9692@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
	<20131024122646.GB2402@suse.de>
	<20131031095143.GA9692@gmail.com>
Date: Thu, 31 Oct 2013 15:25:22 -0700
Message-ID: <CA+55aFyDve4RtZ6n11ghFcq1kmzs52OB+xetZjyP1q3RparUkw@mail.gmail.com>
Subject: Re: [RFC GIT PULL] NUMA-balancing memory corruption fixes
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tom Weber <l_linux-kernel@mail2news.4t2.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On Thu, Oct 31, 2013 at 2:51 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
>
> ( If you think this is too dangerous for too little benefit then
>   I'll drop this separate tree and will send the original commits in
>   the merge window. )

Ugh. I hate hate hate the timing, and this is much larger and scarier
than what I'd like at this point, but I don't see the point to
delaying this either.

So I'm pulling them. And then I may end up doing an rc8 after all.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
