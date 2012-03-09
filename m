Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 6E3806B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:27:45 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0A6863EE0BB
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:27:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3B2345DE5C
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:27:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA2A845DE56
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:27:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA7581DB8053
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:27:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FF811DB804A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:27:43 +0900 (JST)
Date: Fri, 9 Mar 2012 10:26:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 1/7] mm/memcg: scanning_global_lru means
 mem_cgroup_disabled
Message-Id: <20120309102611.2f529749.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120308180401.27621.31137.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
	<20120308180401.27621.31137.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 08 Mar 2012 22:04:01 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> From: Hugh Dickins <hughd@google.com>
> 
> Although one has to admire the skill with which it has been concealed,
> scanning_global_lru(mz) is actually just an interesting way to test
> mem_cgroup_disabled().  Too many developer hours have been wasted on
> confusing it with global_reclaim(): just use mem_cgroup_disabled().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

If no changes since v4, please show Acks you got.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
