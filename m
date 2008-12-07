Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB74hGSa026880
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 7 Dec 2008 13:43:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 667B445DD7B
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 13:43:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 45E8845DD78
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 13:43:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CDA61DB8038
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 13:43:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D77E21DB8037
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 13:43:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] memory hotplug: run lru_add_drain_all() on each cpu
In-Reply-To: <1228509818.12681.21.camel@nimitz>
References: <1228482500.8392.15.camel@t60p> <1228509818.12681.21.camel@nimitz>
Message-Id: <20081207133450.53D8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  7 Dec 2008 13:43:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, gerald.schaefer@de.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

CC to Lee Schermerhorn


> On Fri, 2008-12-05 at 14:08 +0100, Gerald Schaefer wrote:
> > 
> > As explained above, the per-cpu pagevec layout should be independent
> > from NUMA or UNEVICTABLE_LRU, so I guess the right thing to do here
> > is completely remove the #ifdef as in the patch from Kosaki Motohiro
> > (or at least replace it with a CONFIG_SMP as suggested by Kamezawa
> > Hiroyuki).
> 
> Thanks for looking into it deeper.  That CONFIG_SMP thing really does
> look like the right solution.

Lee, Could you read this thread and explain why you add ifdef CONFIG_UNEVICTABLE_LRU?
I am not sure about that Dave's proposal is safe change. (but I guess he is right)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
