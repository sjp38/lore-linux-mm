Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 4C4BB6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 21:47:49 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 944F03EE0BB
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 11:47:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CB0545DEEA
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 11:47:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C32D45DEEC
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 11:47:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 503DA1DB803E
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 11:47:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F33061DB803C
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 11:47:46 +0900 (JST)
Date: Wed, 21 Dec 2011 11:46:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: hugetlb: fix pgoff computation when unmapping page
 from vma
Message-Id: <20111221114635.5b866875.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBDC9hxAFbbTvSWVa=t1kuyBH8=UoTYxRDtDm6iXLGkQWg@mail.gmail.com>
References: <CAJd=RBDC9hxAFbbTvSWVa=t1kuyBH8=UoTYxRDtDm6iXLGkQWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 20 Dec 2011 21:45:51 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> The computation for pgoff is incorrect, at least with
> 
> 	(vma->vm_pgoff >> PAGE_SHIFT)
> 
> involved. It is fixed with the available method if HPAGE_SIZE is concerned in
> page cache lookup.
> 
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
