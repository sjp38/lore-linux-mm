Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 63AC36B006C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:35:36 -0400 (EDT)
Message-ID: <4FD93FE8.1030102@kernel.org>
Date: Thu, 14 Jun 2012 10:35:36 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: fix uninit'ed variable warning
References: <1339621422-8449-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1339621422-8449-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Seth,

On 06/14/2012 06:03 AM, Seth Jennings wrote:

> This patch fixes an uninitialized variable warning in
> alloc_zspage().  It also fixes the secondary issue of
> prev_page leaving scope on each loop iteration.  The only
> reason this ever worked was because prev_page was occupying
> the same space on the stack on each iteration.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>


Nice catch!

Acked-by: Minchan Kim <minchan@kernel.org>

Nitpick:
I can't see the warning.
My gcc version is gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3.

Please, Cced linux-mm, too.
Some guys in mm might have a interest in zsmalloc. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
