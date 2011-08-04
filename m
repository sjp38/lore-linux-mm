Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 52B0E6B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 18:05:27 -0400 (EDT)
Date: Thu, 4 Aug 2011 15:05:24 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] zcache: Fix build error when sysfs is not defined
Message-Id: <20110804150524.2dcfcecf.rdunlap@xenotime.net>
In-Reply-To: <1297484079-12562-1-git-send-email-ngupta@vflare.org>
References: <1297484079-12562-1-git-send-email-ngupta@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>, Stephen Rothwell <sfr@canb.auug.org.au>, gregkh@suse.de
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, 11 Feb 2011 23:14:39 -0500 Nitin Gupta wrote:

> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> ---
>  drivers/staging/zcache/zcache.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache.c b/drivers/staging/zcache/zcache.c
> index 61be849..8cd3fd8 100644
> --- a/drivers/staging/zcache/zcache.c
> +++ b/drivers/staging/zcache/zcache.c
> @@ -1590,9 +1590,9 @@ __setup("nofrontswap", no_frontswap);
>  
>  static int __init zcache_init(void)
>  {
> -#ifdef CONFIG_SYSFS
>  	int ret = 0;
>  
> +#ifdef CONFIG_SYSFS
>  	ret = sysfs_create_group(mm_kobj, &zcache_attr_group);
>  	if (ret) {
>  		pr_err("zcache: can't create sysfs\n");
> -- 

OMG.  This patch still needs to be applied to linux-next 20110804..........
sad.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
