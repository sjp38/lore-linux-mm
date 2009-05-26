Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 25E2E6B005A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 02:51:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4Q6qcvk020852
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 26 May 2009 15:52:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 188BE45DE66
	for <linux-mm@kvack.org>; Tue, 26 May 2009 15:52:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E1A5345DE60
	for <linux-mm@kvack.org>; Tue, 26 May 2009 15:52:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A2E49E38004
	for <linux-mm@kvack.org>; Tue, 26 May 2009 15:52:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D13F0E08007
	for <linux-mm@kvack.org>; Tue, 26 May 2009 15:52:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][mmtom] clean up once printk routine
In-Reply-To: <20090526135733.3c38f758.minchan.kim@barrios-desktop>
References: <20090526135733.3c38f758.minchan.kim@barrios-desktop>
Message-Id: <20090526155155.6871.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 May 2009 15:52:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Dominik Brodowski <linux@dominikbrodowski.net>, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> == CUT HERE ==
> 
> There are some places to be able to use printk_once instead of hard coding.
> 
> It will help code readability and maintenance.
> This patch doesn't change function's behavior.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> CC: Dominik Brodowski <linux@dominikbrodowski.net>
> CC: David S. Miller <davem@davemloft.net>
> CC: Ingo Molnar <mingo@elte.hu>
> ---
>  arch/x86/kernel/cpu/common.c  |    8 ++------
>  drivers/net/3c515.c           |    7 ++-----
>  drivers/pcmcia/pcmcia_ioctl.c |    9 +++------
>  3 files changed, 7 insertions(+), 17 deletions(-)

Please separete to three patches ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
