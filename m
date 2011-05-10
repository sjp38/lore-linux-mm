Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD986B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:54:49 -0400 (EDT)
Date: Tue, 10 May 2011 14:54:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: tracing: Add missing GFP flags to tracing
Message-Id: <20110510145446.1f8e77e3.akpm@linux-foundation.org>
In-Reply-To: <20110510100954.GC4146@suse.de>
References: <20110510100954.GC4146@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Tue, 10 May 2011 11:09:54 +0100
Mel Gorman <mgorman@suse.de> wrote:

> include/linux/gfp.h and include/trace/events/gfpflags.h is out of
> sync. When tracing is enabled, certain flags are not recognised and
> the text output is less useful as a result.  Add the missing flags.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/trace/events/gfpflags.h |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
> index e3615c0..9fe3a366 100644
> --- a/include/trace/events/gfpflags.h
> +++ b/include/trace/events/gfpflags.h
> @@ -10,6 +10,7 @@
>   */
>  #define show_gfp_flags(flags)						\
>  	(flags) ? __print_flags(flags, "|",				\
> +	{(unsigned long)GFP_TRANSHUGE,		"GFP_TRANSHUGE"},	\
>  	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
>  	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
>  	{(unsigned long)GFP_USER,		"GFP_USER"},		\
> @@ -32,6 +33,9 @@
>  	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
>  	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
>  	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
> -	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"}		\
> +	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
> +	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
> +	{(unsigned long)__GFP_NO_KSWAPD,	"GFP_NO_KSWAPD"},	\
> +	{(unsigned long)__GFP_OTHER_NODE,	"GFP_OTHER_NODE"}	\
>  	) : "GFP_NOWAIT"

The patch seems somewhat needed in 2.6.38.x, but 2.6.38 doesn't have
__GFP_OTHER_NODE.  So if you think this needs fixing in -stable, please
prepare a separate patch for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
