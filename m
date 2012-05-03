Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 50F0A6B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 09:19:48 -0400 (EDT)
Received: by qabg27 with SMTP id g27so230322qab.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 06:19:47 -0700 (PDT)
Message-ID: <4FA285F5.20303@vflare.org>
Date: Thu, 03 May 2012 09:19:49 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] zsmalloc: add/fix function comment
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1336027242-372-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 5/3/12 2:40 AM, Minchan Kim wrote:
> Add/fix the comment.
>
> Signed-off-by: Minchan Kim<minchan@kernel.org>
> ---
>   drivers/staging/zsmalloc/zsmalloc-main.c |   17 +++++++++++------
>   1 file changed, 11 insertions(+), 6 deletions(-)

Acked-by: Nitin Gupta <ngupta@vflare.org>

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
