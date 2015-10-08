Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4556B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 18:15:59 -0400 (EDT)
Received: by qkap81 with SMTP id p81so25589884qka.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 15:15:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 66si41770183qgm.14.2015.10.08.15.15.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 15:15:58 -0700 (PDT)
Date: Thu, 8 Oct 2015 15:15:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -next] mm/vmacache: inline vmacache_valid_mm()
Message-Id: <20151008151557.0ea74baaafa753b7e86731d0@linux-foundation.org>
In-Reply-To: <1444277879-22039-1-git-send-email-dave@stgolabs.net>
References: <1444277879-22039-1-git-send-email-dave@stgolabs.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On Wed,  7 Oct 2015 21:17:59 -0700 Davidlohr Bueso <dave@stgolabs.net> wrote:

> This function incurs in very hot paths and merely
> does a few loads for validity check. Lets inline it,
> such that we can save the function call overhead.
> 
> ...
>
> --- a/mm/vmacache.c
> +++ b/mm/vmacache.c
> @@ -52,7 +52,7 @@ void vmacache_flush_all(struct mm_struct *mm)
>   * Also handle the case where a kernel thread has adopted this mm via use_mm().
>   * That kernel thread's vmacache is not applicable to this mm.
>   */
> -static bool vmacache_valid_mm(struct mm_struct *mm)
> +static inline bool vmacache_valid_mm(struct mm_struct *mm)
>  {
>  	return current->mm == mm && !(current->flags & PF_KTHREAD);
>  }

Yeah, I'll ingest my headgear if there's any vaguely recent compiler
which isn't already inlining this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
