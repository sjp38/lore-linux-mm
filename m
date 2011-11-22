Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBEB6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 20:07:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3A6A53EE0AE
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 10:07:23 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 252C145DE4E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 10:07:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E98E45DD6E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 10:07:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 00EB51DB803C
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 10:07:23 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BAA631DB803E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 10:07:22 +0900 (JST)
Date: Tue, 22 Nov 2011 10:06:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix the document of pgpgin/pgpgout
Message-Id: <20111122100618.6d5fbd97.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1321922925-14930-1-git-send-email-yinghan@google.com>
References: <1321922925-14930-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wanlong Gao <gaowanlong@cn.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon, 21 Nov 2011 16:48:45 -0800
Ying Han <yinghan@google.com> wrote:

> The two memcg stats pgpgin/pgpgout have different meaning than the ones in
> vmstat, which indicates that we picked a bad naming for them. It might be late
> to change the stat name, but better documentation is always helpful.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
