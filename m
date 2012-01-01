Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 143B76B00B2
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 03:22:50 -0500 (EST)
Received: by qcsd17 with SMTP id d17so10888966qcs.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 00:22:49 -0800 (PST)
Message-ID: <4F0017D7.4090301@gmail.com>
Date: Sun, 01 Jan 2012 03:22:47 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] mm: remove del_page_from_lru, add page_off_lru
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils> <alpine.LSU.2.00.1112312343570.18500@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112312343570.18500@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

(1/1/12 2:45 AM), Hugh Dickins wrote:
> del_page_from_lru() repeats del_page_from_lru_list(), also working out
> which LRU the page was on, clearing the relevant bits.  Decouple those
> functions: remove del_page_from_lru() and add page_off_lru().
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
