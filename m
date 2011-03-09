Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C219E8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 01:43:50 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2F6C13EE0BB
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:43:45 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1497E45DE68
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:43:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EF7E245DE4E
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:43:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E21241DB803A
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:43:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AEB201DB802C
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:43:44 +0900 (JST)
Date: Wed, 9 Mar 2011 15:37:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] vmalloc: remove confusing comment on vwrite()
Message-Id: <20110309153715.153c524b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299652476-5185-1-git-send-email-namhyung@gmail.com>
References: <1299652476-5185-1-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  9 Mar 2011 15:34:36 +0900
Namhyung Kim <namhyung@gmail.com> wrote:

> KM_USER1 is never used for vwrite() path so the caller
> doesn't need to guarantee it is not used. Only the caller
> should guarantee is KM_USER0 and it is commented already.
> 
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> ---

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
