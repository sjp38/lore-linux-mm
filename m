Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4CC6B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 18:18:18 -0500 (EST)
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was:
 Re: [linux-pm] Memory allocations in .suspend became very unreliable)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <195c7a901001190104x164381f9v4a58d1fce70b17b6@mail.gmail.com>
References: <20100118110324.AE30.A69D9226@jp.fujitsu.com>
	 <201001182155.09727.rjw@sisk.pl>
	 <20100119101101.5F2E.A69D9226@jp.fujitsu.com>
	 <1263871194.724.520.camel@pasglop>
	 <195c7a901001190104x164381f9v4a58d1fce70b17b6@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jan 2010 10:17:51 +1100
Message-ID: <1263943071.724.540.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bastien ROUCARIES <roucaries.bastien@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-01-19 at 10:04 +0100, Bastien ROUCARIES wrote:
> Instead of masking bit could we only check if incompatible flags are
> used during suspend, and warm deeply. Call stack will be therefore
> identified, and we could have some metrics about such problem.
> 
> It will be a debug option like lockdep but pretty low cost.

I still believe it would just be a giant can of worms to require every
call site of memory allocators to "know" whether suspend has been
started or not.... Along the same reasons why we added that stuff for
boot time allocs.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
