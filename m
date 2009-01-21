Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6C7206B0047
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 05:35:48 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0LAZiSg020067
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 21 Jan 2009 19:35:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A14AC45DE55
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:35:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 826BF45DE51
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:35:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 694E21DB803C
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:35:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 03BF81DB803E
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:35:41 +0900 (JST)
Date: Wed, 21 Jan 2009 19:34:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1.5/4] cgroup: delay populate css id
Message-Id: <20090121193436.c314ad7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830901210136j9baf45ft4c86a93fec70827f@mail.gmail.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
	<20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191823q556faeeub28d02d39dda7396@mail.gmail.com>
	<20090120115832.0881506c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090120144337.82ed51d5.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901210136j9baf45ft4c86a93fec70827f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jan 2009 01:36:32 -0800
Paul Menage <menage@google.com> wrote:

> On Mon, Jan 19, 2009 at 9:43 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > +static void populate_css_id(struct cgroup_subsys_state *css)
> > +{
> > +       struct css_id *id = rcu_dereference(css->id);
> > +       if (id)
> > +               rcu_assign_pointer(id->css, css);
> > +}
> 
> I don't think this needs to be split out into a separate function.
ok.

> Also, there's no need for an rcu_dereference(), since we're holding
> cgroup_mutex.
> 
Sure. I'll fix.

I'll merge this behavior to CSS ID patch and post it again.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
