Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id E865F6B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:17:13 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 833593EE0BD
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:17:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6612845DE7E
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:17:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D85245DEA6
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:17:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C0B31DB803F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:17:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D984F1DB8042
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:17:11 +0900 (JST)
Date: Tue, 28 Feb 2012 09:15:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 04/21] memcg: use vm_swappiness from target memory
 cgroup
Message-Id: <20120228091543.1710a1eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135156.12988.47908.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135156.12988.47908.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:51:56 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Use vm_swappiness from memory cgroup which is triggered this memory reclaim.
> This is more reasonable and allows to kill one argument.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Hmm... it may be better to disallow to have different swappiness in a hierarchy..

>From me,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But I wonder other guys may have different idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
