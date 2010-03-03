Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 41E306B004D
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:42:23 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o230gKd2002550
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 09:42:20 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E81945DE50
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:42:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D25845DE4D
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:42:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD94B1DB803C
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:42:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 99394E38001
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:42:19 +0900 (JST)
Date: Wed, 3 Mar 2010 09:38:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom kill behavior v2
Message-Id: <20100303093844.cf768ea4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100303092606.2e2152fc.nishimura@mxp.nes.nec.co.jp>
References: <20100302115834.c0045175.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302135524.afe2f7ab.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302143738.5cd42026.nishimura@mxp.nes.nec.co.jp>
	<20100302145644.0f8fbcca.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302151544.59c23678.nishimura@mxp.nes.nec.co.jp>
	<20100303092606.2e2152fc.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 09:26:06 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > I'll test this patch all through this night, and check whether it doesn't trigger
> > global oom after memcg's oom.
> > 
> O.K. It works well.
> Feel free to add my signs.
> 
> 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 	Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 

Thank you !

I'll apply Balbir's comment and post v3.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
