Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 112979000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:53:05 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 78C2B3EE0AE
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:53:00 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 60CFE45DF46
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:53:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AA8A45DE80
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:53:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E9401DB8037
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:53:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B94A1DB802F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:53:00 +0900 (JST)
Date: Wed, 28 Sep 2011 09:52:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH]   fix find_next_system_ram comments
Message-Id: <20110928095217.37650ffd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317045482-3355-1-git-send-email-wizarddewhite@gmail.com>
References: <1317045482-3355-1-git-send-email-wizarddewhite@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wizard <wizarddewhite@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 26 Sep 2011 21:58:02 +0800
Wizard <wizarddewhite@gmail.com> wrote:

> The purpose of find_next_system_ram() is to find a the lowest
> memory resource which contain or overlap the [res->start, res->end),
> not just contain.
> 
> In this patch, I make this comment more exact and fix one typo.
> 
> Signed-off-by: Wizard <wizarddewhite@gmail.com>

Thank you for catching.

Please hear Randy's advice :)

> ---
>  kernel/resource.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 3b3cedc..2751a8c 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -279,7 +279,8 @@ EXPORT_SYMBOL(release_resource);
>  
>  #if !defined(CONFIG_ARCH_HAS_WALK_MEMORY)
>  /*
> - * Finds the lowest memory reosurce exists within [res->start.res->end)
> + * Finds the lowest memory resource which contains or overlaps
> + * [res->start.res->end)
>   * the caller must specify res->start, res->end, res->flags and "name".
>   * If found, returns 0, res is overwritten, if not found, returns -1.
>   */
> -- 
> 1.6.3.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
