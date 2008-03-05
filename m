Received: by hs-out-0708.google.com with SMTP id j58so728361hsj.6
        for <linux-mm@kvack.org>; Tue, 04 Mar 2008 16:47:36 -0800 (PST)
Message-ID: <47CDEA95.9050507@gmail.com>
Date: Wed, 05 Mar 2008 09:34:29 +0900
MIME-Version: 1.0
Subject: Re: [patch 11/20] No Reclaim LRU Infrastructure
References: <20080304225157.573336066@redhat.com> <20080304225227.455963956@redhat.com>
In-Reply-To: <20080304225227.455963956@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
From: minchan Kim <minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi, Rik.

This is another trivial thing.

 > /*
 >  * Drain pages out of the cpu's pagevecs.
 >  * Either "cpu" is the current CPU, and preemption has already been
 >@@ -353,6 +375,8 @@ void release_pages(struct page **pages,
 >
 > 		if (PageLRU(page)) {
 > 			struct zone *pagezone = page_zone(page);
 >+			int is_lru_page;
 >+
 > 			if (pagezone != zone) {
 > 				if (zone)
 > 					spin_unlock_irqrestore(&zone->lru_lock,

We don't use is_lru_page any more.
It cause warning at compile time.

We can remove is_lru_page local variable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
