Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 78AAF6B01B6
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1pdGo025978
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:39 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 67C0745DE52
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4352345DE4E
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 255FC1DB804A
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CED3B1DB803C
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] oom: use same_thread_group instead comparing ->mm
In-Reply-To: <20100616151547.GF9278@barrios-desktop>
References: <20100616203319.72E6.A69D9226@jp.fujitsu.com> <20100616151547.GF9278@barrios-desktop>
Message-Id: <20100617084452.FB39.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 16, 2010 at 08:34:02PM +0900, KOSAKI Motohiro wrote:
> > Now, oom are using "child->mm != p->mm" check to distinguish subthread.
> > But It's incorrect. vfork() child also have the same ->mm.
> > 
> > This patch change to use same_thread_group() instead.
> 
> Hmm. I think we don't use it to distinguish subthread. 
> We use it for finding child process which is not vforked. 
> 
> I can't understand your point. 

Thank you. my fault. respin.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
