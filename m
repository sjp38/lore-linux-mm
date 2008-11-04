Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA46QOK4007513
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 4 Nov 2008 15:26:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B0352AC02A
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 15:26:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 01B8A12C048
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 15:26:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DDCBB1DB803A
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 15:26:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8602B1DB8042
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 15:26:23 +0900 (JST)
Date: Tue, 4 Nov 2008 15:25:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/5] memcg : force_empty to do move account
Message-Id: <20081104152551.28851a7b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830811032223r4c655c2dsc0c4b61c048039f9@mail.gmail.com>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
	<20081031115241.1399d605.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830811032215j3ce5dcc1g6d0c3e9439a004d@mail.gmail.com>
	<20081104151748.4731f5a1.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830811032223r4c655c2dsc0c4b61c048039f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Mon, 3 Nov 2008 22:23:11 -0800
Paul Menage <menage@google.com> wrote:

> On Mon, Nov 3, 2008 at 10:17 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> >
> >> >        mem = memcg;
> >> > -       ret = mem_cgroup_try_charge(mm, gfp_mask, &mem);
> >> > +       ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
> >>
> >> Isn't this the same as the definition of mem_cgroup_try_charge()? So
> >> you could leave it as-is?
> >>
> > try_charge is called by other places....swapin.
> >
> 
> No, I mean here you can call mem_cgroup_try_charge(...) rather than
> __mem_cgroup_try_charge(..., true).
> 

you're right. will remove this change.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
