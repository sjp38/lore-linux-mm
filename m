Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5606B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 03:20:36 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4BCDC3EE0B6
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 16:20:32 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3206745DE7E
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 16:20:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 13D5145DE7A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 16:20:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0388A1DB8038
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 16:20:32 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C2A521DB802C
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 16:20:31 +0900 (JST)
Date: Thu, 25 Aug 2011 16:13:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2011-08-24-14-08 uploaded
Message-Id: <20110825161307.7c921e46.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <201108242148.p7OLm1lt009191@imap1.linux-foundation.org>
References: <201108242148.p7OLm1lt009191@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Wed, 24 Aug 2011 14:09:05 -0700
akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-08-24-14-08 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> It contains the following patches against 3.1-rc3:
> (patches marked "*" will be included in linux-next)
> 

just reporting.

A compile error from linux-next.patch.

drivers/built-in.o: In function `dwc3_testmode_open':
/home/kamezawa/Kernel/mmotm-Aug24/drivers/usb/dwc3/debugfs.c:481: undefined reference to `dwc3_send_gadget_ep_cmd'
/home/kamezawa/Kernel/mmotm-Aug24/drivers/usb/dwc3/debugfs.c:482: undefined reference to `dwc3_send_gadget_ep_cmd'
make: *** [.tmp_vmlinux1] Error 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
