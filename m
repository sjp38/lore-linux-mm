Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch 
In-reply-to: Your message of Tue, 22 Oct 2002 10:09:47 PDT.
             <3DB5865B.4462537F@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6644.1035312307.1@us.ibm.com>
Date: Tue, 22 Oct 2002 11:45:11 -0700
Message-Id: <E18441g-0001jW-00@w-gerrit2>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In message <3DB5865B.4462537F@digeo.com>, > : Andrew Morton writes:
> Rik van Riel wrote:
> > 
> > ...
> > In short, we really really want shared page tables.
> 
> Or large pages.  I confess to being a little perplexed as to
> why we're pursuing both.

Large pages benefit the performance of large applications which
explicity take advantage of them (at least today - maybe in the
future, large pages will be automagically handed out to those that
can use them).  And, as a side effect, they reduce KVA overhead.
Oh, and at the moment, they are non-pageable, e.g. permanently stuck
in memory.

On the other hand, shared page tables benefit any application that
shares data, including those that haven't been trained to roll over
and beg for large pages.  Shared page tables are already showing large
space savings with at least one database.

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
