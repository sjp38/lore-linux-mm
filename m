Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id BE33C6B00F0
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:46:09 -0400 (EDT)
Received: by lahi5 with SMTP id i5so5030375lah.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 03:46:07 -0700 (PDT)
Message-ID: <4FB0E26D.9090204@openvz.org>
Date: Mon, 14 May 2012 14:46:05 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: trivial cleanups in vmscan.c
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils> <alpine.LSU.2.00.1205132200150.6148@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205132200150.6148@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> Utter trivia in mm/vmscan.c, mostly just reducing the linecount slightly;
> most exciting change being get_scan_count() calling vmscan_swappiness()
> once instead of twice.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
