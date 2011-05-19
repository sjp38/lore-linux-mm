Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B7C7B8D003B
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:19:13 -0400 (EDT)
Subject: Re: [PATCH] kernel buffer overflow kmalloc_slab() fix
From: J Freyensee <james_p_freyensee@linux.intel.com>
Reply-To: james_p_freyensee@linux.intel.com
In-Reply-To: <alpine.DEB.2.00.1105191618460.12530@router.home>
References: <james_p_freyensee@linux.intel.com>
	 <1305834712-27805-2-git-send-email-james_p_freyensee@linux.intel.com>
	 <alpine.DEB.2.00.1105191550001.12530@router.home>
	 <1305839647.2400.32.camel@localhost>
	 <alpine.DEB.2.00.1105191618460.12530@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 19 May 2011 15:19:12 -0700
Message-ID: <1305843552.2400.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, gregkh@suse.de, hari.k.kanigeri@intel.com

On Thu, 2011-05-19 at 16:24 -0500, Christoph Lameter wrote:
> On Thu, 19 May 2011, J Freyensee wrote:
> 
> > On Thu, 2011-05-19 at 15:51 -0500, Christoph Lameter wrote:
> > > On Thu, 19 May 2011, james_p_freyensee@linux.intel.com wrote:
> > >
> > > > From: J Freyensee <james_p_freyensee@linux.intel.com>
> > > >
> > > > Currently, kmalloc_index() can return -1, which can be
> > > > passed right to the kmalloc_caches[] array, cause a
> > >
> > > No kmalloc_index() cannot return -1 for the use case that you are
> > > considering here. The value passed as a size to
> > > kmalloc_slab is bounded by 2 * PAGE_SIZE and kmalloc_slab will only return
> > > -1 for sizes > 4M. So we will have to get machines with page sizes > 2M
> > > before this can be triggered.
> > >
> > >
> >
> > Okay.  I thought it would still be good to check for -1 anyways, even if
> > machines today cannot go above 2M page sizes.  I would think it would be
> > better for software code to always make sure a case that this could
> > never happen instead of relying on whatever physical hardware limits the
> > linux kernel could be running on on today's machines or future machines,
> > because technology has shown limits can change.  I would think
> > regardless what this code runs on, this is still a software flaw that
> > can be considered not a good thing to allow lying around in software
> > code that can easily be fixed.
> 
> This is basically macro style code that is mostly folded at compile time
> and we have to obey certain restrictions to convince the compiler to
> properly do that. Took us a long time to get that right.
> 
> Not sure what to do instead of returning -1 in kmalloc_slab. 

I think returning -1 is fine; I just think code using the function
should be checking for it and protect itself for errors in kernel space.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
