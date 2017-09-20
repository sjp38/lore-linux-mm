Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24CC86B027C
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:45:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so6462462pff.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:45:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z11sor1332184plo.122.2017.09.20.13.45.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:45:35 -0700 (PDT)
Date: Wed, 20 Sep 2017 13:45:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] tools: slabinfo: add "-U" option to show unreclaimable
 slabs only
In-Reply-To: <1505934576-9749-2-git-send-email-yang.s@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1709201343320.97971@chino.kir.corp.google.com>
References: <1505934576-9749-1-git-send-email-yang.s@alibaba-inc.com> <1505934576-9749-2-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 21 Sep 2017, Yang Shi wrote:

> diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
> index b9d34b3..9673190 100644
> --- a/tools/vm/slabinfo.c
> +++ b/tools/vm/slabinfo.c
> @@ -83,6 +83,7 @@ struct aliasinfo {
>  int sort_loss;
>  int extended_totals;
>  int show_bytes;
> +int unreclaim_only;
>  
>  /* Debug options */
>  int sanity;
> @@ -132,6 +133,7 @@ static void usage(void)
>  		"-L|--Loss              Sort by loss\n"
>  		"-X|--Xtotals           Show extended summary information\n"
>  		"-B|--Bytes             Show size in bytes\n"
> +		"-U|--unreclaim		Show unreclaimable slabs only\n"
>  		"\nValid debug options (FZPUT may be combined)\n"
>  		"a / A          Switch on all debug options (=FZUP)\n"
>  		"-              Switch off all debug options\n"

I suppose this should be s/unreclaim/Unreclaim/

> @@ -568,6 +570,9 @@ static void slabcache(struct slabinfo *s)
>  	if (strcmp(s->name, "*") == 0)
>  		return;
>  
> +	if (unreclaim_only && s->reclaim_account)
> +		return;
> +		
>  	if (actual_slabs == 1) {
>  		report(s);
>  		return;
> @@ -1346,6 +1351,7 @@ struct option opts[] = {
>  	{ "Loss", no_argument, NULL, 'L'},
>  	{ "Xtotals", no_argument, NULL, 'X'},
>  	{ "Bytes", no_argument, NULL, 'B'},
> +	{ "unreclaim", no_argument, NULL, 'U'},
>  	{ NULL, 0, NULL, 0 }
>  };
>  

Same.

After that:

Acked-by: David Rientjes <rientjes@google.com>

Also, you may find it better to remove the "RFC" tag from the patchset's 
header email since it's agreed that we want this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
