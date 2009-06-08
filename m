Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B0C76B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 17:09:10 -0400 (EDT)
Date: Mon, 8 Jun 2009 22:05:51 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH mmotm] ksm: stop scan skipping pages
In-Reply-To: <4A2D70BF.9090605@redhat.com>
Message-ID: <Pine.LNX.4.64.0906082204170.23054@sister.anvils>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
 <Pine.LNX.4.64.0906081555360.22943@sister.anvils> <Pine.LNX.4.64.0906081733390.7729@sister.anvils>
 <4A2D4D9F.8080103@redhat.com> <Pine.LNX.4.64.0906081852540.8764@sister.anvils>
 <4A2D70BF.9090605@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jun 2009, Izik Eidus wrote:
> Hugh Dickins wrote:
> >
> > By the time Andrew sends KVM to Linus, it shouldn't be the
> > patches currently in mmotm with more on top: 
> 
> So you want a repost of all the patchs?

Will do eventually.  In the same way that Andrew merges fixes to
patches into the patches before sending to Linus.  But in this
case, rather large pieces would vanish in such a process, plus it
would be unfair to expect Andrew to do that work; so it would
be better for you to submit replacements when we're ready.

> in that case any value to keep this
> stuff in Andrew tree right now?

I guess that depends on whether it's actually receiving any
testing or review while it's in there.  I'm happy for it to remain
there for now - and the core of it is going to remain unchanged
or only trivially changed.  Really a matter for you to decide
with Andrew: I don't want to pull it out of circulation myself.

> Wouldnt it speed our development if we will keep it outside,
> and then repost the whole thing?

I don't see that having a version there in mmotm will slow us
down (what could slow me down more than myself ;-?).  But you
and Andrew are free to decide it's counterproductive to keep the
current version there, that's okay by me if you prefer to pull it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
