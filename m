Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id B3DFD6B0062
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 23:50:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 54CE43EE0AE
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:50:24 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2997345DE6B
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:50:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 10A4945DE6A
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:50:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EF1321DB8044
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:50:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A2D611DB8040
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:50:23 +0900 (JST)
Date: Thu, 12 Jan 2012 13:49:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 3/3] mm, oom: do not emit oom killer warning if chosen
 thread is already exiting
Message-Id: <20120112134911.70041510.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1201111924050.3982@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1201111924050.3982@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 11 Jan 2012 19:24:28 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> If a thread is chosen for oom kill and is already PF_EXITING, then the
> oom killer simply sets TIF_MEMDIE and returns.  This allows the thread to
> have access to memory reserves so that it may quickly exit.  This logic
> is preceeded with a comment saying there's no need to alarm the sysadmin.
> This patch adds truth to that statement.
> 
> There's no need to emit any warning about the oom condition if the thread
> is already exiting since it will not be killed.  In this condition, just
> silently return the oom killer since its only giving access to memory
> reserves and is otherwise a no-op.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
