Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 01BE16B01B4
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:26:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9QLCg006850
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:26:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 812A445DE6E
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BB7145DE60
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 296611DB803E
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CDBAB1DB803B
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] oom: oom_kill_process() doesn't select kthread child
In-Reply-To: <alpine.DEB.2.00.1006211313080.8367@chino.kir.corp.google.com>
References: <20100617104517.FB7D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006211313080.8367@chino.kir.corp.google.com>
Message-Id: <20100630164452.AA3D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:26:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:
> 
> > 
> > Now, select_bad_process() have PF_KTHREAD check, but oom_kill_process
> > doesn't. It mean oom_kill_process() may choose wrong task, especially,
> > when the child are using use_mm().
> > 
> 
> This type of check should be moved to badness(), it will prevent these 
> types of tasks from being selected both in select_bad_process() and 
> oom_kill_process() if the score it returns is 0.

No, process check order of select_bad_process() is certain meaningful.
Only PF_KTHREAD check can move into badness(). Okey, that's fix to
incorrect /proc/<pid>/oom_score issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
