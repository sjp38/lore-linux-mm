Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 148AF6007DB
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 09:03:15 -0500 (EST)
Date: Wed, 2 Dec 2009 15:03:05 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 12/24] HWPOISON: make it possible to unpoison pages
Message-ID: <20091202140305.GL18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043045.150526892@intel.com> <20091202131530.GG18989@one.firstfloor.org> <20091202134645.GA19274@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202134645.GA19274@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> btw, do you feel comfortable with the interface name "renew-pfn"?
> (versus "unpoison-pfn")

I prefer unpoison, that makes it clear what it is.

Maybe even call it "software_unpoison_pfn", because it won't unpoison on the 
hardware level (this really should be documented somewhere too)

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
