Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try
	2)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070209013115.GA17334@wotan.suse.de>
References: <20070208111421.30513.77904.sendpatchset@linux.site>
	 <Pine.LNX.4.64.0702090027580.29905@blonde.wat.veritas.com>
	 <20070209013115.GA17334@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 09 Feb 2007 12:44:09 +1100
Message-Id: <1170985449.2620.391.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > Fix threaded user page write memory ordering
> 
> Thanks, I did see that, but I'm sure it must have been prompted by a
> discussion or another proposed patch from IBM. Maybe I'm wrong
> though.

Yes, my initial proposal iirc was to smp_wmb() in set_pte() but after a
discussion with Linus, we ended with open coding them.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
