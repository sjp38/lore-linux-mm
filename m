Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 7A7256B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 20:40:07 -0500 (EST)
Received: by iajr24 with SMTP id r24so12336528iaj.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 17:40:06 -0800 (PST)
Date: Wed, 7 Mar 2012 17:40:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, counters: remove task argument to sync_mm_rss
 and __sync_task_rss_stat
In-Reply-To: <20120307171155.f9bb71b6.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1203071739150.26591@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061919260.21806@chino.kir.corp.google.com> <20120307171155.f9bb71b6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 Mar 2012, Andrew Morton wrote:

> hm, with my gcc it's beneficial to cache `current' in a local.  But
> when I tried that, Weird Things happened, because gcc has gone and
> decided to inline __sync_task_rss_stat() into its callers.  I don't see
> how that could have been the right thing to do.
> 

c06b1fca18c3 offers some advice :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
