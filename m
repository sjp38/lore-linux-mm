Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AAC216B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 12:56:54 -0400 (EDT)
Date: Thu, 11 Jun 2009 17:57:47 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 0/4] RFC - ksm api change into madvise
In-Reply-To: <20090610092855.43be2405@woof.tlv.redhat.com>
Message-ID: <Pine.LNX.4.64.0906111700390.18609@sister.anvils>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
 <Pine.LNX.4.64.0906081555360.22943@sister.anvils> <4A2D47C1.5020302@redhat.com>
 <Pine.LNX.4.64.0906081902520.9518@sister.anvils> <4A2D7036.1010800@redhat.com>
 <20090609074848.5357839a@woof.tlv.redhat.com> <Pine.LNX.4.64.0906091807300.20120@sister.anvils>
 <Pine.LNX.4.64.0906092013580.31606@sister.anvils> <20090610092855.43be2405@woof.tlv.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jun 2009, Izik Eidus wrote:
> 
> Great!, what you think about below?

A couple of things: please use #ifdef CONFIG_KSM throughout
now that you can, rather than #if defined(CONFIG_KSM).

And we ought to add a comment above the write_protect_page() call:
	/*
	 * If this anonymous page is mapped only here, its pte may need
	 * to be write-protected.  If it's mapped elsewhere, all its
	 * ptes are necessarily already write-protected.  In either
	 * case, we need to lock and check page_count is not raised.
	 */

> another thing we want to add or to start sending it to Andrew?

Umm, umm, umm, let's hold off sending Andrew for now.  It would be
a bit silly to send him 2/2, when what's actually required is to
withdraw ksm-add-page_wrprotect-write-protecting-page.patch,
providing adjustments as necessary to the other patches.

But I don't want us fiddling with Andrew's collection every day
or two (forget my earlier scan fix if you prefer, if you're sure
you caught all of that in what you have now); and I rather doubt
mmotm's KSM is getting much testing at present.  It would be nice
to get the withdrawn rmap.c changes out of everybody else's face,
but not worth messing mmotm around for that right now.

Whilst we can't let our divergence drift on very long, I think
it's better we give him a new collection of patches once we've
more or less settled the madvise switchover.  That new collection
won't contain much in mm/rmap.c if at all.

Unless you or Andrew feel strongly that I'm wrong on this.

> 
> btw may i add your signed-off to this patch?

If you've tested and found it works, please, by all means.
If you've not tested, or found it broken, then I deny all
knowledge of these changes ;)  But it's hypothetical: the
replacement collection to Andrew won't contain either of
these patches as such.

> (the only thing that i changed was taking down the *orig_pte = *ptep,
> so we will merge write_protected pages, and add orig_pte = __pte(0) to
> avoid annoying warning message about being used uninitialized)

Okay.  We do have a macro to annotate such pacifying initializations,
but I've not used it before, and forget what it is or where to look
for an example, I don't see it in kernel.h or compiler.h.  Maybe
Andrew will chime in and remind us.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
