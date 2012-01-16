Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 22D756B004F
	for <linux-mm@kvack.org>; Sun, 15 Jan 2012 19:29:25 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0EC513EE0BC
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 09:29:18 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E6A1C45DEAD
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 09:29:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CE10D45DE9E
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 09:29:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C039D1DB803F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 09:29:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 787311DB8038
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 09:29:17 +0900 (JST)
Date: Mon, 16 Jan 2012 09:27:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: vmscan: handle isolated pages with lru lock
 released
Message-Id: <20120116092745.7721ff31.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBAH4+nFQ35JcHju6eSPfDcQpbkJjMX6GBaZFECVaL2swA@mail.gmail.com>
References: <CAJd=RBANeF+TTTtn=F_Yx3N5KkVb5vFPY6FNYEjVntB1pPSLBA@mail.gmail.com>
	<CAJd=RBAH4+nFQ35JcHju6eSPfDcQpbkJjMX6GBaZFECVaL2swA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 14 Jan 2012 20:05:11 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> On Fri, Jan 13, 2012 at 11:00 PM, Hillf Danton <dhillf@gmail.com> wrote:

> ===cut here===
> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: vmscan: handle isolated pages with lru lock released
> 
> When shrinking inactive lru list, isolated pages are queued on locally private
> list, so the lock-hold time could be reduced if pages are counted without lock
> protection. To achive that, firstly updating reclaim stat is delayed until the
> putback stage, which is pointed out by Hugh, after reacquiring the lru lock.
> 
> Secondly operations related to vm and zone stats, are now proteced with
> preemption disabled as they are per-cpu operation.
> 
> Thanks for comments and ideas received.
> 
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Nice.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
