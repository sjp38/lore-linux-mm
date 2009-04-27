Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DA4176B00CF
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 18:38:49 -0400 (EDT)
Date: Mon, 27 Apr 2009 15:34:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] add ksm kernel shared memory driver.
Message-Id: <20090427153421.2682291f.akpm@linux-foundation.org>
In-Reply-To: <1240191366-10029-6-git-send-email-ieidus@redhat.com>
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com>
	<1240191366-10029-2-git-send-email-ieidus@redhat.com>
	<1240191366-10029-3-git-send-email-ieidus@redhat.com>
	<1240191366-10029-4-git-send-email-ieidus@redhat.com>
	<1240191366-10029-5-git-send-email-ieidus@redhat.com>
	<1240191366-10029-6-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, 20 Apr 2009 04:36:06 +0300
Izik Eidus <ieidus@redhat.com> wrote:

> Ksm is driver that allow merging identical pages between one or more
> applications in way unvisible to the application that use it.
> Pages that are merged are marked as readonly and are COWed when any
> application try to change them.

Breaks sparc64 and probably lots of other architectures:

mm/ksm.c: In function `try_to_merge_two_pages_alloc':
mm/ksm.c:697: error: `_PAGE_RW' undeclared (first use in this function)

there should be an official arch-independent way of manipulating
vma->vm_page_prot, but I'm not immediately finding it.

An alternative (and quite inferior) "fix" would be to disable ksm on
architectures which don't implement _PAGE_RW.  That's most of them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
