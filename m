In-reply-to: <1175765760.6483.93.camel@twins> (message from Peter Zijlstra on
	Thu, 05 Apr 2007 11:36:00 +0200)
Subject: Re: [patch 2/2] only allow nonlinear vmas for ram backed
	filesystems
References: <E1HZOHe-0000RL-00@dorka.pomaz.szeredi.hu>
	 <E1HZOIr-0000Rv-00@dorka.pomaz.szeredi.hu> <1175765760.6483.93.camel@twins>
Message-Id: <E1HZORc-0000UZ-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 05 Apr 2007 11:39:52 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > +		/*
> > +		 * page_mkclean doesn't work on nonlinear vmas, so if dirty
> > +		 * pages need to be accounted, emulate with linear vmas.
> > +		 */
> > +		if (mapping_cap_account_dirty(mapping)) {
> 
> Perhaps this should read:
> 
> 		if (vma_wants_writenotify(vma)) {
> 

I looked at that, but IIRC vma_wants_writenotify() doesn't work after
mmap(), because of the updated protection bits.

> That way we would even allow read only non-linear mappings of 'real'
> filesystem files.

Well, we could do that, but is it really worth the hassle?  The real
question is whether anyone would want to use non-linear
shared-read-only mappings or not.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
