Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 36DC56B00EA
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 19:24:46 -0500 (EST)
Received: by dadv6 with SMTP id v6so2526359dad.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 16:24:45 -0800 (PST)
Date: Fri, 2 Mar 2012 16:24:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/7] mm: push lru index into shrink_[in]active_list()
In-Reply-To: <20120229091551.29236.27110.stgit@zurg>
Message-ID: <alpine.LSU.2.00.1203021623190.3578@eggly.anvils>
References: <20120229090748.29236.35489.stgit@zurg> <20120229091551.29236.27110.stgit@zurg>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Feb 2012, Konstantin Khlebnikov wrote:

> Let's toss lru index through call stack to isolate_lru_pages(),
> this is better than its reconstructing from individual bits.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Yes, this is an improvement, thanks:

Acked-by: Hugh Dickins <hughd@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
