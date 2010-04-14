Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 39D51600370
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 01:03:49 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E53kbm002939
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 14:03:46 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7045F45DE53
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:03:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4176945DE51
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:03:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 181991DB8038
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:03:46 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C4BCD1DB8040
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:03:45 +0900 (JST)
Date: Wed, 14 Apr 2010 13:59:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-Id: <20100414135945.2b0a1e0d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100414014041.GD2493@dastard>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
	<20100413095815.GU25756@csn.ul.ie>
	<20100413111902.GY2493@dastard>
	<20100413193428.GI25756@csn.ul.ie>
	<20100413202021.GZ13327@think>
	<20100414014041.GD2493@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 11:40:41 +1000
Dave Chinner <david@fromorbit.com> wrote:

>  50)     3168      64   xfs_vm_writepage+0xab/0x160 [xfs]
>  51)     3104     384   shrink_page_list+0x65e/0x840
>  52)     2720     528   shrink_zone+0x63f/0xe10

A bit OFF TOPIC.

Could you share disassemble of shrink_zone() ?

In my environ.
00000000000115a0 <shrink_zone>:
   115a0:       55                      push   %rbp
   115a1:       48 89 e5                mov    %rsp,%rbp
   115a4:       41 57                   push   %r15
   115a6:       41 56                   push   %r14
   115a8:       41 55                   push   %r13
   115aa:       41 54                   push   %r12
   115ac:       53                      push   %rbx
   115ad:       48 83 ec 78             sub    $0x78,%rsp
   115b1:       e8 00 00 00 00          callq  115b6 <shrink_zone+0x16>
   115b6:       48 89 75 80             mov    %rsi,-0x80(%rbp)

disassemble seems to show 0x78 bytes for stack. And no changes to %rsp
until retrun.

I may misunderstand something...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
