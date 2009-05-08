Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B3B4B6B004D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 12:29:22 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n48GTl8Y020222
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 9 May 2009 01:29:48 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A921945DD77
	for <linux-mm@kvack.org>; Sat,  9 May 2009 01:29:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8640245DD76
	for <linux-mm@kvack.org>; Sat,  9 May 2009 01:29:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F1D51DB8017
	for <linux-mm@kvack.org>; Sat,  9 May 2009 01:29:47 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4580D1DB8014
	for <linux-mm@kvack.org>; Sat,  9 May 2009 01:29:47 +0900 (JST)
Message-ID: <e100843048ef769085ac80ac03d19842.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090508230107.8dd680b3.d-nishimura@mtf.biglobe.ne.jp>
References: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com>
    <20090508140910.bb07f5c6.kamezawa.hiroyu@jp.fujitsu.com>
    <20090508230107.8dd680b3.d-nishimura@mtf.biglobe.ne.jp>
Date: Sat, 9 May 2009 01:29:46 +0900 (JST)
Subject: Re: [PATCH 2/2] memcg fix stale swap cache account leak v6
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> On Fri, 8 May 2009 14:09:10 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

>>  - avoid swapin-readahead when memcg is activated.
> I agree that disabling readahead would be the easiest way to avoid type-1.
> And this patch looks good to me about it.
>
Thanks.

> But if we go in this way to avoid type-1, I think my patch(*1) would be
> enough to avoid type-2 and is simpler than this one.
> I've confirmed in my test that no leak can be seen with my patch and
> with setting page-cluster to 0.
>
> *1 http://marc.info/?l=linux-kernel&m=124115252607665&w=2
>
Ok, I'll merge yours on my set.
the whole patch set will be
  [1/3]  memcg_activated()
  [2/3]  avoid readahead
  [3/3]  your fix.

I'll post in the next week.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
