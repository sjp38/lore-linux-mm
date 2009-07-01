Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AAEEA6B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 17:17:54 -0400 (EDT)
Date: Wed, 1 Jul 2009 14:17:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/3] hugetlb:  add nodemask arg to huge page alloc, free
 and surplus adjust fcns
Message-Id: <20090701141750.0e5d8066.akpm@linux-foundation.org>
In-Reply-To: <1246453238.23497.21.camel@lts-notebook>
References: <20090630154716.1583.25274.sendpatchset@lts-notebook>
	<20090630154724.1583.55926.sendpatchset@lts-notebook>
	<20090701123830.GE16355@csn.ul.ie>
	<1246453238.23497.21.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, linux-numa@vger.org, nacc@us.ibm.com, rientjes@google.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 01 Jul 2009 09:00:38 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> > I strongly suspect that the same node being used until allocation
> > failure instead of round-robin is an oversight and not deliberate at
> > all. I can't think of a good reason for boot-allocation to behave
> > significantly different to runtime-allocation.
> > 
> > This could be a seperate patch just for consideration in isolation but I
> > for one have no problem with it. If you split out this patch, feel free
> > to add an Ack from me.
> 
> OK.  If this series doesn't fly--e.g., we take another approach--I will
> definitely split this out.  If Andrew wants it separate for the change
> log, I can do that as well.

Can't be bothered, really.  If you think the fix might be useful to
someone running a 2.6.31 or earlier kernel then yes, it would be polite
to split out a minimal backportable fix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
