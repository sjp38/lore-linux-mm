Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id A346B6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 19:01:55 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 47CED3EE0B6
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:01:54 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C19545DE50
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:01:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1431745DE4E
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:01:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 05F9D1DB803F
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:01:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B02541DB802F
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 09:01:53 +0900 (JST)
Date: Fri, 20 Jan 2012 09:00:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: linux-next: Tree for Jan 19 (mm/memcontrol.c)
Message-Id: <20120120090037.e32a119f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F189A97.5080007@xenotime.net>
References: <20120119125932.a4c67005cf6a0938558e8b36@canb.auug.org.au>
	<4F189A97.5080007@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com, Randy Dunlap <rdunlap@xenotime.net>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 19 Jan 2012 14:35:03 -0800
Randy Dunlap <rdunlap@xenotime.net> wrote:

> On 01/18/2012 05:59 PM, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20120118:
> 
> 
> on i386:
> 
> mm/built-in.o:(__jump_table+0x8): undefined reference to `memcg_socket_limit_enabled'
> mm/built-in.o:(__jump_table+0x14): undefined reference to `memcg_socket_limit_enabled'
> 
> 
> Full randconfig file is attached.
> 

Thank you. Forwarding this to Costa.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
