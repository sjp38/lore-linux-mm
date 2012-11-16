Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 2514A6B0071
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 05:16:54 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 359313EE0BB
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 19:16:52 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B57745DE55
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 19:16:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0032045DE4E
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 19:16:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E623B1DB8042
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 19:16:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ABA01DB803B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 19:16:51 +0900 (JST)
Message-ID: <50A6127D.10203@jp.fujitsu.com>
Date: Fri, 16 Nov 2012 19:16:29 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Correct description of SwapFree in Documentation/filesystems/proc.txt
References: <50A5E4D6.60301@gmail.com>
In-Reply-To: <50A5E4D6.60301@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Jim Paris <jim@jtan.com>

(2012/11/16 16:01), Michael Kerrisk wrote:
> After migrating most of the information in
> Documentation/filesystems/proc.txt to the proc(5) man page,
> Jim Paris pointed out to me that the description of SwapFree
> in the man page seemed wrong. I think Jim is right,
> but am given pause by fact that that text has been in
> Documentation/filesystems/proc.txt since at least 2.6.0.
> Anyway, I believe that the patch below fixes things.
>
> Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>
>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

>
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index a1793d6..cf4260f 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -778,8 +778,7 @@ AnonHugePages:   49152 kB
>                 other things, it is where everything from the Slab is
>                 allocated.  Bad things happen when you're out of lowmem.
>      SwapTotal: total amount of swap space available
> -    SwapFree: Memory which has been evicted from RAM, and is temporarily
> -              on the disk
> +    SwapFree: Amount of swap space that is currently unused.
>          Dirty: Memory which is waiting to get written back to the disk
>      Writeback: Memory which is actively being written back to the disk
>      AnonPages: Non-file backed pages mapped into userspace page tables
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
