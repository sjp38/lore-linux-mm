Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 89FC56B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 17:17:25 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id x3so4702980qcv.36
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 14:17:25 -0800 (PST)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id c1si70823160qcq.32.2014.11.18.14.17.24
        for <linux-mm@kvack.org>;
        Tue, 18 Nov 2014 14:17:24 -0800 (PST)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id 62890101384
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 17:17:20 -0500 (EST)
Date: Tue, 18 Nov 2014 16:17:20 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 1/1] mm/zswap: Deletion of an unnecessary check before
 the function call "free_percpu"
Message-ID: <20141118221720.GA20945@cerebellum.variantweb.net>
References: <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
 <546A3302.9040804@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <546A3302.9040804@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Coccinelle <cocci@systeme.lip6.fr>

On Mon, Nov 17, 2014 at 06:40:18PM +0100, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 17 Nov 2014 18:33:33 +0100
> 
> The free_percpu() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.

Thanks for the cleanup!

Acked-by: Seth Jennings <sjennings@variantweb.net>

> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  mm/zswap.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index ea064c1..35629f0 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -152,8 +152,7 @@ static int __init zswap_comp_init(void)
>  static void zswap_comp_exit(void)
>  {
>  	/* free percpu transforms */
> -	if (zswap_comp_pcpu_tfms)
> -		free_percpu(zswap_comp_pcpu_tfms);
> +	free_percpu(zswap_comp_pcpu_tfms);
>  }
>  
>  /*********************************
> -- 
> 2.1.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
