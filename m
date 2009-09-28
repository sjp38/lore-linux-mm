Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A84976B009F
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:23:04 -0400 (EDT)
Date: Mon, 28 Sep 2009 04:57:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090928025741.GI6327@wotan.suse.de>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils> <20090926190645.GB14368@wotan.suse.de> <20090926213204.GX30185@one.firstfloor.org> <Pine.LNX.4.64.0909271714370.9097@sister.anvils> <20090927192251.GB6327@wotan.suse.de> <Pine.LNX.4.64.0909272251180.4402@sister.anvils> <20090927230118.GH6327@wotan.suse.de> <20090928011943.GB1656@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090928011943.GB1656@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 28, 2009 at 03:19:43AM +0200, Andi Kleen wrote:
> > There is no real rush AFAIKS to fix this one single pagecache site
> > while we have problems with slab allocators and all other unaudited
> > places that nonatomically modify page flags with an elevated
> 
> hwpoison ignores slab pages.

"ignores" them *after* it has already written to page flags?
By that time it's too late.

 
> > page reference ... just mark HWPOISON as broken for the moment, or
> > cut it down to do something much simpler I guess?
> 
> Erm no. These cases are *EXTREMLY* unlikely to hit.

Well it's fundamentally badly buggy, rare or not. We could avoid
lots of nasty atomic operations if we just care that it works
most of the time. I guess it's a matter of perspective but I
won't push for one thing or the other in hwpoison code so long
as it stays out of core code for the most part.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
