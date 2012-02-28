Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 17B526B007E
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:47:00 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 924DB3EE0C0
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:46:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A48A45DE52
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:46:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F1F345DE4F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:46:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 404001DB803F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:46:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC2B51DB8037
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:46:57 +0900 (JST)
Date: Tue, 28 Feb 2012 09:45:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 13/21] mm: push lruvecs from pagevec_lru_move_fn() to
 iterator
Message-Id: <20120228094533.f91b7720.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135242.12988.38183.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135242.12988.38183.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:52:42 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Push lruvec pointer from pagevec_lru_move_fn() to iterator function.
> Push lruvec pointer into lru_add_page_tail()
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
