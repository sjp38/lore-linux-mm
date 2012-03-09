Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 6FCDE6B004D
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:29:36 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F3AFA3EE0BC
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:29:34 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DABAA45DE58
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:29:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C248D45DE56
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:29:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A8EF51DB8053
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:29:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D8A21DB804A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:29:34 +0900 (JST)
Date: Fri, 9 Mar 2012 10:28:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 3/7] mm: push lru index into shrink_[in]active_list()
Message-Id: <20120309102805.fe90409b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120308180410.27621.90384.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
	<20120308180410.27621.90384.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 08 Mar 2012 22:04:10 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Let's toss lru index through call stack to isolate_lru_pages(),
> this is better than its reconstructing from individual bits.
> 
> v5:
> * move patch upper
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
