Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7486C6B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 14:54:14 -0400 (EDT)
Date: Tue, 6 Oct 2009 20:53:44 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v2][RFC] add MAP_UNLOCKED mmap flag
Message-ID: <20091006185344.GA19692@redhat.com>
References: <20091006170218.GM9832@redhat.com>
 <20091006183436.GA23110@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091006183436.GA23110@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 06, 2009 at 08:34:36PM +0200, Johannes Weiner wrote:
> On Tue, Oct 06, 2009 at 07:02:18PM +0200, Gleb Natapov wrote:
> > diff --git a/include/asm-generic/mman.h b/include/asm-generic/mman.h
> > index 32c8bd6..59e0f29 100644
> > --- a/include/asm-generic/mman.h
> > +++ b/include/asm-generic/mman.h
> > @@ -12,6 +12,7 @@
> >  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
> >  #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
> >  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> > +#define MAP_UNLOCKED	0x80000         /* force page unlocking */
> >  
> >  #define MCL_CURRENT	1		/* lock all current mappings */
> >  #define MCL_FUTURE	2		/* lock all future mappings */
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 73f5e4b..7c2abdb 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -985,6 +985,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
> >  		if (!can_do_mlock())
> >  			return -EPERM;
> >  
> > +        if (flags & MAP_UNLOKED)
> > +                vm_flags &= ~VM_LOCKED;
> 
> That needs changing into MAP_UNLOCKED as well.
> 
That's for editing patch manually :(

> Should we do something special about (MAP_UNLOCKED | MAP_LOCKED)?
It is simpler to just ignore it. What do you think?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
