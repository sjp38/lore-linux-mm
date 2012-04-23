Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 2385C6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 17:39:51 -0400 (EDT)
Date: Mon, 23 Apr 2012 14:39:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mmap.c: find_vma: remove unnecessary if(mm) check
Message-Id: <20120423143948.01a0ac60.akpm@linux-foundation.org>
In-Reply-To: <1335015755-2881-1-git-send-email-rajman.mekaco@gmail.com>
References: <1335015755-2881-1-git-send-email-rajman.mekaco@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rajman Mekaco <rajman.mekaco@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

On Sat, 21 Apr 2012 19:12:35 +0530
Rajman Mekaco <rajman.mekaco@gmail.com> wrote:

> The if(mm) check is not required in find_vma, as the kernel
> code calls find_vma only when it is absolutely sure that the
> mm_struct arg to it is non-NULL.
> 
> Removing the if(mm) check and adding the a WARN_ONCE(!mm)
> for now.

Lets do this as well:

--- a/mm/mmap.c~mm-mmapc-find_vma-remove-unnecessary-ifmm-check-fix
+++ a/mm/mmap.c
@@ -1639,7 +1639,7 @@ struct vm_area_struct *find_vma(struct m
 {
 	struct vm_area_struct *vma = NULL;
 
-	if (WARN_ON_ONCE(!mm))
+	if (WARN_ON_ONCE(!mm))		/* Remove this in linux-3.6 */
 		return NULL;
 
 	/* Check the cache first. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
