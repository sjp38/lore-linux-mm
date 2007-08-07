Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7704fGV000890
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 20:04:41 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7704f0w458188
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 20:04:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7704ew7030961
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 20:04:41 -0400
Date: Mon, 6 Aug 2007 17:04:40 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 1/5] Fix hugetlb pool allocation with empty nodes V9
Message-ID: <20070807000440.GV15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com> <Pine.LNX.4.64.0708061059400.24256@schroedinger.engr.sgi.com> <20070806181912.GS15714@us.ibm.com> <Pine.LNX.4.64.0708061136260.3152@schroedinger.engr.sgi.com> <1186429941.5065.24.camel@localhost> <Pine.LNX.4.64.0708061314030.7603@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708061314030.7603@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 06.08.2007 [13:15:36 -0700], Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Lee Schermerhorn wrote:
> 
> > I don't understand what you're asking either.  The function that Nish is
> > allocating the initial free huge page pool.  I thought that the intended
> > behavior of this function was to distribute new allocated huge pages
> > evenly across the nodes.  It was broken, in that for systems with
> > memoryless nodes, the allocation would immediately fall back to the next
> > node in the zonelist, overloading that node with huge page.  
> 
> I am all for distributing the pages evenly. The problem is that new
> functions are now exported from the memory policy layer. Exporting
> mpol_new() may be avoided by not using a policy. If we are just doing
> a round robin over a nodemask then this may be done in a different
> way.

How about this -- I'll respin this patch to keep the 'custom'
interleaving in hugetlb.c, while we discuss how best to do interleaving
independent of a process (which is really the issue at hand here, I
think).

That will affect the other patches, too, so I'll rebase them and
resubmit.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
