Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D60AF6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 20:19:36 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2B0JYIM013547
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Mar 2009 09:19:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D5CC45DE4F
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:19:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E0A7445DD72
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:19:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CCE9A1DB803E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:19:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 82BFC1DB803F
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:19:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
In-Reply-To: <20090310105523.3dfd4873@mjolnir.ossman.eu>
References: <20090310081917.GA28968@localhost> <20090310105523.3dfd4873@mjolnir.ossman.eu>
Message-Id: <20090311091738.8784.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Mar 2009 09:19:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> > Here is the initial patch and tool for finding the missing pages.
> > 
> > In the following example, the pages with no flags set is kind of too
> > many (1816MB), but hopefully your missing pages will have PG_reserved
> > or other flags set ;-)
> > 
> > # ./page-types
> > L:locked E:error R:referenced U:uptodate D:dirty L:lru A:active S:slab W:writeback x:reclaim B:buddy r:reserved c:swapcache b:swapbacked
> >  
> 
> Thanks. I'll have a look in a bit. Right now I'm very close to a
> complete bisect. It is just ftrace commits left though, so I'm somewhat
> sceptical that it is correct. ftrace isn't even turned on in the
> kernels I've been testing.
> 
> The remaining commits are ec1bb60bb..6712e299.

Can you try to turn off CONFIG_FTRACE* build option?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
