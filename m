Date: Mon, 27 Jan 2003 23:13:13 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1
Message-ID: <20030128071313.GH780@holomorphy.com>
References: <3.0.6.32.20030127224726.00806c20@boo.net> <884740000.1043737132@titus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <884740000.1043737132@titus>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Jason Papadopoulos <jasonp@boo.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

At some point in the past, Jason P. wrote:
>> This is yet another holding action, a port of my page coloring patch
>> to the 2.5 kernel. This is a minimal port (x86 only) intended to get
>> some testing done; once again the algorithm used is the same as in 
>> previous patches. There are several cleanups and removed 2.4-isms that
>> make the code somewhat more compact, though.
>> I'll be experimenting with other coloring schemes later this week.
>> www.boo.net/~jasonp/page_color-2.5.59-20030127.patch
>> Feedback of any sort welcome.

On Mon, Jan 27, 2003 at 10:58:53PM -0800, Martin J. Bligh wrote:
> I took a 16-way NUMA-Q (700MHz P3 Xeon's w/2MB L2 cache) and ran some 
> cpu-intensive benchmarks (kernel compile on warm cache with -j32 and
> -j 256, SDET 1 - 128 users, and numaschedbench with 1 to 64 processes, 
> which is a memory thrasher to test node affinity of memory operations), 
> and compared to virgin 2.5.59 - no measurable difference on any test. 

I think this one really needs to be done with the userspace cache
thrashing microbenchmarks. I also have rather serious reservations
about the interaction of the qlists with the per-cpu lists.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
