Date: Fri, 29 Jun 2007 13:15:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <1183138909.5012.40.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706291309050.17407@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
 <1183038137.5697.16.camel@localhost>  <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
  <200706291101.41081.ak@suse.de>  <Pine.LNX.4.64.0706290649480.14268@schroedinger.engr.sgi.com>
 <1183138909.5012.40.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jun 2007, Lee Schermerhorn wrote:

> As I've said before, we can DO that, if you think it's needed.  E.g., we
> can require write access to a file in order to install a shared policy.
> Probably a good idea anyway.  Processes that have write access to a
> shared, mmap()ed file BETTER be cooperating.

They currently do not do that.

> Mapped shared file policy is off by default.  Documentation explain the
> implications of turning on for applications that share mapped files
> between cpusets.  We need to do this anyway, for shmem.  How many bug
> reports have you seen from this scenario for shmem segments which behave
> exactly the same?

I think about 7 or so shmem related that were escalated to our team? We 
put in the policy specification for shmem on the kernel command line for a 
reason. You boot the kernel with the policy you want shmem to have and 
tell all other people that may attempt to set a policy on shmem to stay 
the *** away from it.

> Do the bug reports specify whether the mapping is for private or shared
> mappings?  VMA policies ARE applied to page cache pages of private
> mappings if the process COWs the page.   For shared mappings, if we used

Yes but not if the proccess simply reads the page and that is the simple 
case that could be fixed by passing the policy to page_cache_alloc() 
without weird shared sematics on volatile memory objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
