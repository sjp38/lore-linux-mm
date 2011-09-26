Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D710C9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:13:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DA2353EE0AE
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:13:30 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE98145DE58
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:13:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 88C3A45DE5B
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:13:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72BC91DB8053
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:13:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4064D1DB8052
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:13:30 +0900 (JST)
Date: Mon, 26 Sep 2011 18:12:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm/page_cgroup.c: quiet sparse noise
Message-Id: <20110926181230.a5240774.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <201109221815.08891.hartleys@visionengravers.com>
References: <201109221815.08891.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, containers@lists.linux-foundation.org, paul@paulmenage.org, lizf@cn.fujitsu.com, bsingharora@gmail.com, nishimura@mxp.nes.nec.co.jp

On Thu, 22 Sep 2011 18:15:08 -0700
H Hartley Sweeten <hartleys@visionengravers.com> wrote:

> Quite the sparse noise:
> 
> warning: symbol 'swap_cgroup_ctrl' was not declared. Should it be static?
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: Paul Menage <paul@paulmenage.org>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thank you.

Acked-by: KAMEZAWA hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
