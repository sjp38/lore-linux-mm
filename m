From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 06/33] mm: allow PF_MEMALLOC from softirq context
Date: Wed, 31 Oct 2007 21:49:24 +1100
References: <20071030160401.296770000@chello.nl> <200710311451.56747.nickpiggin@yahoo.com.au> <1193827359.27652.129.camel@twins>
In-Reply-To: <1193827359.27652.129.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710312149.25296.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 21:42, Peter Zijlstra wrote:
> On Wed, 2007-10-31 at 14:51 +1100, Nick Piggin wrote:
> > On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > > Allow PF_MEMALLOC to be set in softirq context. When running softirqs
> > > from a borrowed context save current->flags, ksoftirqd will have its
> > > own task_struct.
> >
> > What's this for? Why would ksoftirqd pick up PF_MEMALLOC? (I guess
> > that some networking thing must be picking it up in a subsequent patch,
> > but I'm too lazy to look!)... Again, can you have more of a rationale in
> > your patch headers, or ref the patch that uses it... thanks
>
> Right, I knew I was forgetting something in these changelogs.
>
> The network stack does quite a bit of packet processing from softirq
> context. Once you start swapping over network, some of the packets want
> to be processed under PF_MEMALLOC.

Hmm... what about processing from interrupt context?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
