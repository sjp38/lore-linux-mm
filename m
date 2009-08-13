Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5806B0055
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 16:33:03 -0400 (EDT)
Date: Thu, 13 Aug 2009 22:32:59 +0200 (CEST)
From: Julia Lawall <julia@diku.dk>
Subject: Re: question about nommu.c
In-Reply-To: <20090813195738.GA8686@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0908132232350.7209@ask.diku.dk>
References: <Pine.LNX.4.64.0908132136540.7209@ask.diku.dk>
 <20090813195738.GA8686@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Aug 2009, Paul Mundt wrote:

> On Thu, Aug 13, 2009 at 09:41:38PM +0200, Julia Lawall wrote:
> > The function vmalloc_user in the file mm/nommu.c contains the following 
> > code:
> > 
> > struct vm_area_struct *vma;
> > ...
> > if (vma)
> >         vma->vm_flags |= VM_USERMAP;
> > 
> > The constant VM_USERMAP, however, is elsewhere used in a structure of type 
> > vm_struct, not vm_area_struct.  Furthermore, the value of VM_USERMAP is 8, 
> > which is the same as the value of VM_SHARED (define in mm.h), which is 
> > elsewhere used with a vm_area_struct structure.  Is this occurrence of 
> > VM_USERMAP correct?  Or should it be VM_SHARED?  Or should it be something 
> > else?
> > 
> Yes, this is currently broken, albeit generally harmless. I've been
> working on cleaning this up, but have not gotten around to posting
> patches yet.
> 
> Part of this requires building on top of the infrastructure we have in
> place with the vm_regions to layer a proper vmap implementation on top
> of, which should in turn restore some meaning to the vmlist and permit
> struct vm_struct to be used on nommu properly.
> 
> At the moment this is not a big problem as it doesn't really impact
> anything, it's more regarding future directions for the nommu memory
> management code.

OK, perhaps I should just let you clean it up in a more general way then.

julia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
