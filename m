Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1593D6B0391
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 05:27:14 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so555248579pgq.7
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 02:27:14 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id a9si18594844pgn.328.2016.12.21.02.27.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 02:27:13 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id b1so15831120pgc.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 02:27:13 -0800 (PST)
Date: Wed, 21 Dec 2016 20:26:56 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161221202640.081cd4bf@roar.ozlabs.ibm.com>
In-Reply-To: <20161221080931.GQ3124@twins.programming.kicks-ass.net>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
	<CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
	<156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
	<CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
	<CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
	<20161221080931.GQ3124@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, 21 Dec 2016 09:09:31 +0100
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Dec 20, 2016 at 10:02:46AM -0800, Linus Torvalds wrote:
> > On Tue, Dec 20, 2016 at 9:31 AM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:  
> > >
> > > I'll go back and try to see why the page flag contention patch didn't
> > > get applied.  
> > 
> > Ahh, a combination of warring patches by Nick and PeterZ, and worry
> > about the page flag bits.  
> 
> I think Nick actually had a patch freeing up a pageflag, although Hugh
> had a comment on that.

Yeah I think he basically acked it. It had a small compound debug
false positive but I think it's okay. I'm just testing it again.
 
> That said, I'm not a huge fan of his waiters patch, I'm still not sure
> why he wants to write another whole wait loop, but whatever. Whichever
> you prefer I suppose.

Ah, I was waiting for some feedback, thanks.

Well I wanted to do it that way to keep the manipulation of the new
bit under the same lock as the waitqueue, so as not to introduce new
memory orderings vs testing waitqueue_active.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
