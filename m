Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CDC426B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 18:24:58 -0400 (EDT)
Date: Thu, 13 Oct 2011 00:24:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/huge_memory: Clean up typo when copying user highpage
Message-ID: <20111012222454.GA3218@redhat.com>
References: <CAJd=RBBuwmcV8srUyPGnKUp=RPKvsSd+4BbLrh--aHFGC5s7+g@mail.gmail.com>
 <20111012175148.GA27460@redhat.com>
 <20111012134224.786191ac.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111012134224.786191ac.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Oct 12, 2011 at 01:42:24PM -0700, Andrew Morton wrote:
> On Wed, 12 Oct 2011 19:51:48 +0200
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > On Wed, Oct 12, 2011 at 10:39:36PM +0800, Hillf Danton wrote:
> > > Hi Andrea
> > > 
> > > When copying user highpage, the PAGE_SHIFT in the third parameter is a typo,
> > > I think, and is replaced with PAGE_SIZE.
> > 
> > That looks correct. I wonder how it was not noticed yet. Because it
> > can't go out of bound, it didn't risk to crash the kernel and it didn't
> > not risk to expose random data to the cowing task. So it shouldn't
> > have security implications as far as I can tell, but the app could
> > malfunction and crash (userland corruption only).
> 
> Which architectures care about the copy_user_page() `vaddr' argument? 
> mips, perhaps?  I suspect the intersection between those architectures
> and archs-which-implement-hugepages is the empty set.

Yes it's not happening. debug_cow was specifically meant to trap this
very case so there was little chance it could go unnoticed.

Never mind.... still the patch is correct and good idea to apply as cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
