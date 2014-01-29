Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 06B8E6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 21:39:06 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 19so5925065ykq.8
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 18:39:06 -0800 (PST)
Received: from mail.parisc-linux.org (palinux.external.hp.com. [192.25.206.14])
        by mx.google.com with ESMTPS id 69si620041yhc.116.2014.01.28.18.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 18:39:05 -0800 (PST)
Date: Tue, 28 Jan 2014 19:39:03 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] persistent transparent large
Message-ID: <20140129023903.GF20939@parisc-linux.org>
References: <alpine.LSU.2.11.1401230334110.1414@eggly.anvils> <20140128193833.GD20939@parisc-linux.org> <1390943052.16253.31.camel@dabdike>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390943052.16253.31.camel@dabdike>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Hugh Dickins <hughd@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue, Jan 28, 2014 at 01:04:12PM -0800, James Bottomley wrote:
> That rather depends on whether you think Execute In Place is the correct
> way to handle persistent memory, I think?  I fully accept that it looks
> like a good place to start since it's how all embedded systems handle
> flash ... although looking at the proliferation of XIP hacks and
> filesystems certainly doesn't give one confidence that they actually got
> it right.

One of the things I don't like about the current patch is that XIP
has two completely unrelated meanings.  The embedded people use it
for eXecuting the kernel in-place, whereas the CONFIG_FS_XIP code is
all about avoiding the page cache (for both executables and data).
I'd love to rename it to prevent this confusion ... I just have no idea
what to call it.  Somebody suggested Map In Place (MIP).  Maybe MAXIP
(Map And eXecute In Place)?  I'd rather something that was a TLA though.

> Fixing XIP looks like a good thing independent of whether it's the right
> approach for persistent memory.  However, one thing that's missing for
> the current patch sets is any buy in from the existing users ... can
> they be persuaded to drop their hacks and adopt it (possibly even losing
> some of the XIP specific filesystems), or will this end up as yet
> another XIP hack?

There's only one in-tree filesystem using the current interfaces (ext2)
and it's converted as part of the patchset.  And there're only three
devices drivers implementing the current interface (dcssblk, axonram
and brd).  The MTD XIP is completely unrelated to this, and doesn't need
to be converted.

> Then there's the meta problem of is XIP the right approach.  Using
> persistence within the current memory address space as XIP is a natural
> fit for mixed volatile/NV systems, but what happens when they're all NV
> memory?  Should we be discussing some VM based handling mechanisms for
> persistent memory?

I think this discussion would be more related to checkpointing than it
is VM, so we probably wouldn't have the right people in the room for that.
It would probably have been a good discussion to have at kernel summit.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
