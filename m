Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1CE900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:14:33 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 634453EE0BD
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:14:30 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B28045DE4E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:14:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 30A9745DD74
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:14:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 21A411DB803E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:14:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E46A81DB803A
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:14:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] make sparse happy with gfp.h
In-Reply-To: <20110414234216.9E31DBD9@kernel>
References: <20110414234216.9E31DBD9@kernel>
Message-Id: <20110415121424.F7A6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 Apr 2011 12:14:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Hello,

> diff -puN include/linux/gfp.h~make-sparse-happy-with-gfp_h include/linux/gfp.h
> --- linux-2.6.git/include/linux/gfp.h~make-sparse-happy-with-gfp_h	2011-04-14 14:47:02.629275904 -0700
> +++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-14 14:47:38.813272674 -0700
> @@ -249,14 +249,9 @@ static inline enum zone_type gfp_zone(gf
>  
>  	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
>  					 ((1 << ZONES_SHIFT) - 1);
> -
> -	if (__builtin_constant_p(bit))
> -		BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> -	else {
>  #ifdef CONFIG_DEBUG_VM
> -		BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> +	BUG_ON((GFP_ZONE_BAD >> bit) & 1);
>  #endif
> -	}
>  	return z;

Why don't you use VM_BUG_ON?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
