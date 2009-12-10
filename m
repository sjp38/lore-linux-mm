Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0548860021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 21:09:31 -0500 (EST)
Date: Thu, 10 Dec 2009 10:09:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [19/31] mm: export stable page flags
Message-ID: <20091210020927.GA11017@localhost>
References: <200912081016.198135742@firstfloor.org> <20091208211635.7965AB151F@basil.firstfloor.org> <1260311251.31323.129.camel@calx> <20091209020042.GA7751@localhost> <20091210015014.GK18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091210015014.GK18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Matt Mackall <mpm@selenic.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 10, 2009 at 09:50:14AM +0800, Andi Kleen wrote:
> > Sorry the stable_page_flags() will be undefined on
> > !CONFIG_PROC_PAGE_MONITOR (it is almost always on,
> > except for some embedded systems).
> > 
> > Currently the easy solution is to add a Kconfig dependency to
> > CONFIG_PROC_PAGE_MONITOR.  When there comes more users (ie. some
> > ftrace event), we can then always compile in stable_page_flags().
> 
> I decided to turn it into select instead.

OK, that would be good.

> Your original patch didn't handle hwpoison as module btw.

Yes I realized it later..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
