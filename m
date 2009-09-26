Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E0A7A6B0055
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 17:32:06 -0400 (EDT)
Date: Sat, 26 Sep 2009 23:32:04 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090926213204.GX30185@one.firstfloor.org>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils> <20090926190645.GB14368@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090926190645.GB14368@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> This is a bit tricky to do right now; you have a chicken and egg
> problem between locking the page and pinning the inode mapping.

One possibly simple solution would be to just allocate the page
locked (GFP_LOCKED). When the allocator clears the flags it already
modifies the state, so it could as well set the lock bit too. No
atomics needed.  And then clearing it later is also atomic free.

Would that satisfy the concerns?

Again another way is to just ignore it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
