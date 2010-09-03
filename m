Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E77F96B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 22:40:14 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o832e9BL005681
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 3 Sep 2010 11:40:09 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 74A9445DE51
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:40:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 431FF45DE4E
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:40:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FD711DB801E
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:40:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C1A5D1DB8019
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 11:40:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Add trace points to mmap, munmap, and brk
In-Reply-To: <1283435985-21934-2-git-send-email-emunson@mgebm.net>
References: <1283435985-21934-1-git-send-email-emunson@mgebm.net> <1283435985-21934-2-git-send-email-emunson@mgebm.net>
Message-Id: <20100903113904.B665.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  3 Sep 2010 11:40:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This patch adds trace points to mmap, munmap, and brk that will report
> relevant addresses and sizes before each function exits successfully.
> 
> Signed-off-by: Eric B Munson <emunson@mgebm.net>

These tracepoint are still poor than syscall trace. I don't think this is
good idea. Please avoid fixed specific tracepoint. Please consider make generic.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
