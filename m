Date: Thu, 3 Jan 2008 09:55:25 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
Message-ID: <20080103085525.GB10813@elte.hu>
References: <20071218211539.250334036@redhat.com> <200712201859.12934.nickpiggin@yahoo.com.au> <477C1FB6.5050905@sgi.com> <200801031707.14607.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200801031707.14607.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mike Travis <travis@sgi.com>, Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <peterz@infradead.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > Have you done anything more with allowing > 256 CPUS in this 
> > spinlock patch?  We've been testing with 1k cpus and to verify with 
> > -mm kernel, we need to "unpatch" these spinlock changes.
> 
> Hi Mike,
> 
> Actually I had it in my mind that 64 bit used single-byte locking like 
> i386, so I didn't think I'd caused a regression there.
> 
> I'll take a look at fixing that up now.

thanks - this is a serious showstopper for the ticket spinlock patch. 

( which has otherwise been performing very well in x86.git so far - it 
  has passed a few thousand bootup tests on 64-bit and 32-bit as well, 
  so we are close to it being in a mergable state. Would be a pity to
  lose it due to the 256 cpus limit. )

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
