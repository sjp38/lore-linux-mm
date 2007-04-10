Date: Mon, 9 Apr 2007 17:26:05 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [QUICKLIST 1/4] Quicklists for page table pages V5
Message-ID: <20070410002605.GY2986@holomorphy.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com> <20070409144107.21287fb8.akpm@linux-foundation.org> <Pine.LNX.4.64.0704091501230.2761@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704091501230.2761@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 9 Apr 2007, Andrew Morton wrote:
>> So... we skipped i386 this time?
>> I'd have gone squeamish if it was included, due to the mystery crash when
>> we (effectively) set the list size to zero.  Someone(tm) should look into 
>> that - who knows, it might indicate a problem in generic code.

On Mon, Apr 09, 2007 at 03:03:19PM -0700, Christoph Lameter wrote:
> Yeah too many scary monsters in the i386 arch code. Maybe Bill Irwin can 
> take a look at how to make this work? He liked the benchmarking code that 
> I posted so he may have the tools to insure that it works right. Maybe he 
> can figure out some additional tricks on how to make quicklists work 
> better?

There shouldn't be anything all that interesting in the i386 code apart
from accommodations made for slab.c and pageattr.c. But yes, I can do
the grunt work there since I'm familiar enough with its history.

I used the i386 pagetable caching backout code to help verify that
nothing unusual was going on with generic code in this area. I can
debug the altered quicklist code in like fashion to what that was.

Basically, I'll help all this along.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
