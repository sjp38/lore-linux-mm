Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 325AF8D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:32:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4668A3EE0BD
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:32:34 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D5DB45DE55
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:32:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 16B1145DE4E
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:32:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06BCB1DB803F
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:32:34 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C7ED71DB8038
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:32:33 +0900 (JST)
Message-ID: <4DD31397.1090603@jp.fujitsu.com>
Date: Wed, 18 May 2011 09:32:23 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org> <1305580757-13175-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305580757-13175-3-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.stultz@linaro.org
Cc: linux-kernel@vger.kernel.org, tytso@mit.edu, rientjes@google.com, dave@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

(2011/05/17 6:19), John Stultz wrote:
> Accessing task->comm requires proper locking. However in the past
> access to current->comm could be done without locking. This
> is no longer the case, so all comm access needs to be done
> while holding the comm_lock.
> 
> In my attempt to clean up unprotected comm access, I've noticed
> most comm access is done for printk output. To simplify correct
> locking in these cases, I've introduced a new %ptc format,
> which will print the corresponding task's comm.
> 
> Example use:
> printk("%ptc: unaligned epc - sending SIGBUS.\n", current);
> 
> CC: Ted Ts'o<tytso@mit.edu>
> CC: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> CC: David Rientjes<rientjes@google.com>
> CC: Dave Hansen<dave@linux.vnet.ibm.com>
> CC: Andrew Morton<akpm@linux-foundation.org>
> CC: linux-mm@kvack.org
> Signed-off-by: John Stultz<john.stultz@linaro.org>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
