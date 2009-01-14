Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A88F76B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 22:13:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0E3DA0r004311
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Jan 2009 12:13:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0222F45DD7D
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 12:13:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B83A945DD78
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 12:13:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D3141DB8042
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 12:13:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D8AE1DB803C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 12:13:09 +0900 (JST)
Date: Wed, 14 Jan 2009 12:12:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir
Message-Id: <20090114121205.1bb913aa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830901131905ie10e4bl5168ab7f337b27e1@mail.gmail.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
	<20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131905ie10e4bl5168ab7f337b27e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jan 2009 19:05:35 -0800
Paul Menage <menage@google.com> wrote:

> On Tue, Jan 13, 2009 at 7:00 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > Hmm, add wait_queue to css and wake it up at css_put() ?
> >
> > like this ?
> > ==
> > __css_put()
> > {
> >        if (atomi_dec_return(&css->refcnt) == 1) {
> >                if (notify_on_release(cgrp) {
> >                        .....
> >                }
> >                if (someone_waiting_rmdir(css)) {
> >                        wake_up_him().
> >                }
> >        }
> > }
> 
> Yes, something like that. A system-wide wake queue is probably fine though.
> 
Ok, I'll try that.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
