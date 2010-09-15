Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 00ED96B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 00:53:14 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8F4rCb5023466
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Sep 2010 13:53:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D7D145DE54
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:53:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 088C445DE51
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:53:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DAB091DB803F
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:53:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 92BD51DB805B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:53:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
In-Reply-To: <20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com> <20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20100915135016.C9F1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Sep 2010 13:53:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> >  ==============================================================
> >  
> > diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
> > --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-14 15:44:29.000000000 -0700
> > +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-14 15:58:31.000000000 -0700
> > @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
> >  {
> >  	proc_dointvec_minmax(table, write, buffer, length, ppos);
> >  	if (write) {
> > +		WARN_ONCE(1, "kernel caches forcefully dropped, "
> > +			     "see Documentation/sysctl/vm.txt\n");
> 
> Documentation updeta seems good but showing warning seems to be meddling to me.

Agreed.

If the motivation is blog's bogus rumor, this is no effective. I easily
imazine they will write "Hey, drop_caches may output strange message, 
but please ignore it!".


	Libenter homines id quod volunt credunt.
		Gaius Julius Caesar "Commentarii de Bello Gallico" 3-18



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
