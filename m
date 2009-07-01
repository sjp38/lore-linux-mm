Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 541746B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 21:05:40 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6115k5B017348
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Jul 2009 10:05:47 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EE3F45DE51
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:05:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D21845DE4E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:05:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 502571DB803A
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:05:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AA591DB8037
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:05:46 +0900 (JST)
Date: Wed, 1 Jul 2009 10:04:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
Message-Id: <20090701100412.d59122d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830906301727wcb6b292uc3c46451f8844392@mail.gmail.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
	<20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906300918i3e3f8611r6d6fb7873c720c70@mail.gmail.com>
	<20090701084037.2c3f53f7.nishimura@mxp.nes.nec.co.jp>
	<20090701090959.4cbdb03e.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906301727wcb6b292uc3c46451f8844392@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009 17:27:02 -0700
Paul Menage <menage@google.com> wrote:

> It only looks "cosmeticized" because of the evolution of your fix. The
> first patch added a new function that exposed internal details of
> cgroups, and the second patch removes the addition in favour of a
> different new function that doesn't expose internal details as much; a
> single patch that just adds the simpler new function is easier to
> judge as intuitively correct (separately from Daisuke's testing) than
> one that exposes more internal details.
> 
ok, I'll post again.

BTW, do you have patches for NOOP/signal cgroup we discussed a half year ago ?

Thanks,
-Kame

> Paul
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
