Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 380A46B006A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 08:02:20 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n73CLjQd022863
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 3 Aug 2009 21:21:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5504D45DE6E
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:21:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3545945DE60
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:21:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10C211DB8044
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:21:45 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B1A8F1DB804A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:21:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
References: <77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com> <alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
Message-Id: <20090803212059.CC2C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  3 Aug 2009 21:21:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sat, 1 Aug 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Summarizing I think now .....
> >   - rename mm->oom_adj as mm->effective_oom_adj
> >   - re-add per-thread oom_adj
> >   - update mm->effective_oom_adj based on per-thread oom_adj
> >   - if necessary, plz add read-only /proc/pid/effective_oom_adj file.
> >     or show 2 values in /proc/pid/oom_adj
> >   - rewrite documentation about oom_score.
> >    " it's calclulated from  _process's_ memory usage and oom_adj of
> >     all threads which shares a memor  context".
> >    This behavior is not changed from old implemtation, anyway.
> >  - If necessary, rewrite oom_kill itself to scan only thread group
> >    leader. It's a way to go regardless of  vfork problem.
> > 
> 
> Ok, so you've abandoned the signal_struct proposal and now want to add it 
> back to task_struct with an effective member in mm_struct by changing the 
> documentation.  Hmm.

Oops, please see From line. The page was made from me ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
