Date: Sat, 20 Jul 2002 13:54:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] for_each_pgdat
Message-ID: <20020720205454.GF1096@holomorphy.com>
References: <1027196535.1116.773.camel@sinai> <236911771.1027172579@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <236911771.1027172579@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Robert Love <rml@tech9.net>, akpm@zip.com.au, torvalds@transmeta.com, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At some point in the past, Robert Love wrote:
>> This patch implements for_each_pgdat(pg_data_t *) which is a helper
>> macro to cleanup code that does a loop of the form:

On Sat, Jul 20, 2002 at 01:43:00PM -0700, Martin J. Bligh wrote:
> If you're going to do that (which I think is a good idea) can you
> rename node_next to pgdat_next, as it often has nothing to do with
> nodes whatsoever (discontigmem on a non-NUMA machine, or even more
> confusingly a NUMA machine which is discontig within a node)? I'll
> attatch a patch below, but it conflicts what what you're doing
> horribly, and it's even easier to do after your abtraction ...

Another option would be to convert pgdats to using list.h, which would
make things even prettier IMHO. After wrapping the list iterations it's
actually not difficult to swizzle the list linkage out from underneath.

And yes, s/pgdat/physcontig_region/ or whatever would make the name
match the intended usage.



Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
