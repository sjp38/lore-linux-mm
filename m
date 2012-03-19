Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 12F216B004A
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 20:35:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0352D3EE0BC
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:35:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA8CB45DE9E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:35:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C95B45DEB3
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:35:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 83B411DB804B
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:35:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B2951DB803E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:35:05 +0900 (JST)
Message-ID: <4F667ED4.60204@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 09:33:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] TRIVIAL: mmap.c: fix comment for __insert_vm_struct()
References: <1331918590-2786-1-git-send-email-consul.kautuk@gmail.com>
In-Reply-To: <1331918590-2786-1-git-send-email-consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Jiri Kosina <trivial@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/03/17 2:23), Kautuk Consul wrote:

> The comment above __insert_vm_struct seems to suggest that this
> function is also going to link the VMA with the anon_vma, but
> this is not true.
> This function only links the VMA to the mm->mm_rb tree and the mm->mmap linked
> list.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
> ---
>  mm/mmap.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index da15a79..6328a36 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -452,8 +452,8 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  /*
>   * Helper for vma_adjust in the split_vma insert case:
> - * insert vm structure into list and rbtree and anon_vma,
> - * but it has already been inserted into prio_tree earlier.
> + * insert vm structure into list and rbtree, but it has
> + * already been inserted into prio_tree earlier.
>   */
>  static void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
>  {


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
