Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i980c8UI023418 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 09:38:08 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i980c6ND012778 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 09:38:06 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp (localhost [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id C5885EFB0E
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 09:38:05 +0900 (JST)
Received: from fjmail505.fjmail.jp.fujitsu.com (fjmail505-0.fjmail.jp.fujitsu.com [10.59.80.104])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A581EFB0A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 09:38:05 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail505.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5800L78PRFMO@fjmail505.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri,  8 Oct 2004 09:38:04 +0900 (JST)
Date: Fri, 08 Oct 2004 09:43:40 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [PATCH] no buddy bitmap patch : for ia64 [2/2]
In-reply-to: <1097163793.3625.47.camel@localhost>
Message-id: <4165E2BC.3070906@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <4165399D.7010600@jp.fujitsu.com>
 <1097163793.3625.47.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, "Luck, Tony" <tony.luck@intel.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> The real way to do this is to put it in a Kconfig file.  
> 
> something like:
> 
> config HOLES_IN_ZONE
> 	bool
> 	depends on VIRTUAL_MEM_MAP
> 
> right below where 'config VIRTUAL_MEM_MAP' is defined.  That way, if any
> other architectures need it, they alter their Kconfig files instead of
> headers.  Also, it leaves the possibility of having an arch-independent
> Kconfig file for memory-related options which I'd like to do in the
> future.
> 
Ok, it looks better. I'll move it.
Updated version will be posted in a day.


Kame <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
