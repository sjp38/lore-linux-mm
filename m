Date: Fri, 23 May 2003 08:02:22 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm8
Message-ID: <20030523150222.GC19818@holomorphy.com>
References: <20030522021652.6601ed2b.akpm@digeo.com> <17990000.1053670694@[10.10.2.4]> <1053673399.1547.27.camel@nighthawk> <26160000.1053700350@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <26160000.1053700350@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At some point in the past, Dave Hansen removed Martin Bligh's attribution from:
>>>       1004     2.0% default_idle
>>>        272     8.3% __copy_from_user_ll
>>>        129     1.7% __d_lookup
>>>         79     7.5% link_path_walk

At some point in the past, Martin Bligh removed Dave Hansen's attribution from:
>> I have to wonder if these are cache effects, or just noise.  Can you
>> give oprofile a try with one of the cache performance counters?

On Fri, May 23, 2003 at 07:32:31AM -0700, Martin J. Bligh wrote:
> No, but you can ;-)

Cache things are usually link order and .config dependent, in 2.4.x at
least they were highly dependent on cache color conflicts between task
structures and hot codepaths and similar bizarre phenomena. i.e. exact
binutils, compiler, kernel source, and .config matches are required to
reproduce. And sometimes even that isn't enough and it's not reproducible
across runs. You also want instruction-level multiplicative differential
profiling to find cacheline bounces, not function-level additive
differential profiling, with some method of correlating assembly to source.

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
