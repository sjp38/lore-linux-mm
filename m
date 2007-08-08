Subject: Re: [RFC][PATCH 4/5] hugetlb: fix cpuset-constrained pool resizing
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070808015042.GF15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com>
	 <20070806163726.GK15714@us.ibm.com> <20070806163841.GL15714@us.ibm.com>
	 <20070806164055.GN15714@us.ibm.com> <20070806164410.GO15714@us.ibm.com>
	 <Pine.LNX.4.64.0708061101470.24256@schroedinger.engr.sgi.com>
	 <20070808015042.GF15714@us.ibm.com>
Content-Type: text/plain
Date: Wed, 08 Aug 2007 09:26:38 -0400
Message-Id: <1186579598.5055.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-07 at 18:50 -0700, Nishanth Aravamudan wrote:
<snip>
> Finally, after my hugetlb interleave dequeue patch is applied:
> 
> /cpuset ~
> Trying to resize the pool to     200 from the top cpuset
> Node 3 HugePages_Free:     50
> Node 2 HugePages_Free:     50
> Node 1 HugePages_Free:     50
> Node 0 HugePages_Free:     50
> Done.     200 free
> Trying to resize the pool back to     100 from the top cpuset
> Node 3 HugePages_Free:     25
> Node 2 HugePages_Free:     25
> Node 1 HugePages_Free:     25
> Node 0 HugePages_Free:     25
> Done.     100 free
> /cpuset/set1 /cpuset ~
> Trying to resize the pool to     200 from a cpuset restricted to node 1
> Node 3 HugePages_Free:     50
> Node 2 HugePages_Free:     50
> Node 1 HugePages_Free:     50
> Node 0 HugePages_Free:     50
> Done.     200 free
> Trying to shrink the pool down to 0 from a cpuset restricted to node 1
> Node 3 HugePages_Free:      0
> Node 2 HugePages_Free:      0
> Node 1 HugePages_Free:      0
> Node 0 HugePages_Free:      0
> Done.       0 free

That's the behavior I'd like to see!!!

> 
> So, it would appear that, in your opinion, this set of patches
> constitutes a pseudo-bug-fix? Without the last patch, it seems, cpusets
> are able to constrain what nodes a root process can remove hugepages
> from.
> 
> Thanks,
> Nish
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
