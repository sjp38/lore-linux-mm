Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9RF0lqg000616
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 11:00:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9RF0l4g504472
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 09:00:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9RF0hki018597
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 09:00:43 -0600
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051027131725.GI5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <200510271038.52277.ak@suse.de>  <20051027131725.GI5091@opteron.random>
Content-Type: text/plain
Date: Thu, 27 Oct 2005 08:00:12 -0700
Message-Id: <1130425212.23729.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Jeff Dike <jdike@addtoit.com>, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-10-27 at 15:17 +0200, Andrea Arcangeli wrote:
> On Thu, Oct 27, 2005 at 10:38:51AM +0200, Andi Kleen wrote:
> > On Thursday 27 October 2005 00:49, Badari Pulavarty wrote:
> > 
> > >
> > > I would really appreciate your comments on my approach.
> > 
> > (from a high level point of view) It sounds very scary. Traditionally
> > a lot of code had special case handling to avoid truncate
> > races, and it might need a lot of auditing to make sure
> > everybode else can handle arbitary punch hole too.
> 
> -ENOSYS is returned for all fs but tmpfs (the short term big need of
> this feature). so as long as tmpfs works and -ENOSYS is returned to the
> other fs, complexity should remain reasonably low, and for the long term
> the API sounds nicer than a local tmpfs hack like MADV_DISCARD.
> 
> Patch looks good to me, thanks Baudari for taking care of this!
> 
> I'll try to give it some testing and I'll let you know if I run into
> troubles.

Thank you for taking a look at it. I am hoping this would satisfy
Jeff's UML requirement too.

BTW, my initial testing found no bugs so far - thats why I am scared :(
But again, I am sure my testing is not covering cases where shared 
memory segments got swapped out. I need to do a closer audit to make
sure that I am indeed freeing up all the swap entries.

And also, I am not sure we should allow using this interface for
truncating up. 

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
