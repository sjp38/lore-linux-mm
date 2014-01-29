Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id DB55D6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 18:00:44 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so2361605pbc.36
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 15:00:44 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id tq3si4153566pab.125.2014.01.29.15.00.43
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 15:00:43 -0800 (PST)
Message-ID: <1391036440.2181.52.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] persistent transparent large
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 29 Jan 2014 15:00:40 -0800
In-Reply-To: <20140129023903.GF20939@parisc-linux.org>
References: <alpine.LSU.2.11.1401230334110.1414@eggly.anvils>
	 <20140128193833.GD20939@parisc-linux.org>
	 <1390943052.16253.31.camel@dabdike>
	 <20140129023903.GF20939@parisc-linux.org>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Hugh Dickins <hughd@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue, 2014-01-28 at 19:39 -0700, Matthew Wilcox wrote:
> On Tue, Jan 28, 2014 at 01:04:12PM -0800, James Bottomley wrote:
> > That rather depends on whether you think Execute In Place is the correct
> > way to handle persistent memory, I think?  I fully accept that it looks
> > like a good place to start since it's how all embedded systems handle
> > flash ... although looking at the proliferation of XIP hacks and
> > filesystems certainly doesn't give one confidence that they actually got
> > it right.
> 
> One of the things I don't like about the current patch is that XIP
> has two completely unrelated meanings.  The embedded people use it
> for eXecuting the kernel in-place, whereas the CONFIG_FS_XIP code is
> all about avoiding the page cache (for both executables and data).
> I'd love to rename it to prevent this confusion ... I just have no idea
> what to call it.  Somebody suggested Map In Place (MIP).  Maybe MAXIP
> (Map And eXecute In Place)?  I'd rather something that was a TLA though.

I understand; essentially it's about inserting existing pages into the
page cache as mappings.  Curiously it's not unlike one of the user space
APIs the database people have requested.

> > Fixing XIP looks like a good thing independent of whether it's the right
> > approach for persistent memory.  However, one thing that's missing for
> > the current patch sets is any buy in from the existing users ... can
> > they be persuaded to drop their hacks and adopt it (possibly even losing
> > some of the XIP specific filesystems), or will this end up as yet
> > another XIP hack?
> 
> There's only one in-tree filesystem using the current interfaces (ext2)
> and it's converted as part of the patchset.  And there're only three
> devices drivers implementing the current interface (dcssblk, axonram
> and brd).  The MTD XIP is completely unrelated to this, and doesn't need
> to be converted.

Quite a few of the MTD XIP patches have been *application* not kernel;
those should be convertible to your patches.

> > Then there's the meta problem of is XIP the right approach.  Using
> > persistence within the current memory address space as XIP is a natural
> > fit for mixed volatile/NV systems, but what happens when they're all NV
> > memory?  Should we be discussing some VM based handling mechanisms for
> > persistent memory?
> 
> I think this discussion would be more related to checkpointing than it
> is VM, so we probably wouldn't have the right people in the room for that.
> It would probably have been a good discussion to have at kernel summit.

Actually, since all the checkpointing guys are mad russians and mostly
happen to work for Parallels I can see whom I can provide (I was
planning to poke them with a big stick to attend, anyway).


James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
