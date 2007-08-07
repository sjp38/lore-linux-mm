Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7703URO008566
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 20:03:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7703U2l212918
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 18:03:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7703UCf009535
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 18:03:30 -0600
Date: Mon, 6 Aug 2007 17:03:29 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] hugetlb: fix cpuset-constrained pool resizing
Message-ID: <20070807000329.GU15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com> <20070806163841.GL15714@us.ibm.com> <20070806164055.GN15714@us.ibm.com> <20070806164410.GO15714@us.ibm.com> <Pine.LNX.4.64.0708061101470.24256@schroedinger.engr.sgi.com> <20070806182616.GT15714@us.ibm.com> <Pine.LNX.4.64.0708061137510.3152@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708061137510.3152@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On 06.08.2007 [11:41:12 -0700], Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:
> 
> > I understand what you mean, that root should be able to do whatever it
> > wants, but at the same time, if a root-owned process is running in a
> > cpuset, it's constrained for a reason.
> 
> Yes but the constraint is for an application running under a regular 
> user id not for the root user.
> 
> > More importantly, let's say your process (owned by root or not) is
> > running in a restricted cpuset on  nodes 2 and 3 of a 4-node system and
> > wants to use 100 hugepages. Using the global sysctl, presuming an equal
> > distribution of free memory on all nodes, said process would need to
> > allocate 200 hugepages on the system (50 on each node), to get 100
> > hugepages on nodes 2 and 3. With this patch, it only needs to allocate
> > 100 hugepages.
> 
> The app is not able to use the sysctl. The root user must be able to do 
> whatever desired. Does not make sense to impose restrictions on sysctls.
> 
> > Become dependent on the *proccess* context, which is, to me, what would
> > be expected. If a process is restricted in some way, I would expect it
> > to be restricted in that way across the board.
> 
> Nope these values are global. Cpuset relative data belongs in /dev/cpuset.

Ok, I'll respin the patches with this in mind and resubmit.

Thanks for the feedback,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
