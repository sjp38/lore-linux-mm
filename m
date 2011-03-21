Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6948D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 20:04:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B03A93EE0C1
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:04:24 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 92C3245DE4E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:04:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DD2D45DE61
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:04:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D5721DB803C
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:04:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 158A7E08001
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:04:24 +0900 (JST)
Date: Tue, 22 Mar 2011 08:57:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] memcg: mark init_section_page_cgroup() properly
Message-Id: <20110322085755.c4193fc1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 18 Mar 2011 21:54:13 +0900
Namhyung Kim <namhyung@gmail.com> wrote:

> The commit ca371c0d7e23 ("memcg: fix page_cgroup fatal error
> in FLATMEM") removes call to alloc_bootmem() in the function
> so that it can be marked as __meminit to reduce memory usage
> when MEMORY_HOTPLUG=n.
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/page_cgroup.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5bffada7cde1..2d1a0fa01d7b 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -105,8 +105,7 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
>  	return section->page_cgroup + pfn;
>  }
>  
> -/* __alloc_bootmem...() is protected by !slab_available() */
> -static int __init_refok init_section_page_cgroup(unsigned long pfn)
> +static int __meminit init_section_page_cgroup(unsigned long pfn)
>  {
>  	struct mem_section *section = __pfn_to_section(pfn);
>  	struct page_cgroup *base, *pc;
> -- 
> 1.7.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
