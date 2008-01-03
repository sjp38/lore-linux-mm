From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
Date: Thu, 3 Jan 2008 17:07:14 +1100
References: <20071218211539.250334036@redhat.com> <200712201859.12934.nickpiggin@yahoo.com.au> <477C1FB6.5050905@sgi.com>
In-Reply-To: <477C1FB6.5050905@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801031707.14607.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <peterz@infradead.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thursday 03 January 2008 10:35, Mike Travis wrote:
> Hi Nick,
>
> Have you done anything more with allowing > 256 CPUS in this spinlock
> patch?  We've been testing with 1k cpus and to verify with -mm kernel,
> we need to "unpatch" these spinlock changes.
>
> Thanks,
> Mike

Hi Mike,

Actually I had it in my mind that 64 bit used single-byte locking like
i386, so I didn't think I'd caused a regression there.

I'll take a look at fixing that up now.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
