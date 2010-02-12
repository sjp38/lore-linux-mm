Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 589C36B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 03:04:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C848Oe016779
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 12 Feb 2010 17:04:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 70B7745DE70
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:04:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9230D45DE4D
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:04:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D300E18003
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:04:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 296631DB8037
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:04:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
In-Reply-To: <4B7504D2.1040903@nortel.com>
References: <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com> <4B7504D2.1040903@nortel.com>
Message-Id: <20100212170248.73B8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 12 Feb 2010 17:04:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

>   backtrace:
>     [<ffffffff8061c162>] kmemleak_alloc_page+0x1eb/0x380
>     [<ffffffff80276ae8>] __pagevec_lru_add_active+0xb6/0x104
>     [<ffffffff80276b85>] lru_cache_add_active+0x4f/0x53
>     [<ffffffff8027d182>] do_wp_page+0x355/0x6f6
>     [<ffffffff8027eef1>] handle_mm_fault+0x62b/0x77c
>     [<ffffffff80632557>] do_page_fault+0x3c7/0xba0
>     [<ffffffff8062fb79>] error_exit+0x0/0x51
>     [<ffffffffffffffff>] 0xffffffffffffffff
> 
> and
> 
>   backtrace:
>     [<ffffffff8061c162>] kmemleak_alloc_page+0x1eb/0x380
>     [<ffffffff80276ae8>] __pagevec_lru_add_active+0xb6/0x104
>     [<ffffffff80276b85>] lru_cache_add_active+0x4f/0x53
>     [<ffffffff8027eddc>] handle_mm_fault+0x516/0x77c
>     [<ffffffff8027f180>] get_user_pages+0x13e/0x462
>     [<ffffffff802a2f65>] get_arg_page+0x6a/0xca
>     [<ffffffff802a30bf>] copy_strings+0xfa/0x1d4
>     [<ffffffff802a31c7>] copy_strings_kernel+0x2e/0x43
>     [<ffffffff802d33fb>] compat_do_execve+0x1fa/0x2fd
>     [<ffffffff8021e405>] sys32_execve+0x44/0x62
>     [<ffffffff8021def5>] ia32_ptregs_common+0x25/0x50
>     [<ffffffffffffffff>] 0xffffffffffffffff
> 
> I'll dig into them further, but do either of these look like known issues?

no known issue.
AFAIK, 2.6.27 - 2.6.33 don't have such problem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
