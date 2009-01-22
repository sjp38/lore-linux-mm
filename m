Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1CD6D6B0087
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 21:07:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0M27d9b017813
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jan 2009 11:07:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C607645DE65
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 11:07:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9574345DE51
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 11:07:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A6E2E38003
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 11:07:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BAE71DB803E
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 11:07:38 +0900 (JST)
Date: Thu, 22 Jan 2009 11:06:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1.5/4] cgroup: delay populate css id
Message-Id: <20090122110632.e5c4216c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090121193436.c314ad7d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
	<20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191823q556faeeub28d02d39dda7396@mail.gmail.com>
	<20090120115832.0881506c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090120144337.82ed51d5.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901210136j9baf45ft4c86a93fec70827f@mail.gmail.com>
	<20090121193436.c314ad7d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jan 2009 19:34:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 21 Jan 2009 01:36:32 -0800
> Paul Menage <menage@google.com> wrote:
> 
> > On Mon, Jan 19, 2009 at 9:43 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > +static void populate_css_id(struct cgroup_subsys_state *css)
> > > +{
> > > +       struct css_id *id = rcu_dereference(css->id);
> > > +       if (id)
> > > +               rcu_assign_pointer(id->css, css);
> > > +}
> > 
> > I don't think this needs to be split out into a separate function.
> ok.
> 
> > Also, there's no need for an rcu_dereference(), since we're holding
> > cgroup_mutex.
> > 
> Sure. I'll fix.
> 

BTW, isn't it better to use rcu_assign_pointer to show "this pointer will be
dereferenced from RCU-read-side" ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
