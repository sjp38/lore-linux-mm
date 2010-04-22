Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CF6E26B01EF
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 02:04:43 -0400 (EDT)
Date: Thu, 22 Apr 2010 15:03:47 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [BUG] rmap: fix page_address_in_vma() to walk through
 anon_vma_chain
Message-ID: <20100422060347.GA10601@spritzerA.linux.bs1.fc.nec.co.jp>
References: <20100422054241.GB10957@spritzerA.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100422054241.GB10957@spritzerA.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

>                            mmap_sem      page_table_lock
>   mm/ksm.c:
>     write_protect_page()   hold          not hold
>     replace_page()         hold          not hold
>   mm/memory-failure.c:
>     add_to_kill()          not hold      hold
                                           ^^^^
Sorry, I misread here. This is "not hold".

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
