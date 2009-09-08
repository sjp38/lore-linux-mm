Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E35376B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 10:14:27 -0400 (EDT)
Date: Tue, 8 Sep 2009 07:13:55 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 7/8] mm: reinstate ZERO_PAGE
In-Reply-To: <20090908073119.GA29902@wotan.suse.de>
Message-ID: <alpine.LFD.2.01.0909080712200.7458@localhost.localdomain>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072238320.15430@sister.anvils> <20090908073119.GA29902@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Tue, 8 Sep 2009, Nick Piggin wrote:
> 
> Without looking closely, why is it a big problem to have a
> !HAVE PTE SPECIAL case? Couldn't it just be a check for
> pfn == zero_pfn that is conditionally compiled away for pte
> special architectures anyway?

At least traditionally, there wasn't a single zero_pfn, but multiple (for 
VIPT caches that have performance issues with aliases). But yeah, we could 
check just the pfn number, and allow any architecture to do it.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
