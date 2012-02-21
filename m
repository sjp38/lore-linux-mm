Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 8D4AD6B004D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:04:44 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 703BD3EE0C1
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:04:42 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 57C7545DE50
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:04:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EDBD45DE53
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:04:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DDB21DB802F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:04:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE95A1DB803B
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:04:41 +0900 (JST)
Date: Tue, 21 Feb 2012 17:03:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/10] mm/memcg: scanning_global_lru means
 mem_cgroup_disabled
Message-Id: <20120221170306.3fd147b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202201526540.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
	<alpine.LSU.2.00.1202201526540.23274@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012 15:28:21 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Although one has to admire the skill with which it has been concealed,
> scanning_global_lru(mz) is actually just an interesting way to test
> mem_cgroup_disabled().  Too many developer hours have been wasted on
> confusing it with global_reclaim(): just use mem_cgroup_disabled().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Ah, ok. Now we have global_reclaim() and scanning_global_lru() but
scanning_global_lru() is obsolete now.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
