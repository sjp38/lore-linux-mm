Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id F107D6B004D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 04:36:14 -0500 (EST)
Received: by qadc16 with SMTP id c16so11059431qad.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 01:36:14 -0800 (PST)
Message-ID: <4F002907.8090008@gmail.com>
Date: Sun, 01 Jan 2012 04:36:07 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] mm: remove isolate_pages
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils> <alpine.LSU.2.00.1112312345250.18500@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112312345250.18500@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

(1/1/12 2:46 AM), Hugh Dickins wrote:
> The isolate_pages() level in vmscan.c offers little but indirection:
> merge it into isolate_lru_pages() as the compiler does, and use the
> names nr_to_scan and nr_scanned in each case.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
>   mm/vmscan.c |   61 ++++++++++++++++++++++----------------------------
>   1 file changed, 27 insertions(+), 34 deletions(-)

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
