Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id DA92C6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:35:24 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 27E0F3EE0BB
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:35:23 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 119CC45DE52
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:35:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DBBDB45DE4F
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:35:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CDADF1DB803F
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:35:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 85FCD1DB8037
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:35:22 +0900 (JST)
Date: Fri, 9 Mar 2012 10:33:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 7/7] mm/memcg: use vm_swappiness from target memory
 cgroup
Message-Id: <20120309103351.d6757a31.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120308180430.27621.99232.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
	<20120308180430.27621.99232.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 08 Mar 2012 22:04:30 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Use vm_swappiness from memory cgroup which is triggered this memory reclaim.
> This is more reasonable and allows to kill one argument.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>

Thank you for your works!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
