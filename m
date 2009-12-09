Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CB7AF60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 19:27:02 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB90QxcB009630
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Dec 2009 09:26:59 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F0BF45DE56
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:26:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F386145DE52
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:26:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 788DF1DB8042
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:26:58 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 08759E78007
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:26:58 +0900 (JST)
Date: Wed, 9 Dec 2009 09:24:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [cleanup][PATCH mmotm]memcg: don't call
 mem_cgroup_soft_limit_check() against root cgroup (Re: [BUG?] [PATCH] soft
 limits and root cgroups)
Message-Id: <20091209092406.b239a447.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091208100954.44996a7e.nishimura@mxp.nes.nec.co.jp>
References: <cc557aab0912071041j5c5731dbj9fd669ef26e6f2ae@mail.gmail.com>
	<20091208100954.44996a7e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Dec 2009 10:09:54 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> current memory cgroup doesn't use res_counter about root cgroup, so soft limits
> on root cgroup has no use.
> This patch disables writing to <root cgroup>/memory.soft_limit_in_bytes and
> changes uncharge path not to call mem_cgroup_soft_limit_check() against root
> cgroup.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
