Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 98DC26B00AE
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 03:18:39 -0500 (EST)
Received: by qcsd17 with SMTP id d17so10888290qcs.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 00:18:38 -0800 (PST)
Message-ID: <4F0016D9.2060506@gmail.com>
Date: Sun, 01 Jan 2012 03:18:33 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] mm: no blank line after EXPORT_SYMBOL in swap.c
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils> <alpine.LSU.2.00.1112312341340.18500@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112312341340.18500@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

(1/1/12 2:42 AM), Hugh Dickins wrote:
> checkpatch rightly protests
> WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> so fix the five offenders in mm/swap.c.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
