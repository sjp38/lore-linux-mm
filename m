Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 285E36B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 11:18:53 -0400 (EDT)
Date: Thu, 25 Aug 2011 08:18:48 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: mmotm 2011-08-24-14-08 uploaded
Message-Id: <20110825081848.f6e8a62d.rdunlap@xenotime.net>
In-Reply-To: <20110825161307.7c921e46.kamezawa.hiroyu@jp.fujitsu.com>
References: <201108242148.p7OLm1lt009191@imap1.linux-foundation.org>
	<20110825161307.7c921e46.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Thu, 25 Aug 2011 16:13:07 +0900 KAMEZAWA Hiroyuki wrote:

> On Wed, 24 Aug 2011 14:09:05 -0700
> akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2011-08-24-14-08 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > It contains the following patches against 3.1-rc3:
> > (patches marked "*" will be included in linux-next)
> > 
> 
> just reporting.
> 
> A compile error from linux-next.patch.
> 
> drivers/built-in.o: In function `dwc3_testmode_open':
> /home/kamezawa/Kernel/mmotm-Aug24/drivers/usb/dwc3/debugfs.c:481: undefined reference to `dwc3_send_gadget_ep_cmd'
> /home/kamezawa/Kernel/mmotm-Aug24/drivers/usb/dwc3/debugfs.c:482: undefined reference to `dwc3_send_gadget_ep_cmd'
> make: *** [.tmp_vmlinux1] Error 

Yes, I've sent GregKH a patch for this against linux-next.

thanks,
---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
