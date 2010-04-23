Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D00A6B01EE
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 22:09:58 -0400 (EDT)
Date: Fri, 23 Apr 2010 11:06:32 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [BUG] rmap: fix page_address_in_vma() to walk through
 anon_vma_chain
Message-ID: <20100423020632.GA7383@spritzerA.linux.bs1.fc.nec.co.jp>
References: <20100422054241.GB10957@spritzerA.linux.bs1.fc.nec.co.jp>
 <4BD0688A.7050806@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <4BD0688A.7050806@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> However, for anonymous pages, page_address_in_vma only
> ever determined whether the page _could_ be part of the
> VMA, never whether it actually was.
>
> The function page_address_in_vma has always given
> false positives, which means all of the callers already
> check that the page is actually part of the process.

I see.

> This means we may be able to get away with not verifying
> the anon_vma at all.  After all, verifying that the VMA
> has the anon_vma mapped does not mean the VMA has this
> page...
> 
> Doing away with that check gets rid of your locking
> conundrum :)

I get it, thank you :)
I'll rewrite fix patch based on your comments.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
