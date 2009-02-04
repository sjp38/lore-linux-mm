Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A06A86B003D
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 21:51:52 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n142pnjY019769
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 4 Feb 2009 11:51:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AD9D45DD7C
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:51:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B9E445DD77
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:51:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7893E1DB803F
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:51:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E26A81DB8049
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:51:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] fix mlocked page counter mistmatch
In-Reply-To: <20090204024447.GB6212@barrios-desktop>
References: <20090204103648.ECAF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090204024447.GB6212@barrios-desktop>
Message-Id: <20090204115047.ECB5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  4 Feb 2009 11:51:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > Could you please teach me why this issue doesn't happend on munlockall()?
> > your scenario seems to don't depend on exit_mmap().
> 
> 
> Good question.
> It's a different issue.
> It is related to mmap_sem locking issue. 
> 
> Actually, I am about to make a patch.
> But, I can't understand that Why try_do_mlock_page should downgrade mm_sem ?
> Is it necessary ? 
> 
> In munlockall path, mmap_sem already is holding in write-mode of mmap_sem.
> so, try_to_mlock_page always fail to downgrade mmap_sem.
> It's why it looks like working well about mlocked counter. 

lastest linus tree don't have downgrade mmap_sem.
(recently it was removed)

please see it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
