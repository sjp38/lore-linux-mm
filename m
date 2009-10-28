Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 280726B0089
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 20:35:00 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S0YvoG006004
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 09:34:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A5D145DE5D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:34:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1807845DE51
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:34:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E7FAF1DB803F
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:34:56 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CC811DB803A
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:34:56 +0900 (JST)
Date: Wed, 28 Oct 2009 09:32:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
 RSS/swap value for oom_score (Re: Memory overcommit
Message-Id: <20091028093226.034d2e51.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091027184743.GD5753@random.random>
References: <4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
	<20091027153429.b36866c4.minchan.kim@barrios-desktop>
	<20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
	<20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910271821130.11372@sister.anvils>
	<20091027184743.GD5753@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 19:47:43 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote: 
> > should be included along with rss isn't quite clear to me: I'm not
> > saying you're wrong, not at all, just that it's not quite obvious.
> 
> Agreed it's not obvious. Intuitively I think only including RSS and no
> swap is best, but clearly I can't be entirely against including swap
> too as there may be scenarios where including swap provides for a
> better choice.
> 
> My argument for not including swap is that we kill tasks to free RAM
> (we don't really care to free swap, system needs RAM at oom time).
> Freeing swap won't immediately help because no RAM is freed when swap
> is released (sure other tasks that sits huge in RAM can be moved to
> swap after swap isn't full but if we immediately killed those tasks
> that were huge in RAM in the first place we'd be better off).
> 
Okay.

As first step, I'll divide this into 
   - replace total_vm with anon_rss/file_rss patch
   - swap accounting
   - a patch for consider whether swap amount should be included or not.

Then, necessary part will go early. And backport will be easy.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
