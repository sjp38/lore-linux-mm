Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CDE666B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 05:46:16 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0LAkEPu023109
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 21 Jan 2009 19:46:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5140B45DE50
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:46:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 35A6045DE4F
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:46:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F64B1DB803E
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:46:14 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id ADF981DB803F
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:46:13 +0900 (JST)
Date: Wed, 21 Jan 2009 19:45:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir v2
Message-Id: <20090121194509.b5084225.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830901210243k433f618bva4ec756b769be4d4@mail.gmail.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
	<20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131905ie10e4bl5168ab7f337b27e1@mail.gmail.com>
	<20090114121205.1bb913aa.kamezawa.hiroyu@jp.fujitsu.com>
	<20090120194735.cc52c5e0.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901210200q77b2553ag35f706c321a18d83@mail.gmail.com>
	<20090121193248.94aecb10.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901210243k433f618bva4ec756b769be4d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jan 2009 02:43:44 -0800
Paul Menage <menage@google.com> wrote:

> On Wed, Jan 21, 2009 at 2:32 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > Hmm, subsystem may return -EPERM or some..
> > I'll change this to
> >
> >  if (!ret)
> >    return ret;
> 
> You mean
> 
> if (ret)
>   return ret;
> 
Yes. (>_<!

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
