Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 807DC6B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 18:08:00 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so6037597pdb.16
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 15:08:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fd2si41959040pbd.177.2014.07.07.15.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 15:07:59 -0700 (PDT)
Date: Mon, 7 Jul 2014 15:07:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,vmacache: inline vmacache_valid_mm()
Message-Id: <20140707150757.d8812f4243c9c5dccebc3e4f@linux-foundation.org>
In-Reply-To: <1404508083.2457.15.camel@buesod1.americas.hpqcorp.net>
References: <1404508083.2457.15.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 04 Jul 2014 14:08:03 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:

> From: Davidlohr Bueso <davidlohr@hp.com>
> 
> No brainer for this little function.
> 
> ...
>
> --- a/mm/vmacache.c
> +++ b/mm/vmacache.c
> @@ -50,7 +50,7 @@ void vmacache_flush_all(struct mm_struct *mm)
>   * Also handle the case where a kernel thread has adopted this mm via use_mm().
>   * That kernel thread's vmacache is not applicable to this mm.
>   */
> -static bool vmacache_valid_mm(struct mm_struct *mm)
> +static inline bool vmacache_valid_mm(struct mm_struct *mm)
>  {
>  	return current->mm == mm && !(current->flags & PF_KTHREAD);
>  }

The patch doesn't actually do anything.

- gcc ignores `inline'

- gcc will inline this function anwyay

- if we really really need a hammer, we use __always_inline, along
  with a comment explaining why.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
