Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 6538A6B005C
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 02:03:42 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0EA403EE0BD
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:03:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EBAB045DE56
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:03:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5A1145DE58
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:03:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA2961DB8045
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:03:40 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C0F51DB8049
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:03:40 +0900 (JST)
Date: Mon, 26 Dec 2011 16:02:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: memcg: clean up fault accounting fix
Message-Id: <20111226160230.f934d46b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1324580874-8467-1-git-send-email-hannes@cmpxchg.org>
References: <1324580874-8467-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, 22 Dec 2011 20:07:54 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Signed-off-by: Knucklehead <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
