Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 222846B005C
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 15:27:35 -0400 (EDT)
Date: Thu, 2 Apr 2009 20:27:21 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 0/6] Guest page hinting version 7.
In-Reply-To: <20090402175249.3c4a6d59@skybase>
Message-ID: <Pine.LNX.4.64.0904022016180.29625@blonde.anvils>
References: <20090327150905.819861420@de.ibm.com> <200903281705.29798.rusty@rustcorp.com.au>
 <20090329162336.7c0700e9@skybase> <200904022232.02185.nickpiggin@yahoo.com.au>
 <20090402175249.3c4a6d59@skybase>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Rusty Russell <rusty@rustcorp.com.au>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, akpm@osdl.org, frankeh@watson.ibm.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 2 Apr 2009, Martin Schwidefsky wrote:
> On Thu, 2 Apr 2009 22:32:00 +1100
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> > I still think this needs much more justification.
>  
> Ok, I can understand that. We probably need a KVM based version to show
> that benefits exist on non-s390 hardware as well.

That would indeed help your cause enormously (I think I made the same
point last time).  All these complex transitions, added to benefit only
an architecture to which few developers have access, asks for trouble -
we mm hackers already get caught out often enough by your
too-well-camouflaged page_test_dirty().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
