Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EB1B860021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 20:50:17 -0500 (EST)
Date: Thu, 10 Dec 2009 02:50:14 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [19/31] mm: export stable page flags
Message-ID: <20091210015014.GK18989@one.firstfloor.org>
References: <200912081016.198135742@firstfloor.org> <20091208211635.7965AB151F@basil.firstfloor.org> <1260311251.31323.129.camel@calx> <20091209020042.GA7751@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091209020042.GA7751@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Matt Mackall <mpm@selenic.com>, Andi Kleen <andi@firstfloor.org>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Sorry the stable_page_flags() will be undefined on
> !CONFIG_PROC_PAGE_MONITOR (it is almost always on,
> except for some embedded systems).
> 
> Currently the easy solution is to add a Kconfig dependency to
> CONFIG_PROC_PAGE_MONITOR.  When there comes more users (ie. some
> ftrace event), we can then always compile in stable_page_flags().

I decided to turn it into select instead.

Your original patch didn't handle hwpoison as module btw.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
