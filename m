Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id F0A286B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 02:29:25 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4B9463EE0B5
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:29:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30ADA45DE54
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:29:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 16DAC45DE4F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:29:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 050581DB803E
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:29:24 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B47071DB803B
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:29:23 +0900 (JST)
Date: Mon, 26 Dec 2011 16:28:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: hugetlb: avoid bogus counter of surplus huge page
Message-Id: <20111226162813.fee00d84.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBCS3-PoFa3FUVwhiznPTQH5xq7fTYa3m01a0-buACQbCA@mail.gmail.com>
References: <CAJd=RBCS3-PoFa3FUVwhiznPTQH5xq7fTYa3m01a0-buACQbCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

On Fri, 23 Dec 2011 21:38:38 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: hugetlb: avoid bogus counter of surplus huge page
> 
> If we have to hand back the newly allocated huge page to page allocator,
> for any reason, the changed counter should be recovered.
> 
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
