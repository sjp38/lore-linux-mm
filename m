Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2212A6B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 19:28:55 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 6/9] mm: assert that get_page_unless_zero() callers hold the rcu lock
References: <1313740111-27446-1-git-send-email-walken@google.com>
	<1313740111-27446-7-git-send-email-walken@google.com>
Date: Fri, 19 Aug 2011 16:28:53 -0700
In-Reply-To: <1313740111-27446-7-git-send-email-walken@google.com> (Michel
	Lespinasse's message of "Fri, 19 Aug 2011 00:48:28 -0700")
Message-ID: <m2bovlhtfu.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

Michel Lespinasse <walken@google.com> writes:
>
> Other call sites in memory_hotplug.c, memory_failure.c and hwpoison-inject.c
> are also exempted. It would be preferable if someone more familiar with

I see no reason why hwpoison-inject needs to be exempted. If it doesn't
hold rcu read lock it should.
-Andi

 

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
