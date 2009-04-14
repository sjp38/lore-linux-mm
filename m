Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A6CC5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 03:16:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E7HAsx021742
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 16:17:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B0E2245DD76
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 16:17:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DE3A45DD74
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 16:17:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 76623E08008
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 16:17:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D0ECEE08002
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 16:17:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
In-Reply-To: <20090414071159.GV14687@one.firstfloor.org>
References: <20090414154606.C665.A69D9226@jp.fujitsu.com> <20090414071159.GV14687@one.firstfloor.org>
Message-Id: <20090414161211.C66E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 16:17:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Apr 14, 2009 at 03:54:40PM +0900, KOSAKI Motohiro wrote:
> > Hi
> 
> There are two use cases here:
> 
> First what is useful for the administrator as a general abstraction.
> And what is useful for the kernel hacker for debugging.
> 
> The kernel hacker wants everything even if it's subject to change,
> the administrator wants a higher level abstraction they can make
> sense of and that doesn't change too often.
> 
> I think there's a case for both usages, but perhaps they 
> should be separated (in a public and a internal interface perhaps?)
> 
> My comments below are about abstractions for the first case.
> 
> 
> > 
> > > On Tue, Apr 14, 2009 at 12:37:10PM +0800, KOSAKI Motohiro wrote:
> > > > > Export the following page flags in /proc/kpageflags,
> > > > > just in case they will be useful to someone:
> > > > > 
> > > > > - PG_swapcache
> > > > > - PG_swapbacked
> > > > > - PG_mappedtodisk
> > > > > - PG_reserved
> 
> PG_reserved should be exported as PG_KERNEL or somesuch.

OK.

rest problem is, how do we write document this.
PG_reserved have multiple meanings...


> > > > > - PG_private
> > > > > - PG_private_2
> > > > > - PG_owner_priv_1
> > > > > 
> > > > > - PG_head
> > > > > - PG_tail
> > > > > - PG_compound
> 
> I would combine these three into a pseudo "large page" flag.

Ah good idea.

> > > > > 
> > > > > - PG_unevictable
> > > > > - PG_mlocked
> > > > > 
> > > > > - PG_poison
> 
> PG_poison is also useful to export. But since it depends on my
> patchkit I will pull a patch for that into the HWPOISON series.

Yes, I agree.

> > > > > - PG_unevictable
> > > > > - PG_mlocked
> > 
> > this 9 flags shouldn't exported.
> > I can't imazine administrator use what purpose those flags.
> 
> I think an abstraced "PG_pinned" or somesuch flag that combines
> page lock, unevictable, mlocked would be useful for the administrator.

PG_unevictable and PG_mlocked have a bit delicate meaning.
it gurantee the page isn't evicted. but mlock(2) don't gurantee
turn page on PG_mlocked. some race prevent it.

I'm afraid administrator confuse it. but if someone can write good
document, my worriness will vanished.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
