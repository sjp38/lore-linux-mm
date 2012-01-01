Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 8568B6B00B0
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 03:19:15 -0500 (EST)
Received: by qabg40 with SMTP id g40so8041460qab.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 00:19:14 -0800 (PST)
Message-ID: <4F001700.5050404@gmail.com>
Date: Sun, 01 Jan 2012 03:19:12 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] mm: enum lru_list lru
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils> <alpine.LSU.2.00.1112312342540.18500@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112312342540.18500@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

(1/1/12 2:43 AM), Hugh Dickins wrote:
> Mostly we use "enum lru_list lru": change those few "l"s to "lru"s.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
>   include/linux/mm_inline.h |   26 +++++++++++++-------------
>   include/linux/mmzone.h    |   16 ++++++++--------
>   mm/page_alloc.c           |    6 +++---
>   mm/vmscan.c               |   22 +++++++++++-----------
>   4 files changed, 35 insertions(+), 35 deletions(-)
>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
