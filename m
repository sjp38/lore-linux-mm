Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7D8BD9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 21:03:01 -0400 (EDT)
Received: from mail-qy0-f169.google.com (mail-qy0-f169.google.com [209.85.216.169])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 98194DBCD1
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 09:02:45 +0800 (CST)
Received: by qyl38 with SMTP id 38so3484086qyl.14
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 18:02:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110928180503.GC1696@barrios-desktop>
References: <1317174330-2677-1-git-send-email-minchan.kim@gmail.com>
	<CAF1ivSaf8ER9yDWohudy-huiq5QHS8vE04R+4+nPTQihZ2MAmQ@mail.gmail.com>
	<20110928180503.GC1696@barrios-desktop>
Date: Thu, 29 Sep 2011 09:02:36 +0800
Message-ID: <CAF1ivSbPoC_ngCmwmTC+JJuNxhhSoJyCRhTRcWj9V9VgYwU9jQ@mail.gmail.com>
Subject: Re: [PATCH] vmscan: add barrier to prevent evictable page in
 unevictable list
From: Lin Ming <mlin@ss.pku.edu.cn>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>

On Thu, Sep 29, 2011 at 2:05 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Wed, Sep 28, 2011 at 11:04:05PM +0800, Lin Ming wrote:
>> On Wed, Sep 28, 2011 at 9:45 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
>> > When racing between putback_lru_page and shmem_unlock happens,
>>
>> s/shmem_unlock/shmem_lock/
>
> I did it intentionally for represent shmem_lock with user = 1, lock = 0.
> If you think it makes others confusing, I will change in next version.
> Thanks.

I was confused. Now I understand.

>
>>
>> > progrom execution order is as follows, but clear_bit in processor #1
>> > could be reordered right before spin_unlock of processor #1.
>> > Then, the page would be stranded on the unevictable list.
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
