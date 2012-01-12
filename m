Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 679A26B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 21:29:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F1A2B3EE0B5
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 11:29:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D1E1445DE4D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 11:29:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BD3EC45DD74
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 11:29:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF44CE08001
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 11:29:36 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67F981DB802C
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 11:29:36 +0900 (JST)
Date: Thu, 12 Jan 2012 11:28:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: vmscan: deactivate isolated pages with lru lock
 released
Message-Id: <20120112112826.f4a8acea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBAiAfyXBcn+9WO6AERthyx+C=cNP-romp9YJO3Hn7-U-g@mail.gmail.com>
References: <CAJd=RBAiAfyXBcn+9WO6AERthyx+C=cNP-romp9YJO3Hn7-U-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 11 Jan 2012 20:45:07 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> Spinners on other CPUs, if any, could take the lru lock and do their jobs while
> isolated pages are deactivated on the current CPU if the lock is released
> actively. And no risk of race raised as pages are already queued on locally
> private list.
> 
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Doesn't this increase the number of lock/unlock ?
Hmm, isn't it better to integrate clear_active_flags to isolate_pages() ?
Then we don't need list scan.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
