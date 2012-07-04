Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 9211D6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 02:43:43 -0400 (EDT)
Received: by yenr5 with SMTP id r5so7503641yen.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 23:43:42 -0700 (PDT)
Date: Tue, 3 Jul 2012 23:43:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch] mm/policy: use int instead of unsigned for nid
In-Reply-To: <1341370901-14187-1-git-send-email-amwang@redhat.com>
Message-ID: <alpine.DEB.2.00.1207032342120.32556@chino.kir.corp.google.com>
References: <1341370901-14187-1-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, WANG Cong <xiyou.wangcong@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Wed, 4 Jul 2012, Cong Wang wrote:

> From: WANG Cong <xiyou.wangcong@gmail.com>
> 
> 'nid' should be 'int', not 'unsigned'.
> 

unsigned is already of type int, so you're saying these occurrences should 
become signed, but that's not true since they never return NUMA_NO_NODE.  
They are all safe returning unsigned.

And alloc_page_interleave() doesn't exist anymore since the sched/numa 
bits were merged into sched/core, so nobody could apply this patch anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
