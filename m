Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7E5406B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 20:11:16 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n610BYAR025446
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Jul 2009 09:11:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 976B845DE51
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 09:11:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BF9C45DE50
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 09:11:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CBB91DB8037
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 09:11:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 11D1B1DB803E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 09:11:33 +0900 (JST)
Date: Wed, 1 Jul 2009 09:09:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
Message-Id: <20090701090959.4cbdb03e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090701084037.2c3f53f7.nishimura@mxp.nes.nec.co.jp>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
	<20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906300918i3e3f8611r6d6fb7873c720c70@mail.gmail.com>
	<20090701084037.2c3f53f7.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jul 2009 08:40:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 30 Jun 2009 09:18:03 -0700, Paul Menage <menage@google.com> wrote:
> > On Tue, Jun 30, 2009 at 2:23 AM, KAMEZAWA
> > Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > This patch is _not_ tested by Nishimura.
> > 
> > True, but it's functionally identical to, and simpler than, the one
> > that was tested.
> > 
> I agree.
> I'll test with both of these patches folded.
> 
Hm,ok. I'll post merged one today.
But I don't like cosmeticized bugfix patch ;(

-Kame

> 
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
