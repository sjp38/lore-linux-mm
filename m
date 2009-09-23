Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7907C6B005A
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 16:37:37 -0400 (EDT)
Date: Wed, 23 Sep 2009 13:37:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ksm: change default values to better fit into mainline
 kernel
Message-Id: <20090923133735.dbe5dcec.akpm@linux-foundation.org>
In-Reply-To: <1253736347-3779-1-git-send-email-ieidus@redhat.com>
References: <1253736347-3779-1-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 23 Sep 2009 23:05:47 +0300
Izik Eidus <ieidus@redhat.com> wrote:

> +static void __init ksm_init_max_kernel_pages(void)
> +{
> +	ksm_max_kernel_pages = nr_free_buffer_pages() / 4;
> +}
> +
>  static int __init ksm_slab_init(void)
>  {
>  	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
> @@ -1667,6 +1673,8 @@ static int __init ksm_init(void)
>  	struct task_struct *ksm_thread;
>  	int err;
>  
> +	ksm_init_max_kernel_pages();

Was it really worth creating a new function for this?

--- a/mm/ksm.c~ksm-change-default-values-to-better-fit-into-mainline-kernel-fix
+++ a/mm/ksm.c
@@ -184,11 +184,6 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
-static void __init ksm_init_max_kernel_pages(void)
-{
-	ksm_max_kernel_pages = nr_free_buffer_pages() / 4;
-}
-
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -1673,7 +1668,7 @@ static int __init ksm_init(void)
 	struct task_struct *ksm_thread;
 	int err;
 
-	ksm_init_max_kernel_pages();
+	ksm_max_kernel_pages = nr_free_buffer_pages() / 4;
 
 	err = ksm_slab_init();
 	if (err)
_

oh well, whatever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
