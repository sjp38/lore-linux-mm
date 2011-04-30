Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 54BE0900001
	for <linux-mm@kvack.org>; Sat, 30 Apr 2011 12:46:19 -0400 (EDT)
Date: Sat, 30 Apr 2011 09:46:16 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: mmotm 2011-04-29-16-25 uploaded
Message-Id: <20110430094616.1fd43735.rdunlap@xenotime.net>
In-Reply-To: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, 29 Apr 2011 16:26:16 -0700 akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-04-29-16-25 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://zen-kernel.org/kernel/mmotm.git
> 
> It contains the following patches against 2.6.39-rc5:


mm-per-node-vmstat-show-proper-vmstats.patch

when CONFIG_PROC_FS is not enabled:

drivers/built-in.o: In function `node_read_vmstat':
node.c:(.text+0x1e995): undefined reference to `vmstat_text'

from drivers/base/node.c

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
