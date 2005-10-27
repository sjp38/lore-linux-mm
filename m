Date: Thu, 27 Oct 2005 15:17:25 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051027131725.GI5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200510271038.52277.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Jeff Dike <jdike@addtoit.com>, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 10:38:51AM +0200, Andi Kleen wrote:
> On Thursday 27 October 2005 00:49, Badari Pulavarty wrote:
> 
> >
> > I would really appreciate your comments on my approach.
> 
> (from a high level point of view) It sounds very scary. Traditionally
> a lot of code had special case handling to avoid truncate
> races, and it might need a lot of auditing to make sure
> everybode else can handle arbitary punch hole too.

-ENOSYS is returned for all fs but tmpfs (the short term big need of
this feature). so as long as tmpfs works and -ENOSYS is returned to the
other fs, complexity should remain reasonably low, and for the long term
the API sounds nicer than a local tmpfs hack like MADV_DISCARD.

Patch looks good to me, thanks Baudari for taking care of this!

I'll try to give it some testing and I'll let you know if I run into
troubles.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
