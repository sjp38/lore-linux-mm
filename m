Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 17DC06B004D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 16:48:32 -0400 (EDT)
Received: by iajr24 with SMTP id r24so1796352iaj.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 13:48:31 -0700 (PDT)
Date: Tue, 13 Mar 2012 13:48:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] page_alloc.c: kill add_from_early_node_map
In-Reply-To: <1331652720-3054-1-git-send-email-consul.kautuk@gmail.com>
Message-ID: <alpine.DEB.2.00.1203131348160.27008@chino.kir.corp.google.com>
References: <1331652720-3054-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 13 Mar 2012, Kautuk Consul wrote:

> No one seems to be calling add_from_early_node_map anywhere from the
> kernel.
> 
> Also, deleting this function decreases page_alloc.o file size.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
