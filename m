Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 1DAB86B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 01:02:17 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 962FC3EE081
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:02:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B1A845DE5F
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:02:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 61A1645DE5C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:02:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 511C5E08004
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:02:15 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F10D11DB8051
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:02:14 +0900 (JST)
Date: Wed, 29 Feb 2012 15:00:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/10] memcg: Introduce __GFP_NOACCOUNT.
Message-Id: <20120229150041.62c1feeb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1330383533-20711-5-git-send-email-ssouhlal@FreeBSD.org>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-5-git-send-email-ssouhlal@FreeBSD.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, glommer@parallels.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Mon, 27 Feb 2012 14:58:47 -0800
Suleiman Souhlal <ssouhlal@FreeBSD.org> wrote:

> This is used to indicate that we don't want an allocation to be accounted
> to the current cgroup.
> 
> Signed-off-by: Suleiman Souhlal <suleiman@google.com>

I don't like this.

Please add 

___GFP_ACCOUNT  "account this allocation to memcg"

Or make this as slab's flag if this work is for slab allocation.

Thanks,
-Kame



> ---
>  include/linux/gfp.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 581e74b..765c20f 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -23,6 +23,7 @@ struct vm_area_struct;
>  #define ___GFP_REPEAT		0x400u
>  #define ___GFP_NOFAIL		0x800u
>  #define ___GFP_NORETRY		0x1000u
> +#define ___GFP_NOACCOUNT	0x2000u
>  #define ___GFP_COMP		0x4000u
>  #define ___GFP_ZERO		0x8000u
>  #define ___GFP_NOMEMALLOC	0x10000u
> @@ -76,6 +77,7 @@ struct vm_area_struct;
>  #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
>  #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)	/* See above */
>  #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY) /* See above */
> +#define __GFP_NOACCOUNT	((__force gfp_t)___GFP_NOACCOUNT) /* Don't account to the current cgroup */
>  #define __GFP_COMP	((__force gfp_t)___GFP_COMP)	/* Add compound page metadata */
>  #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)	/* Return zeroed page on success */
>  #define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves */
> -- 
> 1.7.7.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
