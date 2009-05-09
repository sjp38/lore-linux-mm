Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 22D306B00A9
	for <linux-mm@kvack.org>; Sat,  9 May 2009 04:13:32 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n498DgHh004079
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 9 May 2009 17:13:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AF9845DE56
	for <linux-mm@kvack.org>; Sat,  9 May 2009 17:13:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 04AAC45DE51
	for <linux-mm@kvack.org>; Sat,  9 May 2009 17:13:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE3641DB803E
	for <linux-mm@kvack.org>; Sat,  9 May 2009 17:13:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 876561DB803B
	for <linux-mm@kvack.org>; Sat,  9 May 2009 17:13:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] pagemap: document 9 more exported page flags
In-Reply-To: <20090508111031.568178884@intel.com>
References: <20090508105320.316173813@intel.com> <20090508111031.568178884@intel.com>
Message-Id: <20090509171125.8D08.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat,  9 May 2009 17:13:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Also add short descriptions for all of the 20 exported page flags.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  Documentation/vm/pagemap.txt |   62 +++++++++++++++++++++++++++++++++
>  1 file changed, 62 insertions(+)
> 
> --- linux.orig/Documentation/vm/pagemap.txt
> +++ linux/Documentation/vm/pagemap.txt
> @@ -49,6 +49,68 @@ There are three components to pagemap:
>       8. WRITEBACK
>       9. RECLAIM
>      10. BUDDY
> +    11. MMAP
> +    12. ANON
> +    13. SWAPCACHE
> +    14. SWAPBACKED
> +    15. COMPOUND_HEAD
> +    16. COMPOUND_TAIL
> +    16. HUGE

nit. 16 appear twice.



> +    18. UNEVICTABLE
> +    20. NOPAGE


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
