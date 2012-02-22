Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6C0F66B00FF
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 19:48:00 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 642833EE0C0
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:47:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C9F745DE52
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:47:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 31C7645DD78
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:47:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F78E1DB802C
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:47:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C93BF1DB803A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:47:57 +0900 (JST)
Date: Wed, 22 Feb 2012 09:46:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] small cleanup for memcontrol.c
Message-Id: <20120222094619.caffc432.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1329824079-14449-2-git-send-email-glommer@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
	<1329824079-14449-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Paul Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>

On Tue, 21 Feb 2012 15:34:33 +0400
Glauber Costa <glommer@parallels.com> wrote:

> Move some hardcoded definitions to an enum type.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Kirill A. Shutemov <kirill@shutemov.name>
> CC: Greg Thelen <gthelen@google.com>
> CC: Johannes Weiner <jweiner@redhat.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Paul Turner <pjt@google.com>
> CC: Frederic Weisbecker <fweisbec@gmail.com>

seems ok to me.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

a nitpick..

> ---
>  mm/memcontrol.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6728a7a..b15a693 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -351,9 +351,13 @@ enum charge_type {
>  };
>  
>  /* for encoding cft->private value on file */
> -#define _MEM			(0)
> -#define _MEMSWAP		(1)
> -#define _OOM_TYPE		(2)
> +
> +enum mem_type {
> +	_MEM = 0,

=0 is required ?

> +	_MEMSWAP,
> +	_OOM_TYPE,
> +};
> +
>  #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
>  #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
>  #define MEMFILE_ATTR(val)	((val) & 0xffff)
> -- 
> 1.7.7.6
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
