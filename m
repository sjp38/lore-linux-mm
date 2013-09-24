Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1BF6B0034
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:55:07 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so4173336pad.23
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 13:55:07 -0700 (PDT)
Message-ID: <5241FC12.4090107@infradead.org>
Date: Tue, 24 Sep 2013 13:54:42 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH resend] typo: replace kernelcore with Movable
References: <a1714d6a349ac584626a164631c5e2b74d91326d.1380012101.git.wpan@redhat.com>
In-Reply-To: <a1714d6a349ac584626a164631c5e2b74d91326d.1380012101.git.wpan@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weiping Pan <wpan@redhat.com>
Cc: linux-mm@kvack.org, rob@landley.net, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 09/24/13 01:48, Weiping Pan wrote:
> Han Pingtian found a typo in Documentation/kernel-parameters.txt
> about "kernelcore=", that "kernelcore" should be replaced with "Movable" here.
> 
> I sent this patch a 8 months ago and got ack from Mel Gorman,
> http://marc.info/?l=linux-mm&m=135756720602638&w=2
> but it has not been merged so I resent it again.
> 
> Signed-off-by: Weiping Pan <wpan@redhat.com>

so add:
Acked-by: Mel Gorman <mgorman@suse.de>

and Cc: Andrew Morton.  He can easily merge it.

Thanks.

> ---
>  Documentation/kernel-parameters.txt |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 1a036cd9..c3ea235 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1357,7 +1357,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			pages. In the event, a node is too small to have both
>  			kernelcore and Movable pages, kernelcore pages will
>  			take priority and other nodes will have a larger number
> -			of kernelcore pages.  The Movable zone is used for the
> +			of Movable pages.  The Movable zone is used for the
>  			allocation of pages that may be reclaimed or moved
>  			by the page migration subsystem.  This means that
>  			HugeTLB pages may not be allocated from this zone.
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
