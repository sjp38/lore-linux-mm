Date: Wed, 26 Mar 2008 18:54:27 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: larger default page sizes...
Message-ID: <20080326185427.GA874@csn.ul.ie>
References: <18408.29107.709577.374424@cargo.ozlabs.ibm.com> <20080324.211532.33163290.davem@davemloft.net> <18408.59112.945786.488350@cargo.ozlabs.ibm.com> <20080325.163240.102401706.davem@davemloft.net> <1FE6DD409037234FAB833C420AA843ECE9E2CA@orsmsx424.amr.corp.intel.com> <29495f1d0803260854j46d37eedrc0927af226b3b8c8@mail.gmail.com> <1FE6DD409037234FAB833C420AA843ECE9E7AC@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE9E7AC@orsmsx424.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, David Miller <davem@davemloft.net>, paulus@samba.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On (26/03/08 10:05), Luck, Tony didst pronounce:
> > That's not entirely true. We have a dynamic pool now, thanks to Adam
> > Litke [added to Cc], which can be treated as a high watermark for the
> > hugetlb pool (and the static pool value serves as a low watermark).
> > Unless by hugepages you mean something other than what I think (but
> > referring to a 2M size on x86 imples you are not). And with the
> > antifragmentation improvements, hugepage pool changes at run-time are
> > more likely to succeed [added Mel to Cc].
> 
> Things are better than I thought ... though the phrase "more likely
> to succeed" doesn't fill me with confidence. 

It's a lot more likely to succeed since 2.6.24 than it has in the past. On
workloads where it is mainly user data that is occuping memory, the chances
are even better. If min_free_kbytes is hugepage_size*num_online_nodes(),
it becomes a harder again to fragment memory.

> Instead I imagine a
> system where an occasional spike in memory load causes some memory
> fragmentation that can't be handled, and so from that point many of
> the applications that relied on huge pages take a 10% performance
> hit. 

If it was found to be a problem and normal anti-frag is not coping for hugepage
pool resizes, then specify movablecore=MAX_POSSIBLE_POOL_SIZE_YOU_WOULD_NEED
on the command-line and the hugepage pool will be able to expand to that
side independent of workload. This would avoid the need to scheduled regular
reboots.

> This results in sysadmins scheduling regular reboots to unjam
> things. [Reminds me of the instructions that came with my first
> flatbed scanner that recommended rebooting the system before and
> after each use :-( ]
> 
> > I feel like I should promote libhugetlbfs here.
> 
> This is also better than I thought ... sounds like some really
> good things have already happened here.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
