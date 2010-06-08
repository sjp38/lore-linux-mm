Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C5EE16B0215
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:05 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg3AO008097
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 99D4745DE52
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FD5845DE56
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A27B1DB8040
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D541E1DB805B
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 18/18] oom: deprecate oom_adj tunable
In-Reply-To: <alpine.DEB.2.00.1006061527320.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061527320.32225@chino.kir.corp.google.com>
Message-Id: <20100608194514.7654.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:42:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +	/*
> +	 * Warn that /proc/pid/oom_adj is deprecated, see
> +	 * Documentation/feature-removal-schedule.txt.
> +	 */
> +	printk_once(KERN_WARNING "%s (%d): /proc/%d/oom_adj is deprecated, "
> +			"please use /proc/%d/oom_score_adj instead.\n",
> +			current->comm, task_pid_nr(current),
> +			task_pid_nr(task), task_pid_nr(task));
>  	task->signal->oom_adj = oom_adjust;

Sorry, we can't accept this. oom_adj is one of most freqently used
tuning knob. putting this one makes a lot of confusion.

In addition, this knob is used from some applications (please google
by google code search or something else). that said, an enduser can't
stop the warning. that makes a lot of frustration. NO.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
