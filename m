Date: Tue, 19 Aug 2003 14:10:00 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test3-mm3
Message-Id: <20030819141000.7df20405.akpm@osdl.org>
In-Reply-To: <20030819183249.GD19465@matchmail.com>
References: <20030819013834.1fa487dc.akpm@osdl.org>
	<20030819183249.GD19465@matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Fedyk <mfedyk@matchmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Fedyk <mfedyk@matchmail.com> wrote:
>
> On Tue, Aug 19, 2003 at 01:38:34AM -0700, Andrew Morton wrote:
> > +disable-athlon-prefetch.patch
> > 
> >  Disable prefetch() on all AMD CPUs.  It seems to need significant work to
> >  get right and we're currently getting rare oopses with K7's.
> 
> Is this going to stay in -mm, or will it eventually propogate to stock?

That depends if someone does any work on it in the next few days I guess. 
Right now we're getting mysterious oopses down inside fine_inode_fast,
which is unacceptable.

> If it does, can this be added to the to-do list of things to fix before 2.6.0?
> 
> I'd hate to see this feature lost...

Show me a workload in which it makes a measurable difference.

But no, it won't get forgotten.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
