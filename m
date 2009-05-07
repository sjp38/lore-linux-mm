Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1B41E6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 22:41:35 -0400 (EDT)
Date: Wed, 6 May 2009 22:41:29 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Message-ID: <20090506224129.242ce9e2@riellaptop.surriel.com>
In-Reply-To: <20090506235949.GC16870@x200.localdomain>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
	<1241475935-21162-2-git-send-email-ieidus@redhat.com>
	<1241475935-21162-3-git-send-email-ieidus@redhat.com>
	<1241475935-21162-4-git-send-email-ieidus@redhat.com>
	<4A00DF9B.1080501@redhat.com>
	<4A014C7B.9080702@redhat.com>
	<Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
	<4A01AC5E.6000906@redhat.com>
	<Pine.LNX.4.64.0905061706590.4005@blonde.anvils>
	<4A01C1AD.9060802@redhat.com>
	<20090506235949.GC16870@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009 16:59:49 -0700
Chris Wright <chrisw@redhat.com> wrote:

> * Izik Eidus (ieidus@redhat.com) wrote:
> > Ok, i give up, lets move to madvice(), i will write a patch that
> > move the whole thing into madvice after i finish here something,
> > but that ofcurse only if Andrea agree for the move?
> 
> Here's where I left off last time (refreshed against a current mmotm).
> 
> It needs to get converted to vma rather than still scanning via slots.
> It's got locking issues (I think this can be remedied w/ vma
> conversion).  I think the scan list would be ->mm and each ->mm we'd
> scan the vma's that are marked VM_MERGEABLE or whatever.

Doing that kind of scan would be useful for other reasons,
too.

For example, it is not uncommon for large database systems
to end up having half of system memory in page tables
occasionally, which can drive the system to swapping.

Reclaiming some of those (file pte only) page tables would
be a relatively simple thing to do and could really save
such systems from the occasional swap disaster.

The subsequent minor faults would be expensive, but not
nearly as badly as swap disk IO...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
