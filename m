Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 667FE6B006C
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 10:29:25 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: khugepaged doesn't want to freeze
Date: Tue,  8 Nov 2011 16:29:10 +0100
Message-Id: <1320766151-2619-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <4EB8E969.6010502@suse.cz>
References: <4EB8E969.6010502@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@suse.com>
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

[PATCH] thp: reduce khugepaged freezing latency

Beware patch untested but I suspect the problem was the lack of
wakeup during long schedule_timeout. And a missing try_to_freeze in
case alloc_hugepage repeatedly fails in the CONFIG_NUMA=n case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
