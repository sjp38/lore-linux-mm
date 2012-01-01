Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 572556B00AC
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 03:17:57 -0500 (EST)
Received: by qcsd17 with SMTP id d17so10888182qcs.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 00:17:56 -0800 (PST)
Message-ID: <4F0016B2.5080705@gmail.com>
Date: Sun, 01 Jan 2012 03:17:54 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] mm: fewer underscores in ____pagevec_lru_add
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils> <alpine.LSU.2.00.1112312339550.18500@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112312339550.18500@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

(1/1/12 2:41 AM), Hugh Dickins wrote:
> What's so special about ____pagevec_lru_add() that it needs four
> leading underscores?  Nothing, it just helped to distinguish from
> __pagevec_lru_add() in 2.6.28 development.  Cut two leading underscores.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Yes, this is just historical reason.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
