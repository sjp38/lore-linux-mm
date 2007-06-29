From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
Date: Fri, 29 Jun 2007 11:01:40 +0200
References: <20070625195224.21210.89898.sendpatchset@localhost> <1183038137.5697.16.camel@localhost> <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706291101.41081.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Friday 29 June 2007 03:39:52 Christoph Lameter wrote:
> On Thu, 28 Jun 2007, Lee Schermerhorn wrote:
> 
> > Avoid the taking the reference count on the system default policy or the
> > current task's task policy.  Note that if show_numa_map() is called from
> > the context of a relative of the target task with the same task mempolicy,
> > we won't take an extra reference either.  This is safe, because the policy
> > remains referenced by the calling task during the mpol_to_str() processing.
> 
> I still do not see the rationale for this patchset. This adds more special 
> casing. 

The reference count change at least is a good idea.

> So if we have a vma policy then we suck again? 

An additional reference count inc/dec is not exactly "suck". We try to 
avoid it because it's a little slow on some obsolete CPUs we support, but
even on those it is not that bad and will probably only show up
in extreme microbenchmarking. Still it's normally good to avoid
making the default path slower.

> 
> This all still falls under the category of messing up a bad situation even 
> more.

I think you're exaggerating.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
