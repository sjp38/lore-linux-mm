From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2/2] Fold numa_maps into mempolicy.c
Date: Wed, 16 Nov 2005 09:36:04 +0100
References: <Pine.LNX.4.62.0511081520540.32262@schroedinger.engr.sgi.com> <Pine.LNX.4.62.0511081524570.32262@schroedinger.engr.sgi.com> <20051115231051.5437e25b.pj@sgi.com>
In-Reply-To: <20051115231051.5437e25b.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511160936.04721.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 16 November 2005 08:10, Paul Jackson wrote:
> Christoph wrote:
> > + * Must hold mmap_sem until memory pointer is no longer in use
> > + * or be called from the current task.
> > + */
> > +struct mempolicy *get_vma_policy(struct task_struct *task,
> 
> Twenty (well, four) questions time.
> 
> Hmmm ... is that true - that get_vma_policy() can be called for the
> current task w/o holding mmap_sem?

Yes, e.g. when vma is NULL.

> Is there any call to get_vma_policy() made that isn't holding mmap_sem?

There are some callers of alloc_page_vma with NULL vma yes

> Except for /proc output, is there any call to get_vma_policy made on any
> task other than current?

In the original version there wasn't any. I still think it's a mistake
to allow it for /proc, unfortunately the patch went in.

> What does "until memory pointer is no longer in use" mean?

mempolicy is no longer in use or you took a reference.


-Andi
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
