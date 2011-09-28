Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3EBDE9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:04:27 -0400 (EDT)
Received: from mail-vx0-f169.google.com (mail-vx0-f169.google.com [209.85.220.169])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 28121DBCB5
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 23:04:09 +0800 (CST)
Received: by vcbfo14 with SMTP id fo14so6652222vcb.14
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 08:04:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317174330-2677-1-git-send-email-minchan.kim@gmail.com>
References: <1317174330-2677-1-git-send-email-minchan.kim@gmail.com>
Date: Wed, 28 Sep 2011 23:04:05 +0800
Message-ID: <CAF1ivSaf8ER9yDWohudy-huiq5QHS8vE04R+4+nPTQihZ2MAmQ@mail.gmail.com>
Subject: Re: [PATCH] vmscan: add barrier to prevent evictable page in
 unevictable list
From: Lin Ming <mlin@ss.pku.edu.cn>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>

On Wed, Sep 28, 2011 at 9:45 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> When racing between putback_lru_page and shmem_unlock happens,

s/shmem_unlock/shmem_lock/

> progrom execution order is as follows, but clear_bit in processor #1
> could be reordered right before spin_unlock of processor #1.
> Then, the page would be stranded on the unevictable list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
