Date: Wed, 24 Jul 2002 20:14:50 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: page_add/remove_rmap costs
Message-ID: <165767220.1027541688@[10.10.2.3]>
In-Reply-To: <20020725030834.GC2907@holomorphy.com>
References: <20020725030834.GC2907@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Wed, Jul 24, 2002 at 01:15:10PM -0700, Andrew Morton wrote:
>> So.. who's going to do it?
>> It's early days yet - although this looks bad on benchmarks we really
>> need a better understanding of _why_ it's so bad, and of whether it
>> really matters for real workloads.
>> For example: given that copy_page_range performs atomic ops against
>> page->count, how come page_add_rmap()'s atomic op against page->flags
>> is more of a problem?

If it's bouncing the lock cacheline around that's suspected to be 
the problem, might it be faster to take a per-zone lock, rather
than a per-page lock, and batch the work up? Maybe we used a little
too much explosive when we broke up the global lock?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
