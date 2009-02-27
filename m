Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D13FF6B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 01:10:01 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1R69vhc018515
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Feb 2009 15:09:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6087345DD7F
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 15:09:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F93445DD78
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 15:09:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 27DD41DB803E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 15:09:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1FCB1DB8038
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 15:09:56 +0900 (JST)
Date: Fri, 27 Feb 2009 15:08:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 12785] New: kswapd block the whole system by
 IO blaster in some case
Message-Id: <20090227150841.b7269557.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090226212918.fce45757.akpm@linux-foundation.org>
References: <bug-12785-10286@http.bugzilla.kernel.org/>
	<20090226212918.fce45757.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, bugme-daemon@bugzilla.kernel.org, crackevil@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 2009 21:29:18 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> (uh-oh)
> 
> On Thu, 26 Feb 2009 21:20:46 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=12785
> > 
> >            Summary: kswapd block the whole system by IO blaster in some case
> >            Product: Memory Management
> >            Version: 2.5
> >      KernelVersion: 2.6.28.4
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: low
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@osdl.org
> >         ReportedBy: crackevil@gmail.com
> > 
> > 
> > Distribution:debian lenny with some experimental packages
> > Hardware Environment:ThinkPad SL 400 7DC with 2G memery
> > Software Environment:no swap partition,kernel with 4G memery support
> > Problem Description:
> > Some day, my box dived into a block while HDLED was blinking.
> > I switched to console from gdm, tried iotop by long waiting and found the
> > killer was kswapd.
> > In "top" output, free memory is almost 50M.The most memory is cached by swap.
> > The system blocked even shutdown command wasn't effective.The box had been
> > killed by pressing then power button.

BTW, pages can be SwapCache even when there are no swap partition ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
