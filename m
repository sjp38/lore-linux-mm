Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 823949000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 12:58:58 -0400 (EDT)
Message-ID: <4E80AF4F.1030706@xenotime.net>
Date: Mon, 26 Sep 2011 09:58:55 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: [PATCH]   fix find_next_system_ram comments
References: <1317045482-3355-1-git-send-email-wizarddewhite@gmail.com>
In-Reply-To: <1317045482-3355-1-git-send-email-wizarddewhite@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wizard <wizarddewhite@gmail.com>
Cc: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On 09/26/2011 06:58 AM, Wizard wrote:
> The purpose of find_next_system_ram() is to find a the lowest
> memory resource which contain or overlap the [res->start, res->end),
> not just contain.
> 
> In this patch, I make this comment more exact and fix one typo.
> 
> Signed-off-by: Wizard <wizarddewhite@gmail.com>

For Signed-off-by: Documentation/SubmittingPatches says:

using your real name (sorry, no pseudonyms or anonymous contributions.)

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

Your patch description uses ", " (comma) here.  I think that's better than
keeping the ".".

>   * the caller must specify res->start, res->end, res->flags and "name".
>   * If found, returns 0, res is overwritten, if not found, returns -1.
>   */


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
