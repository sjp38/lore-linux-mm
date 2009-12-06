Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 886BD60021B
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 15:34:34 -0500 (EST)
Message-ID: <4B1C1554.5060007@redhat.com>
Date: Sun, 06 Dec 2009 15:34:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] Don't deactivate the page if trylock_page() is failed.
References: <20091204173233.5891.A69D9226@jp.fujitsu.com> <20091204174347.58A0.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091204174347.58A0.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/04/2009 03:44 AM, KOSAKI Motohiro wrote:
>  From 7635eaa033cfcce7f351b5023952f23f0daffefe Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 4 Dec 2009 12:03:07 +0900
> Subject: [PATCH 5/7] Don't deactivate the page if trylock_page() is failed.
>
> Currently, wipe_page_reference() increment refctx->referenced variable
> if trylock_page() is failed. but it is meaningless at all.
> shrink_active_list() deactivate the page although the page was
> referenced. The page shouldn't be deactivated with young bit. it
> break reclaim basic theory and decrease reclaim throughput.
>
> This patch introduce new SWAP_AGAIN return value to
> wipe_page_reference().
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
