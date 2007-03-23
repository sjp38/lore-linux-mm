Date: Fri, 23 Mar 2007 12:17:48 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
Message-ID: <20070323191748.GX2986@holomorphy.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com> <20070322223927.bb4caf43.akpm@linux-foundation.org> <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com> <20070322234848.100abb3d.akpm@linux-foundation.org> <20070323112920.GR2986@holomorphy.com> <20070323145707.GT2986@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070323145707.GT2986@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 22, 2007 at 11:48:48PM -0800, Andrew Morton wrote:
>>> afacit that two-year-old, totally-different patch has nothing to do with my
>>> repeatedly-asked question.  It appears to be consolidating three separate
>>> quicklist allocators into one common implementation.
>>> In an attempt to answer my own question (and hence to justify the retention
>>> of this custom allocator) I did this:
>> [... patch changing allocator alloc()/free() to bare page allocations ...]
>>> but it crashes early in the page allocator (i386) and I don't see why.  It
>>> makes me wonder if we have a use-after-free which is hidden by the presence
>>> of the quicklist buffering or something.

On Fri, Mar 23, 2007 at 04:29:20AM -0700, William Lee Irwin III wrote:
>> Sorry I flubbed the first message. Anyway this does mean something is
>> seriously wrong and needs to be debugged. Looking into it now.

On Fri, Mar 23, 2007 at 07:57:07AM -0700, William Lee Irwin III wrote:
> I know what's happening. I just need to catch the culprit.

Are you tripping the BUG_ON() in include/linux/mm.h:256 with
CONFIG_DEBUG_VM set?


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
