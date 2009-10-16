Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 100B86B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 00:08:51 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9G48n99013808
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Oct 2009 13:08:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E4F5745DE51
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 13:08:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C85F045DE4C
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 13:08:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id ABB4E1DB8038
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 13:08:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C5521DB803A
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 13:08:48 +0900 (JST)
Date: Fri, 16 Oct 2009 13:06:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/9] swap_info: swap count continuations
Message-Id: <20091016130622.8c096641.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910160314310.2993@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
	<Pine.LNX.4.64.0910150153560.3291@sister.anvils>
	<20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910160016160.11643@sister.anvils>
	<20091016102951.a4f66a19.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910160314310.2993@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, hongshin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Oct 2009 03:24:57 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Fri, 16 Oct 2009, KAMEZAWA Hiroyuki wrote:
> > > 
> > My concern is that small numbers of swap_map[] which has too much refcnt
> > can consume too much pages.
> > 
> > If an entry is shared by 65535, 65535/128 = 512 page will be used.
> > (I'm sorry if I don't undestand implementation correctly.)
> 
> Ah, you're thinking it's additive: perhaps because I use the name
> "continuation", which may give that impression - maybe there's a
> better name I can give it.
> 
> No, it's multiplicative - just like 999 is almost a thousand, not 27.
> 
> If an entry is shared by 65535, then it needs its original swap_map
> page (0 to 0x3e) and a continuation page (0 to 0x7f) and another
> continuation page (0 to 0x7f): if I've got my arithmetic right,
> those three pages can hold a shared count up to 1032191, for
> every one of that group of PAGE_SIZE neighbouring pages.
> 
Ah, okay. I see. thank you for explanation.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
