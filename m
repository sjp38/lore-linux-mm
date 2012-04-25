Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 6D35E6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:44:04 -0400 (EDT)
Received: by qam2 with SMTP id 2so888629qam.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 05:44:03 -0700 (PDT)
Message-ID: <4F97F18E.4000600@vflare.org>
Date: Wed, 25 Apr 2012 08:43:58 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] zsmalloc: use PageFlag macro instead of [set|test]_bit
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1335334994-22138-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/25/2012 02:23 AM, Minchan Kim wrote:

> MM code always uses PageXXX to handle page flags.
> Let's keep the consistency.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>



Acked-by: Nitin Gupta <ngupta@vflare.org>

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
