Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AD29C6B01E3
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 20:42:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o320gPo8012852
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 2 Apr 2010 09:42:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D9CDC45DE4D
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:42:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B617445DE4F
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:42:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D7E71DB804C
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:42:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 531AA1DB804B
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:42:24 +0900 (JST)
Date: Fri, 2 Apr 2010 09:38:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 1/5 v2] oom: hold tasklist_lock when dumping tasks
Message-Id: <20100402093829.5fa895dc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1004011242420.13247@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1004011242420.13247@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010 12:44:28 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> dump_header() always requires tasklist_lock to be held because it calls 
> dump_tasks() which iterates through the tasklist.  There are a few places
> where this isn't maintained, so make sure tasklist_lock is always held
> whenever calling dump_header().
> 
> This also fixes the pagefault case where oom_kill_process() is called on
> current without tasklist_lock.  It is necessary to hold a readlock for
> both calling dump_header() and iterating its children.
> 
> Reported-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
