Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 32A3F6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 20:05:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4C33E3EE0B6
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:05:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3230C45DE52
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:05:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 173F245DE4E
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:05:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 000C51DB8042
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:05:23 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ACD5F1DB803E
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:05:23 +0900 (JST)
Message-ID: <4F9890DB.6080206@jp.fujitsu.com>
Date: Thu, 26 Apr 2012 09:03:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] rename is_mlocked_vma() to mlocked_vma_newpage()
References: <1335375955-32037-1-git-send-email-yinghan@google.com>
In-Reply-To: <1335375955-32037-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

(2012/04/26 2:45), Ying Han wrote:

> Andrew pointed out that the is_mlocked_vma() is misnamed. A function
> with name like that would expect bool return and no side-effects.
> 
> Since it is called on the fault path for new page, rename it in this
> patch.
> 
> Signed-off-by: Ying Han <yinghan@google.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
