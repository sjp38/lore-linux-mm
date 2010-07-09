Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C157E6B02A4
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 12:48:21 -0400 (EDT)
Date: Fri, 9 Jul 2010 18:48:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][BUGFIX][PATCH 0/2] transhuge-memcg: some fixes (Re:
 Transparent Hugepage Support #25)
Message-ID: <20100709164815.GE5741@random.random>
References: <20100521000539.GA5733@random.random>
 <20100602144438.dc04ece7.nishimura@mxp.nes.nec.co.jp>
 <20100618010840.GE5787@random.random>
 <20100618132817.657f69b9.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100618132817.657f69b9.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 18, 2010 at 01:28:17PM +0900, Daisuke Nishimura wrote:
> Will do if necessary, but hmm, I heard from KAMEZAWA-san that he has already sent
> some patches to fix the similar problems on RHEL6, and I prefer his fixes to mine.
> Should I(or KAMEZAWA-san?) forward port his patches onto current aa.git ?

Now I also got more memcg fixes from Johannes... included in -27. It'd
be nice to keep things in sync.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc4/transparent_hugepage-27/memcg_check_room
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc4/transparent_hugepage-27/memcg_consume_stock
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.35-rc4/transparent_hugepage-27/memcg_oom

> Agreed. And I think you'll see some extra changes of memcg in 2.6.36...
> Any way, I'll do some test in both RHEL6 and aa.git when I have a time,
> and feel free to tell me if you have any troubles in back/forward porting
> memcg's fixes.

I just released a new #27, please use that. Thanks!

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
