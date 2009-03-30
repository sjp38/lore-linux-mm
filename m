Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D37296B003D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 14:37:38 -0400 (EDT)
Message-ID: <49D11184.3060002@goop.org>
Date: Mon, 30 Mar 2009 11:37:56 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<1238195024.8286.562.camel@nimitz>  <20090329161253.3faffdeb@skybase> <1238428495.8286.638.camel@nimitz>
In-Reply-To: <1238428495.8286.638.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, nickpiggin@yahoo.com.au, frankeh@watson.ibm.com, virtualization@lists.osdl.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> It also occurs to me that the hypervisor could be doing a lot of this
> internally.  This whole scheme is about telling the hypervisor about
> pages that we (the kernel) know we can regenerate.  The hypervisor
> should know a lot of that information, too.  We ask it to populate a
> page with stuff from virtual I/O devices or write a page out to those
> devices.  The page remains volatile until something from the guest
> writes to it.  The hypervisor could keep a record of how to recreate the
> page as long as it remains volatile and clean.
>   

That potentially pushes a lot of complexity elsewhere.  If you have 
multiple paths to a storage device, or a cluster store shared between 
multiple machines, then the underlying storage can change making the 
guest's copies of those blocks unbacked.  Obviously the host/hypervisor 
could deal with that, but it would be a pile of new mechanisms which 
don't necessarily exist (for example, it would have to be an active 
participant in a distributed locking scheme for a shared block device 
rather than just passing it all through to the guest to handle).

That said, people have been looking at tracking block IO to work out 
when it might be useful to try and share pages between guests under Xen.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
