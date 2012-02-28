Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id AA9176B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:38:02 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 34A923EE0BC
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:38:01 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 14E6C45DEBA
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:38:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EE15245DEA6
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:38:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E05641DB8042
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:38:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 962F11DB8044
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:38:00 +0900 (JST)
Date: Tue, 28 Feb 2012 09:36:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 08/21] mm: unify inactive_list_is_low()
Message-Id: <20120228093636.239f5d75.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135219.12988.94138.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135219.12988.94138.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:52:19 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Unify memcg and non-memcg logic, always use exact counters from struct lruvec.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Nice.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
