Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C4BE46B010E
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 13:26:43 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so7369621pdi.21
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 10:26:43 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id xk4si11775583pbc.5.2014.03.18.10.26.42
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 10:26:42 -0700 (PDT)
Date: Tue, 18 Mar 2014 12:26:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Testing Large-Memory Hardware
In-Reply-To: <20140318165059.GI22095@laptop.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.10.1403181224000.23935@nuc>
References: <5328753B.2050107@intel.com> <20140318165059.GI22095@laptop.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, lsf@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 18 Mar 2014, Peter Zijlstra wrote:

> > My gut reaction was that we'd probably be better served by putting
> > resources in to systems with higher core counts rather than lots of RAM.
> >  I have encountered the occasional boot bug on my 1TB system, but it's
> > far from a frequent occurrence, and even more infrequent to encounter
> > things at runtime.
> >
> > Would folks agree with that?  What kinds of tests, benchmarks, stress
> > tests, etc... do folks run that are both valuable and can only be run on
> > a system with a large amount of actual RAM?
>
> We had a sched-numa + kvm fail on really large systems the other day,
> but yeah in general such problems tend to be rare. Then again, without
> test coverage they will always be rare, for even if there were problems,
> nobody would notice :-)

SGI had systems out there up to few PB of RAM. There were a couple of
tricks to get this going. Bootup time was pretty long. I/O has to be done
carefully. The MM subsystem used to work with these sizes (I have not had
a chance to verify that recently).

This was Itanium with 64K page size so you had a factor of 16 less page
structs to process. What I saw there is one of the reasons why I would
like to see larger page support in the kernel. Managing massive amounts of
4k pages is creation far too much overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
