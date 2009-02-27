Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6454F6B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 00:29:57 -0500 (EST)
Date: Thu, 26 Feb 2009 21:29:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12785] New: kswapd block the whole system by
 IO blaster in some case
Message-Id: <20090226212918.fce45757.akpm@linux-foundation.org>
In-Reply-To: <bug-12785-10286@http.bugzilla.kernel.org/>
References: <bug-12785-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: bugme-daemon@bugzilla.kernel.org, crackevil@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

(uh-oh)

On Thu, 26 Feb 2009 21:20:46 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12785
> 
>            Summary: kswapd block the whole system by IO blaster in some case
>            Product: Memory Management
>            Version: 2.5
>      KernelVersion: 2.6.28.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@osdl.org
>         ReportedBy: crackevil@gmail.com
> 
> 
> Distribution:debian lenny with some experimental packages
> Hardware Environment:ThinkPad SL 400 7DC with 2G memery
> Software Environment:no swap partition,kernel with 4G memery support
> Problem Description:
> Some day, my box dived into a block while HDLED was blinking.
> I switched to console from gdm, tried iotop by long waiting and found the
> killer was kswapd.
> In "top" output, free memory is almost 50M.The most memory is cached by swap.
> The system blocked even shutdown command wasn't effective.The box had been
> killed by pressing then power button.
> BTW, there was no network available then, so there was no attack possibility.
> 
> I'd like to attach my kernel config file, but I don't know how to.For someone
> interesting, we may transfer the file my mail.crackevil@gmail.com
> 
> ps:these experimental packages installed
> 
> libdrm2_2.4.4+git+20090205+8b88036-1_i386.deb
> libdrm-dev_2.4.4+git+20090205+8b88036-1_i386.deb
> libdrm-intel1_2.4.4+git+20090205+8b88036-1_i386.deb
> libdrm-nouveau1_2.4.4+git+20090205+8b88036-1_i386.deb
> libgl1-mesa-dev_7.3-1_all.deb
> libgl1-mesa-dri_7.3-1_i386.deb
> libgl1-mesa-glx_7.3-1_i386.deb
> libglu1-mesa_7.3-1_i386.deb
> mesa-common-dev_7.3-1_all.deb
> mesa-utils_7.3-1_i386.deb
> xserver-common_2%3a1.5.99.902-1_all.deb
> xserver-xorg-core_2%3a1.5.99.902-1_i386.deb
> xkb-data_1.5-2_all.deb
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
