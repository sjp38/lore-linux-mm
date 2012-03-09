Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 3D0A16B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:31:39 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B90B63EE0B5
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:31:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FBFC45DE5A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:31:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87EB845DE56
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:31:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A8961DB8052
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:31:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 317E51DB8049
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:31:37 +0900 (JST)
Date: Fri, 9 Mar 2012 10:30:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 4/7] mm: rework __isolate_lru_page() page lru filter
Message-Id: <20120309103006.2450d02d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120308180415.27621.23390.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
	<20120308180415.27621.23390.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 08 Mar 2012 22:04:15 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patch adds lru bit mask into lower byte of isolate_mode_t,
> this allows to simplify checks in __isolate_lru_page().
> 
> v5:
> * lru bit mask instead of special file/anon active/inactive bits
> * mark page_lru() as __always_inline, it helps gcc generate more compact code
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> 

Nice !

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
