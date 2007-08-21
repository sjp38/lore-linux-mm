Date: Tue, 21 Aug 2007 14:30:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
In-Reply-To: <46CB55A8.4030501@redhat.com>
Message-ID: <Pine.LNX.4.64.0708211429530.3390@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <46CB01B7.3050201@redhat.com>
 <Pine.LNX.4.64.0708211355430.3082@schroedinger.engr.sgi.com>
 <46CB55A8.4030501@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Rik van Riel wrote:

> > What is preventing that from occurring right now? If the dirty pags are
> > aligned in the right way you can have the exact same situation.
> 
> For one, dirty page writeout is done even when free memory
> is low.  The kernel will dig into the PF_MEMALLOC reserves,
> instead of deciding not to do writeout unless there is lots
> of free memory.

Right that is a fundamental problem with this RFC. We need to be able to 
get into PF_MEMALLOC reserves for writeout.
  
> Secondly, why would you want to recreate this worst case on
> purpose every time the pageout code runs?

I did not intend that to occur.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
