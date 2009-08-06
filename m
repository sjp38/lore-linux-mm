Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C82806B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 19:06:03 -0400 (EDT)
Subject: Re: [PATCH 2/2] Dirty page tracking & on-the-fly memory mirroring
From: Andi Kleen <andi@firstfloor.org>
References: <4A7393D9.50807@redhat.com>
Date: Fri, 07 Aug 2009 01:06:01 +0200
In-Reply-To: <4A7393D9.50807@redhat.com> (Jim Paradis's message of "Fri, 31 Jul 2009 21:01:13 -0400")
Message-ID: <87hbwkiluu.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Jim Paradis <jparadis@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jim Paradis <jparadis@redhat.com> writes:

> +#ifdef CONFIG_TRACK_DIRTY_PAGES
> +
> +#if PAGETABLE_LEVELS <= 3
> +static inline unsigned pud_index(unsigned long address)
> +{
> +    return 0;
> +}
> +#endif

Needing special code for different page table levels is a really bad
sign that it uses the wrong abstractions for page tables. It should be using
the standard page walk idioms or perhaps even walk_page_range() now

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
