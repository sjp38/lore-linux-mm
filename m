Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A40426B005A
	for <linux-mm@kvack.org>; Wed,  6 May 2009 12:51:20 -0400 (EDT)
Date: Wed, 6 May 2009 17:36:51 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
In-Reply-To: <20090506161424.GC15712@x200.localdomain>
Message-ID: <Pine.LNX.4.64.0905061732220.5775@blonde.anvils>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com>
 <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com>
 <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
 <4A01AC5E.6000906@redhat.com> <20090506161424.GC15712@x200.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Chris Wright wrote:
> 
> There's already locking issues w/ using madvise and ksm, so yes,
> changes would need to be made.  Some question of how (whether) to handle
> registration of unmapped ranges, closest to say ->mm->def_flags=VM_MERGE.
> My hunch is there's 2 cases users might care about, a specific range
> (qemu-kvm, CERN app, etc) or the entire vma space of a process.

Good food for thought there, but not on my mind at this moment.

> Another
> question of what to do w/ VM_LOCKED, should that exclude VM_MERGE or
> let user get what asked for?

What's the issue with VM_LOCKED?  We wouldn't want to merge a page
while it was under get_user_pages (unless KSM's own, but ignore that),
but what's the deal with VM_LOCKED?

Is the phrase "covert channel" going to come up somehow?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
