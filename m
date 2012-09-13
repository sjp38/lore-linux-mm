Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id D66E96B0178
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 16:44:26 -0400 (EDT)
Date: Thu, 13 Sep 2012 17:44:09 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH -mm] enable CONFIG_COMPACTION by default
Message-ID: <20120913204408.GA10671@optiplex.redhat.com>
References: <20120913162104.1458bea2@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120913162104.1458bea2@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 13, 2012 at 04:21:04PM -0400, Rik van Riel wrote:
> Now that lumpy reclaim has been removed, compaction is the
> only way left to free up contiguous memory areas. It is time
> to just enable CONFIG_COMPACTION by default.
>     
> Signed-off-by: Rik van Riel <riel@redhat.com>
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d5c8019..32ea0ef 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -191,6 +191,7 @@ config SPLIT_PTLOCK_CPUS
>  # support for memory compaction
>  config COMPACTION
>  	bool "Allow for memory compaction"
> +	def_bool y
>  	select MIGRATION
>  	depends on MMU
>  	help
>

Acked-by: Rafael Aquini <aquini@redhat.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
