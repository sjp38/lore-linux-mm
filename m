Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D4566B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 20:49:03 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2B0n1hh026000
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 11 Mar 2009 09:49:01 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AF1C45DE4F
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:49:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DEE845DE4E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:49:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E4687E08006
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:49:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 54691E08004
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:49:00 +0900 (JST)
Date: Wed, 11 Mar 2009 09:47:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: charge swapcache to proper memcg
Message-Id: <20090311094739.3123b05d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <isapiwc.d14e3c29.6b18.49b7092b.9bc73.52@mail.jp.nec.com>
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
	<20090310160856.77deb5c3.akpm@linux-foundation.org>
	<20090311085326.403a211d.kamezawa.hiroyu@jp.fujitsu.com>
	<isapiwc.d14e3c29.6b18.49b7092b.9bc73.52@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Wed, 11 Mar 2009 09:43:23 +0900
nishimura@mxp.nes.nec.co.jp wrote:

> >> I temporarily dropped
> >> use-css-id-in-swap_cgroup-for-saving-memory-v4.patch.  Could I have a
> >> fixed version please?
> > Okay.
> > 
> I'm sorry for bothering you.
> 
No problem :) Thank you for digging bug.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
