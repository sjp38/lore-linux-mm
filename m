Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 403A86B0055
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 15:12:01 -0400 (EDT)
Date: Sat, 26 Sep 2009 21:12:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090926191201.GC14368@wotan.suse.de>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils> <20090926114806.GA12419@localhost> <20090926150555.GM30185@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090926150555.GM30185@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 26, 2009 at 05:05:55PM +0200, Andi Kleen wrote:
> > However we may well end up to accept the fact that "we just cannot do
> > hwpoison 100% correct", and settle with a simple and 99% correct code.
> 
> I would prefer to avoid any oopses, but if they are unlikely enough
> and too hard to fix that's bearable. The race window here is certainly rather 
> small. 

Well, several places non-atomically modify page flags, including
within preempt-enabled regions... It's nasty to introduce these
oopses in the hwposion code! I'm ashamed I didn't pick up on this
problem seeing as I introduced several of them.

 
> On the other hand if you cannot detect a difference in benchmarks I see
> no reason not to add the additional steps, as long as the code isn't
> complicated or ugly. These changes are neither.

The patch to add atomics back into the fastpaths? I don't think that's
acceptable at all. A config option doesn't go far enough either because
distros will have to turn it on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
