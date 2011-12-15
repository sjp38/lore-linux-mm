Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 383636B004F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 17:54:07 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DF50C3EE0B5
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:54:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C22A645DF01
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:54:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A9E8845DEFF
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:54:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A52B1DB804F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:54:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 552D61DB804A
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:54:05 +0900 (JST)
Date: Fri, 16 Dec 2011 07:52:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: linux-next: Tree for Dec 15 (memcontrol)
Message-Id: <20111216075254.f4a8fa0f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4EEA8693.8020905@xenotime.net>
References: <20111215191115.fd4ef2ab8fa11872ea22d70e@canb.auug.org.au>
	<4EEA8693.8020905@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 15 Dec 2011 15:45:23 -0800
Randy Dunlap <rdunlap@xenotime.net> wrote:

> On 12/15/2011 12:11 AM, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20111214:
> 
> 
> memcontrol.c:(.text+0x31f9d): undefined reference to `mem_cgroup_sockets_init'
> memcontrol.c:(.text+0x326dd): undefined reference to `mem_cgroup_sockets_destroy'
> 
> Full randconfig file is attached.
> 

Added Glauber Costa <glommer@parallels.com> to CC.

THanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
