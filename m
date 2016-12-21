Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB0BF6B0385
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 03:09:33 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o141so131314381itc.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 00:09:33 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id r137si10213491itr.2.2016.12.21.00.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 00:09:33 -0800 (PST)
Date: Wed, 21 Dec 2016 09:09:31 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161221080931.GQ3124@twins.programming.kicks-ass.net>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
 <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
 <156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
 <CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
 <CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Tue, Dec 20, 2016 at 10:02:46AM -0800, Linus Torvalds wrote:
> On Tue, Dec 20, 2016 at 9:31 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > I'll go back and try to see why the page flag contention patch didn't
> > get applied.
> 
> Ahh, a combination of warring patches by Nick and PeterZ, and worry
> about the page flag bits.

I think Nick actually had a patch freeing up a pageflag, although Hugh
had a comment on that.

That said, I'm not a huge fan of his waiters patch, I'm still not sure
why he wants to write another whole wait loop, but whatever. Whichever
you prefer I suppose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
