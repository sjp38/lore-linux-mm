Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 272E76B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:42:04 -0500 (EST)
Date: Thu, 10 Dec 2009 14:42:00 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [19/31] mm: export stable page flags
Message-ID: <20091210134200.GP18989@one.firstfloor.org>
References: <200912081016.198135742@firstfloor.org> <20091208211635.7965AB151F@basil.firstfloor.org> <1260311251.31323.129.camel@calx> <20091209020042.GA7751@localhost> <20091210015014.GK18989@one.firstfloor.org> <20091210020927.GA11017@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091210020927.GA11017@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Your original patch didn't handle hwpoison as module btw.
> 
> Yes I realized it later..

It's always a big trap, I've seen lots of people (including myself)
run into it.

I preferred to not have the ifdefs in the core module, simply
because it's very little additional code.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
