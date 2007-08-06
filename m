Date: Mon, 6 Aug 2007 11:41:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 4/5] hugetlb: fix cpuset-constrained pool resizing
In-Reply-To: <20070806182616.GT15714@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0708061137510.3152@schroedinger.engr.sgi.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com>
 <20070806163841.GL15714@us.ibm.com> <20070806164055.GN15714@us.ibm.com>
 <20070806164410.GO15714@us.ibm.com> <Pine.LNX.4.64.0708061101470.24256@schroedinger.engr.sgi.com>
 <20070806182616.GT15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:

> I understand what you mean, that root should be able to do whatever it
> wants, but at the same time, if a root-owned process is running in a
> cpuset, it's constrained for a reason.

Yes but the constraint is for an application running under a regular 
user id not for the root user.
 
> More importantly, let's say your process (owned by root or not) is
> running in a restricted cpuset on  nodes 2 and 3 of a 4-node system and
> wants to use 100 hugepages. Using the global sysctl, presuming an equal
> distribution of free memory on all nodes, said process would need to
> allocate 200 hugepages on the system (50 on each node), to get 100
> hugepages on nodes 2 and 3. With this patch, it only needs to allocate
> 100 hugepages.

The app is not able to use the sysctl. The root user must be able to do 
whatever desired. Does not make sense to impose restrictions on sysctls.

> Become dependent on the *proccess* context, which is, to me, what would
> be expected. If a process is restricted in some way, I would expect it
> to be restricted in that way across the board.

Nope these values are global. Cpuset relative data belongs in /dev/cpuset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
