Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BDD91900118
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:46:13 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4GKk94Y027464
	for <linux-mm@kvack.org>; Mon, 16 May 2011 13:46:10 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by wpaz24.hot.corp.google.com with ESMTP id p4GKjlGE012049
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 13:46:08 -0700
Received: by pwi6 with SMTP id 6so2864351pwi.4
        for <linux-mm@kvack.org>; Mon, 16 May 2011 13:46:08 -0700 (PDT)
Date: Mon, 16 May 2011 13:46:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: OOM Killer don't works at all if the system have >gigabytes
 memory (was Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable())
In-Reply-To: <958295827.17529.1305269596598.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1105161343120.4353@chino.kir.corp.google.com>
References: <958295827.17529.1305269596598.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Fri, 13 May 2011, CAI Qian wrote:

> I have had a chance to test this patch after applied this patch manually
> (dd not apply cleanly) on the top of mainline kernel. The test is still
> running because it is trying to kill tons of python processes instread
> of the parent. Isn't there a way for oom to be smart enough to do
> "killall python"?

Not without userspace doing that explicitly, the oom killer attempts to 
only kill the most memory-hogging task to free memory.  If you're test is 
constantly forking new processes which allocate memory then the oom killer 
will just keep killing those children anytime it is out of memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
