Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AA6986B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:42:37 -0500 (EST)
Date: Fri, 19 Nov 2010 09:42:11 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: percpu: Implement this_cpu_add,sub,dec,inc_return
In-Reply-To: <1290018527.2687.108.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1011190941380.32655@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>  <alpine.DEB.2.00.1011100939530.23566@router.home> <1290018527.2687.108.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, Eric Dumazet wrote:

> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index b676c58..bb5db26 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -91,7 +91,7 @@ static inline int kmap_atomic_idx_push(void)
>
>  static inline int kmap_atomic_idx(void)
>  {
> -	return __get_cpu_var(__kmap_atomic_idx) - 1;
> +	return __this_cpu_read(__kmap_atomic_idx) - 1;
>  }
>
>  static inline int kmap_atomic_idx_pop(void)

This isnt a use case for this_cpu_dec right? Seems that your message was
cut off?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
