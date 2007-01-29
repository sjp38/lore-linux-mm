Date: Mon, 29 Jan 2007 21:06:48 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-ID: <20070129200648.GA26694@elte.hu>
References: <1169993494.10987.23.camel@lappy> <20070128142925.df2f4dce.akpm@osdl.org> <20070129190806.GA14353@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070129190806.GA14353@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> wrote:

> Here are the numbers that i think changes the picture:

i forgot to explain them:

current (estimated) total installed base of 32-bit (i686) Fedora:

>  http://www.fedoraproject.org/awstats/stats/updates-released-fc6-i386.total

current (estimated) total installed base of 64-bit (x86_64) Fedora:

>  http://www.fedoraproject.org/awstats/stats/updates-released-fc6-x86_64.total

current (estimated) total installed base of PPC(64) Fedora:

>  http://www.fedoraproject.org/awstats/stats/updates-released-fc6-ppc.total

these are updated daily i think. The counters started late October 2006, 
when FC6 was released.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
