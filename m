Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6668E6B02B5
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 12:06:13 -0400 (EDT)
Received: by iwn2 with SMTP id 2so1863054iwn.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 09:06:15 -0700 (PDT)
Date: Fri, 20 Aug 2010 01:05:42 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/2] oom: fix tasklist_lock leak
Message-ID: <20100819160542.GH6805@barrios-desktop>
References: <20100819194707.5FC4.A69D9226@jp.fujitsu.com>
 <20100819195346.5FCA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819195346.5FCA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 07:54:06PM +0900, KOSAKI Motohiro wrote:
> commit 0aad4b3124 (oom: fold __out_of_memory into out_of_memory)
> introduced tasklist_lock leak. Then it caused following obvious
> danger warings and panic.
> 
>     ================================================
>     [ BUG: lock held when returning to user space! ]
>     ------------------------------------------------
>     rsyslogd/1422 is leaving the kernel with locks still held!
>     1 lock held by rsyslogd/1422:
>      #0:  (tasklist_lock){.+.+.+}, at: [<ffffffff810faf64>] out_of_memory+0x164/0x3f0
>     BUG: scheduling while atomic: rsyslogd/1422/0x00000002
>     INFO: lockdep is turned off.
> 
> This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
