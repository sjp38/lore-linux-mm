Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 671AA6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 19:18:20 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 13B303EE0AE
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:18:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B647945DE5E
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:18:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A1BF45DE5B
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:18:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 875221DB8052
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:18:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F26E1DB804E
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:18:18 +0900 (JST)
Date: Wed, 21 Dec 2011 09:17:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] page_alloc: break early in
 check_for_regular_memory()
Message-Id: <20111221091706.aed44254.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1324375359-31306-1-git-send-email-lliubbo@gmail.com>
References: <1324375359-31306-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, tj@kernel.org, aarcange@redhat.com

On Tue, 20 Dec 2011 18:02:39 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> If there is a zone below ZONE_NORMAL has present_pages, we can set
> node state to N_NORMAL_MEMORY, no need to loop to end.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
