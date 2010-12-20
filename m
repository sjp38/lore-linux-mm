Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1D06B008C
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 06:17:03 -0500 (EST)
Date: Mon, 20 Dec 2010 11:16:40 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Transparent Hugepage Support #33
Message-ID: <20101220111639.GQ13914@csn.ul.ie>
References: <20101215051540.GP5638@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101215051540.GP5638@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 15, 2010 at 06:15:40AM +0100, Andrea Arcangeli wrote:
> Some of some relevant user of the project:
> 
> KVM Virtualization
> GCC (kernel build included, requires a few liner patch to enable)
> JVM
> VMware Workstation
> HPC
> 
> It would be great if it could go in -mm.
> 

I ran some basic performance tests comparing base pages, hugetlbfs and
transparent huge pages.

STREAM (triad only)
Triad--17.0    18955.94 ( 0.00%) 18955.94 ( 0.00%) 18955.94 ( 0.00%)
Triad--17.33   19756.78 ( 0.00%) 19756.78 ( 0.00%) 19808.90 ( 0.26%)
Triad--17.66   19918.20 ( 0.00%) 19918.20 ( 0.00%) 19918.20 ( 0.00%)
Triad--18.0    19303.15 ( 0.00%) 19687.37 ( 1.95%) 19199.75 (-0.54%)
Triad--18.33   18397.44 ( 0.00%) 18556.45 ( 0.86%) 18443.83 ( 0.25%)
Triad--18.66   18917.43 ( 0.00%) 19088.28 ( 0.90%) 18865.09 (-0.28%)
Triad--19.0    16338.07 ( 0.00%) 18794.78 (13.07%) 16380.81 ( 0.26%)
Triad--19.33   11402.08 ( 0.00%) 11387.21 (-0.13%) 11226.44 (-1.56%)
Triad--19.66    9654.13 ( 0.00%)  9516.96 (-1.44%)  9666.16 ( 0.12%)
Triad--20.0     9556.79 ( 0.00%)  9572.48 ( 0.16%)  9573.63 ( 0.18%)
Triad--20.33    9553.81 ( 0.00%)  9524.22 (-0.31%)  9552.19 (-0.02%)
Triad--20.66    9504.67 ( 0.00%)  9504.67 ( 0.00%)  9509.61 ( 0.05%)
Triad--21.0     9500.04 ( 0.00%)  9538.13 ( 0.40%)  9501.06 ( 0.01%)
Triad--21.33    9355.53 ( 0.00%)  9511.82 ( 1.64%)  9391.13 ( 0.38%)
Triad--21.66    9310.97 ( 0.00%)  9535.04 ( 2.35%)  9459.83 ( 1.57%)
Triad--22.0     9264.88 ( 0.00%)  9521.61 ( 2.70%)  9512.85 ( 2.61%)
Triad--22.33    9197.81 ( 0.00%)  9505.28 ( 3.23%)  9442.67 ( 2.59%)
Triad--22.66    8535.29 ( 0.00%)  8965.94 ( 4.80%)  8839.97 ( 3.45%)
Triad--23.0     7158.25 ( 0.00%)  7462.07 ( 4.07%)  7373.10 ( 2.91%)
Triad--23.33    5659.50 ( 0.00%)  5708.15 ( 0.85%)  5695.34 ( 0.63%)
Triad--23.66    5191.97 ( 0.00%)  5200.99 ( 0.17%)  5175.16 (-0.32%)
Triad--24.0     4960.82 ( 0.00%)  5038.79 ( 1.55%)  5017.61 ( 1.13%)
Triad--24.33    4734.72 ( 0.00%)  4767.03 ( 0.68%)  4752.25 ( 0.37%)
Triad--24.66    4694.59 ( 0.00%)  4687.10 (-0.16%)  4698.72 ( 0.09%)
Triad--25.0     4701.91 ( 0.00%)  4823.23 ( 2.52%)  4759.94 ( 1.22%)
Triad--25.33    4664.94 ( 0.00%)  4748.64 ( 1.76%)  4690.97 ( 0.55%)
Triad--25.66    4670.35 ( 0.00%)  4751.30 ( 1.70%)  4706.59 ( 0.77%)
Triad--26.0     4704.77 ( 0.00%)  4814.09 ( 2.27%)  4788.46 ( 1.75%)
Triad--26.33    4702.14 ( 0.00%)  4707.05 ( 0.10%)  4677.77 (-0.52%)
Triad--26.66    4668.22 ( 0.00%)  4682.79 ( 0.31%)  4671.49 ( 0.07%)
Triad--27.0     4728.34 ( 0.00%)  4807.55 ( 1.65%)  4794.87 ( 1.39%)
Triad--27.33    4722.43 ( 0.00%)  4765.43 ( 0.90%)  4757.13 ( 0.73%)
Triad--27.66    4721.08 ( 0.00%)  4748.82 ( 0.58%)  4748.01 ( 0.57%)
Triad--28.0     4720.13 ( 0.00%)  4804.78 ( 1.76%)  4792.87 ( 1.52%)
Triad--28.33    4685.32 ( 0.00%)  4674.07 (-0.24%)  4627.00 (-1.26%)
Triad--28.66    4689.31 ( 0.00%)  4690.17 ( 0.02%)  4654.35 (-0.75%)
Triad--29.0     4740.42 ( 0.00%)  4780.69 ( 0.84%)  4779.78 ( 0.82%)
Triad--29.33    4688.10 ( 0.00%)  4655.82 (-0.69%)  4722.80 ( 0.73%)
Triad--29.66    4719.65 ( 0.00%)  4670.27 (-1.06%)  4768.32 ( 1.02%)
Triad--30.0     4731.50 ( 0.00%)  4786.19 ( 1.14%)  4773.81 ( 0.89%)
Triad--30.33    4722.82 ( 0.00%)  4734.01 ( 0.24%)  4748.29 ( 0.54%)
Triad--30.66    4732.06 ( 0.00%)  4721.55 (-0.22%)  4733.16 ( 0.02%)
Triad--31.0     4756.53 ( 0.00%)  4784.76 ( 0.59%)  4767.52 ( 0.23%)

I didn't include the other operations because the results are comparable
each time. Broadly speaking, hugetlbfs does slightly better but
transparent huge pages did improve performance a small amount.

SYSBENCH 
threads                     base              huge         transhuge
1              18629.91 ( 0.00%) 19017.23 ( 2.04%) 18766.30 ( 0.73%)
2              29691.39 ( 0.00%) 30062.81 ( 1.24%) 29808.59 ( 0.39%)
3              39824.00 ( 0.00%) 40324.75 ( 1.24%) 40002.75 ( 0.45%)
4              67639.65 ( 0.00%) 69231.83 ( 2.30%) 68305.58 ( 0.97%)
5              66833.81 ( 0.00%) 68339.77 ( 2.20%) 67393.01 ( 0.83%)
6              66168.22 ( 0.00%) 67875.52 ( 2.52%) 67255.45 ( 1.62%)
7              65775.08 ( 0.00%) 67386.93 ( 2.39%) 66208.60 ( 0.65%)
8              64899.14 ( 0.00%) 66588.38 ( 2.54%) 65367.80 ( 0.72%)

In some ways this is more interesting. hugetlbfs is backing only the
shared memory segment where transhuge is promoting other areas. Hence,
it's not really a like-with-like comparison but still, transparent
hugepages is pushing up performance by a small amount.

NAS-SER C Class (time, lower is better)
                            base         huge-heap         transhuge
bt.C            1389.33 ( 0.00%)  1421.64 (-2.27%)  1315.75 ( 5.59%)
cg.C             561.27 ( 0.00%)   509.38 (10.19%)   562.71 (-0.26%)
ep.C             375.78 ( 0.00%)   376.69 (-0.24%)   371.86 ( 1.05%)
ft.C             374.43 ( 0.00%)   371.73 ( 0.73%)   341.87 ( 9.52%)
is.C              17.84 ( 0.00%)    18.80 (-5.11%)    18.49 (-3.52%)
lu.C            1655.91 ( 0.00%)  1668.52 (-0.76%)  1662.25 (-0.38%)
mg.C             134.28 ( 0.00%)   136.96 (-1.96%)   128.04 ( 4.87%)
sp.C            1214.57 ( 0.00%)  1261.40 (-3.71%)  1151.98 ( 5.43%)
ua.C            1070.87 ( 0.00%)  1115.73 (-4.02%)  1048.45 ( 2.14%)

This is more of a like-with-like comparison as hugetlbfs is only backing
the heap. Results were mixed. Sometimes hugetlbfs was better and other times
transhuge was THP won the majority of the time.

SPECjvm huge page comparison
                            base              huge         transhuge
compiler         145.54 ( 0.00%)   156.00 ( 6.71%)   156.23 ( 6.84%)
compress         168.07 ( 0.00%)   175.15 ( 4.04%)   174.83 ( 3.87%)
crypto           164.30 ( 0.00%)   157.16 (-4.54%)   156.39 (-5.06%)
derby             53.64 ( 0.00%)    68.71 (21.93%)    58.57 ( 8.42%)
mpegaudio         81.80 ( 0.00%)    94.29 (13.25%)    92.58 (11.64%)
scimark.large     22.97 ( 0.00%)    21.43 (-7.19%)    21.59 (-6.39%)
scimark.small    119.25 ( 0.00%)   122.10 ( 2.33%)   121.44 ( 1.80%)
serial            46.93 ( 0.00%)    46.83 (-0.21%)    47.65 ( 1.51%)
sunflow           47.49 ( 0.00%)    50.03 ( 5.08%)    48.51 ( 2.10%)
xml              206.17 ( 0.00%)   211.42 ( 2.48%)   212.77 ( 3.10%)

hugetlbfs edged out transparent hugepages the majority of the times but
broadly speaking they were comparable in terms of performance.

Bottom-line is that overall transparent hugepages is delivering the expected
performance for this range of workloads at least. It's generally not as
good as hugetlbfs in terms of raw performance but that is hardly a surprise
considering how they both operate and what their objectives are.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
