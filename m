Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A37356B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 00:48:06 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1R5m4AB015055
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 27 Feb 2009 14:48:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 572AD45DD78
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 14:48:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 275BD45DD72
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 14:48:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F2B08E08006
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 14:48:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A80DD1DB803F
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 14:48:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 12785] New: kswapd block the whole system by IO blaster in some case
In-Reply-To: <20090226212918.fce45757.akpm@linux-foundation.org>
References: <bug-12785-10286@http.bugzilla.kernel.org/> <20090226212918.fce45757.akpm@linux-foundation.org>
Message-Id: <20090227144355.1545.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 27 Feb 2009 14:48:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, bugme-daemon@bugzilla.kernel.org, crackevil@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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

As far as I know, lenny (debian 5.0) use kernel 2.6.26.
then, recently changed code don't provide any hint.

Martin, if remove experimental package, do you still see the same issue?



> > Hardware Environment:ThinkPad SL 400 7DC with 2G memery
> > Software Environment:no swap partition,kernel with 4G memery support
> > Problem Description:
> > Some day, my box dived into a block while HDLED was blinking.
> > I switched to console from gdm, tried iotop by long waiting and found the
> > killer was kswapd.
> > In "top" output, free memory is almost 50M.The most memory is cached by swap.
> > The system blocked even shutdown command wasn't effective.The box had been
> > killed by pressing then power button.
> > BTW, there was no network available then, so there was no attack possibility.
> > 
> > I'd like to attach my kernel config file, but I don't know how to.For someone
> > interesting, we may transfer the file my mail.crackevil@gmail.com
> > 
> > ps:these experimental packages installed
> > 
> > libdrm2_2.4.4+git+20090205+8b88036-1_i386.deb
> > libdrm-dev_2.4.4+git+20090205+8b88036-1_i386.deb
> > libdrm-intel1_2.4.4+git+20090205+8b88036-1_i386.deb
> > libdrm-nouveau1_2.4.4+git+20090205+8b88036-1_i386.deb
> > libgl1-mesa-dev_7.3-1_all.deb
> > libgl1-mesa-dri_7.3-1_i386.deb
> > libgl1-mesa-glx_7.3-1_i386.deb
> > libglu1-mesa_7.3-1_i386.deb
> > mesa-common-dev_7.3-1_all.deb
> > mesa-utils_7.3-1_i386.deb
> > xserver-common_2%3a1.5.99.902-1_all.deb
> > xserver-xorg-core_2%3a1.5.99.902-1_i386.deb
> > xkb-data_1.5-2_all.deb
> > 
> > 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
