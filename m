Date: Thu, 28 Jun 2007 18:39:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <1183038137.5697.16.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
 <1182968078.4948.30.camel@localhost>  <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
  <200706280001.16383.ak@suse.de> <1183038137.5697.16.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007, Lee Schermerhorn wrote:

> Avoid the taking the reference count on the system default policy or the
> current task's task policy.  Note that if show_numa_map() is called from
> the context of a relative of the target task with the same task mempolicy,
> we won't take an extra reference either.  This is safe, because the policy
> remains referenced by the calling task during the mpol_to_str() processing.

I still do not see the rationale for this patchset. This adds more special 
casing. So if we have a vma policy then we suck again?

This all still falls under the category of messing up a bad situation even 
more. Its first necessary to come up with way to consistently handle 
memory policies and improve the interaction with other methods to 
constrain allocations (cpusets, node restrictions for hugetlb etc etc). It 
should improve the situation and not increase special casing or make the 
system more unpreditable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
