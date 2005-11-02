From: Rob Landley <rob@landley.net>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Date: Wed, 2 Nov 2005 17:47:44 -0600
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com> <436888E7.1060609@yahoo.com.au>
In-Reply-To: <436888E7.1060609@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511021747.45599.rob@landley.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Gerrit Huizenga <gh@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wednesday 02 November 2005 03:37, Nick Piggin wrote:
> > So do you see the problem with fragementation if the hypervisor is
> > handing out, say, 1 MB pages?  Or, more likely, something like 64 MB
> > pages?  What are the chances that an entire 64 MB page can be freed
> > on a large system that has been up a while?
>
> I see the problem, but if you want to be able to shrink memory to a
> given size, then you must either introduce a hard limit somewhere, or
> have the hypervisor hand out guest sized pages. Use zones, or Xen?

In the UML case, I want the system to automatically be able to hand back any 
sufficiently large chunks of memory it currently isn't using.

What does this have to do with specifying hard limits of anything?  What's to 
specify?  Workloads vary.  Deal with it.

> If there are zone rebalancing problems[*], then it would be great to
> have more users of zones because then they will be more likely to get
> fixed.

Ok, so you want to artificially turn this into a zone balancing issue in hopes 
of giving that area of the code more testing when, if zones weren't involved, 
there would be no need for balancing at all?

How does that make sense?

> [*] and there are, sadly enough - see the recent patches I posted to
>      lkml for example.

I was under the impression that zone balancing is, conceptually speaking, a 
difficult problem.

>      But I'm fairly confident that once the particularly 
>      silly ones have been fixed,

Great, you're advocating migrating the fragmentation patches to an area of 
code that has known problems you yourself describe as "particularly silly".  
A ringing endorsement, that.

The fact that the migrated version wouldn't even address fragmentation 
avoidance at all (the topic of this thread!) is apparently a side issue.

>      zone balancing will no longer be a 
>      derogatory term as has been thrown around (maybe rightly) in this
>      thread!

If I'm not mistaken, you introduced zones into this thread, you are the 
primary (possibly only) proponent of them.  Yes, zones are a way of 
categorizing memory.  They're not a way of defragmenting it.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
