Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFB56B0055
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 11:05:56 -0400 (EDT)
Date: Sat, 26 Sep 2009 17:05:55 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090926150555.GM30185@one.firstfloor.org>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils> <20090926114806.GA12419@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090926114806.GA12419@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> However we may well end up to accept the fact that "we just cannot do
> hwpoison 100% correct", and settle with a simple and 99% correct code.

I would prefer to avoid any oopses, but if they are unlikely enough
and too hard to fix that's bearable. The race window here is certainly rather 
small. 

On the other hand if you cannot detect a difference in benchmarks I see
no reason not to add the additional steps, as long as the code isn't
complicated or ugly. These changes are neither.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
