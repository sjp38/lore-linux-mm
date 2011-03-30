Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ACCD18D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 22:32:25 -0400 (EDT)
Received: by pvg4 with SMTP id 4so192635pvg.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:32:22 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: Re: [PATCH] Stack trace dedup
In-Reply-To: <1301419696-2045-1-git-send-email-yinghan@google.com> (Ying Han's
	message of "Tue, 29 Mar 2011 10:28:16 -0700")
References: <1301419696-2045-1-git-send-email-yinghan@google.com>
Date: Wed, 30 Mar 2011 11:32:12 +0900
Message-ID: <87pqp92v9v.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyu <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

Ying Han <yinghan@google.com> writes:

> This doesn't build.

Please check out the commit e8e999cf3cc7 ("x86, dumpstack: Correct stack
dump info when frame pointer is available"). Most of internal stack
trace functions now requires additional @bp argument.

Thanks.

--
Regards,
Namhyung Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
