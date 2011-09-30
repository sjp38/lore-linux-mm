Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3284E9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 17:30:04 -0400 (EDT)
Message-ID: <4E8634D3.2080504@zytor.com>
Date: Fri, 30 Sep 2011 14:29:55 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFCv2][PATCH 1/4] break units out of string_get_size()
References: <20110930203219.60D507CB@kernel>
In-Reply-To: <20110930203219.60D507CB@kernel>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com

On 09/30/2011 01:32 PM, Dave Hansen wrote:
> I would like to use these (well one of them) arrays in
> another function.  Might as well break both versions
> out for consistency.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/lib/string_helpers.c |   25 +++++++++++++------------
>  1 file changed, 13 insertions(+), 12 deletions(-)
> 
> diff -puN lib/string_helpers.c~string_get_size-pow2 lib/string_helpers.c
>  
> +const char *units_10[] = { "B", "kB", "MB", "GB", "TB", "PB",
> +			   "EB", "ZB", "YB", NULL};
> +const char *units_2[] = {"B", "KiB", "MiB", "GiB", "TiB", "PiB",
> +			 "EiB", "ZiB", "YiB", NULL };

These names are way too generic to be public symbols.

Another thing worth thinking about is whether or not the -B suffix
should be part of these arrays.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
