Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F3F376B0071
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 20:29:27 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU1TPBb001952
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Nov 2010 10:29:25 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26E7D45DE60
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:29:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 015B345DE79
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:29:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C80B31DB803A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:29:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BCD7E38003
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:29:24 +0900 (JST)
Date: Tue, 30 Nov 2010 10:23:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Question about cgroup hierarchy and reducing memory limit
Message-Id: <20101130102349.5bb5e671.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101130090333.0c8c1728.kamezawa.hiroyu@jp.fujitsu.com>
References: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
	<20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimSRJ6GC3=bddNMfnVE3LmMx-9xSY2GX_XNvzCA@mail.gmail.com>
	<20101125100428.24920cd3.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinQ_sqpEc=-vcCQvpp98ny5HSDVvqD_R6_YE3-C@mail.gmail.com>
	<20101129155858.6af29381.kamezawa.hiroyu@jp.fujitsu.com>
	<20101129140233.GA4199@balbir.in.ibm.com>
	<20101130090333.0c8c1728.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Evgeniy Ivanov <lolkaantimat@gmail.com>, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 09:03:33 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > Oh! oh! I'd hate to do this in the fault path
> > 
> Why ? We have per-cpu stock now and infulence of this is minimum.
> We never hit this.
> If problem, I'll use per-cpu value but it seems to be overkill.

I'll remove all atomic ops. 

BTW, if you don't like waitqueue, what is alternative ?
Keeping memory cgroup limit broken as returning -EBUSY is better ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
