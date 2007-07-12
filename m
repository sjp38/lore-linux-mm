Subject: Re: [RFT][PATCH] mm: drop behind
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <eada2a070707111537p20ab429anebd8b1840f5e5b5f@mail.gmail.com>
References: <1184007008.1913.45.camel@twins>
	 <eada2a070707111537p20ab429anebd8b1840f5e5b5f@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 12 Jul 2007 09:24:46 +0200
Message-Id: <1184225086.20032.45.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Pepper <lnxninja@us.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Fengguang Wu <wfg@mail.ustc.edu.cn>, riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Hi Tim,

On Wed, 2007-07-11 at 15:37 -0700, Tim Pepper wrote:
> On 7/9/07, Peter Zijlstra <peterz@infradead.org> wrote:
> > Use the read-ahead code to provide hints to page reclaim.
> >
> > This patch has the potential to solve the streaming-IO trashes my
> > desktop problem.
> >
> > It tries to aggressively reclaim pages that were loaded in a strong
> > sequential pattern and have been consumed. Thereby limiting the damage
> > to the current resident set.
> 
> Interesting...
> 
> Would it make sense to tie this into (finally) making
> POSIX_FADV_NOREUSE something more than a noop?

We talked about that, but the thing is, if we make the functionality
conditional, nobody will ever use it :-/

So, yes, in a perfect world that would indeed make sense. However since
nobody ever uses these [fm]advise calls,..

So the big question is, does this functionally hurt any workload? If it
turns out it does (which I still doubt) then we might hide it behind
knobs, otherwise I'd like to keep it always on.

Peter



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
